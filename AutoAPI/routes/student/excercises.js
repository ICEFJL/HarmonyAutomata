const express = require('express');
const router = express.Router();
const { Excercise,TeacherAndStudent } = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');

/**
 * 查询各个类型的习题列表
 * GET Excercises listing.
 * get /student/excercises/
 */
router.get('/', async function (req, res, next) {
    try {
        const query = req.query;
        //当前是第几页，如果不传，默认第一页
        const currentPage = Math.abs(Number(query.currentPage)) || 1;
        const pageSize = Math.abs(Number(query.pageSize)) || 2;
        //计算offset
        const offset = (currentPage - 1) * pageSize;
        const condition = {
            limit: pageSize,
            offset: offset
        };
        //找到该学生的所有老师
        const teachers = await TeacherAndStudent.findAll({
            where: {
                student_id: req.userId
            },
            attributes: ['teacher_id']
        });
        //限制条件为，发布者为teachers的teacher_id或者null
        condition.where = {
            [Op.or]: [{
                publisher: {
                    [Op.in]: teachers.map(teacher => teacher.teacher_id)
                }
            }, {
                publisher: null
            }],
            type: req.query.excerciseType
        }
        const {count, rows} = await Excercise.findAndCountAll(condition);
        //success(res, '查询习题列表成功。', {teachers});
        success(res, '查询习题列表成功。', {
            excercises: rows.map(excercise => ({
                id: excercise.id,
                title: excercise.title,
                publisher: excercise.publisher,
            })),
            pagination: {
                total: count,
                currentPage: currentPage,
                pageSize: pageSize,
                totalPage: Math.ceil(count / pageSize)
            }
        });
    } catch (error) {
        failure(res, error);
    }
});
/**
 * 查询已完成的习题列表
 * GET Excercises listing.
 * get /student/excercises/completed
 */
router.get('/completed', async function (req, res, next) {
    try {
        const query = req.query;
        //当前是第几页，如果不传，默认第一页
        const currentPage = Math.abs(Number(query.currentPage)) || 1;
        const pageSize = Math.abs(Number(query.pageSize)) || 2;
        //计算offset
        const offset = (currentPage - 1) * pageSize;
        let condition = {};
        //找到answers表中的student_id为req.userId的记录，再查询excercise表中对应id的记录
        const answers = await Answer.findAll({
            where: {
                student_id: req.userId
            },
            attributes: ['excercise_id']
        });
        condition = {
            limit: pageSize,
            offset: offset,
            where : {
                id: {
                    [Op.in]: answers.map(answer => answer.excercise_id)
                },
                type: req.query.excerciseType,
            },
            include : [{
                model: User,
                as: 'ex',
                attributes: ['uname']
            }],
            attributes: ['id', 'title','publisher','createdAt']
        }
        const {count, rows} = await Excercise.findAndCountAll(condition);
        success(res, '查询已完成的习题列表成功。', {
            excercises: rows.map(excercise => ({
                id: excercise.id,
                title: excercise.title,
                publisher: excercise.publisher,
                publisher_uname: excercise.ex.uname,
                excercise_createdAt: excercise.createdAt,
            })),
            pagination: {
                total: count,
                currentPage: currentPage,
                pageSize: pageSize,
                totalPage: Math.ceil(count / pageSize)
            }
        })
    } catch (error) {
        failure(res, error);
    }
});
/**
 * 查询未完成的习题列表
 * get /student/excercises/uncompleted
 */
router.get('/uncompleted', async function (req, res, next) {
    try {
        const query = req.query;
        //当前是第几页，如果不传，默认第一页
        const currentPage = Math.abs(Number(query.currentPage)) || 1;
        const pageSize = Math.abs(Number(query.pageSize)) || 2;
        //计算offset
        const offset = (currentPage - 1) * pageSize;
        const condition = {
            limit: pageSize,
            offset: offset
        };
        //查询该学生的所有老师，然后查询所有老师发布的所有习题excercises，查询answers表中该学生的所有记录answers，excercises.id不在answers.excercise_id中，则表示该学生未完成该习题
        const teachers = await TeacherAndStudent.findAll({
            where: {
                student_id: req.userId
            },
            attributes: ['teacher_id']
        });
        condition.where = {
            [Op.or]: [{
                publisher: {
                    [Op.in]: teachers.map(teacher => teacher.teacher_id)
                }
            }, {
                publisher: null
            }],
            type: req.query.excerciseType
        }
        const answers = await Answer.findAll({
            where: {
                student_id: req.userId
            },
            attributes: ['excercise_id']
        });
        condition.where.id = {
            [Op.notIn]: answers.map(answer => answer.excercise_id)
        }
        //同时也要和users表连表查询uname
        condition.include = [{
            model: User,
            as: 'ex',
            attributes: ['uname']
        }];
        const {count, rows} = await Excercise.findAndCountAll(condition);
        success(res, '查询未完成的习题列表成功。', {
            excercises: rows.map(excercise => ({
                id: excercise.id,
                title: excercise.title,
                publisher: excercise.publisher,
                publisher_uname: excercise.ex.uname,
                excercise_createdAt: excercise.createdAt
            })),
            pagination: {
                total: count,
                currentPage: currentPage,
                pageSize: pageSize,
                totalPage: Math.ceil(count / pageSize)
            }
        })

    } catch (error) {
        failure(res, error);
    }
})

/**
 * 查询单个习题详情
 * get /student/excercises/:id
 */
router.get('/:id', async function (req, res, next) {
    try {
        const excercise = await getExcercise(req);
        success(res, '查询习题详情成功。', {excercise});
    } catch (error) {
        failure(res, error);
    }
})


/**
 * 公共方法：查询当前习题
 */
async function getExcercise(req) {
    //获取习题id
    const { id } = req.params;
    //查询习题
    const excercise = await Excercise.findByPk(id);
    //如果没有找到，抛出异常
    if (!excercise) {
        throw new NotFoundError(`ID: ${id}的用户未找到`);
    }
    return excercise;
}


module.exports = router;