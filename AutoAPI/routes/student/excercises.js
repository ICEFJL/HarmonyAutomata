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