const express = require('express');
const router = express.Router();
const { Excercise,TeacherAndStudent,Answer,User } = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');
const { redisClient,setKey, getKey,delKey, getKeysByPattern} = require('../../utils/redis');
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

        //定义带有[当前页码]和[每页条数]的cacheKey作为缓存的键
        const cacheKey = `excercises:${req.query.excerciseType}:${currentPage}:${pageSize}`;
        //读取缓存中的数据
        let data = await getKey(cacheKey);
        if(data) {
            return success(res, `查询 ${req.query.excerciseType} 习题列表成功。`, data)
        }

        //找到该学生的所有老师
        const teachers = await TeacherAndStudent.findAll({
            where: {
                //student_id: req.userId
                student_id: req.query.userId
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
            type: req.query.excerciseType,
        }
        condition.include = [{
            model: User,
            as: 'ex',
            attributes: ['uname']
        }]
        const {count, rows} = await Excercise.findAndCountAll(condition,{attributes: ['id', 'title','type','publisher','createdAt']});

        data = {
            excercises: rows.map(excercise => ({
            id: excercise.id,
            title: excercise.title,
            publisher: excercise.publisher,
            publisherName: excercise.ex.uname,
            publishTime: excercise.createdAt,
            type:excercise.type
        })),
            pagination: {
                total: count,
                currentPage:currentPage,
                pageSize:pageSize,
                totalPage: Math.ceil(count / pageSize)
            }
        }
        await setKey(cacheKey, data);

        //success(res, '查询习题列表成功。', {teachers});
        success(res, '查询习题列表成功。', {
            excercises: rows.map(excercise => ({
                id: excercise.id,
                title: excercise.title,
                publisher: excercise.publisher,
                publisherName: excercise.ex.uname,
                publishTime: excercise.createdAt,
                type:excercise.type
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

        //定义带有[当前页码]和[每页条数]的cacheKey作为缓存的键
        const cacheKey = `excercises:${currentPage}:${pageSize}:${req.query.excerciseType}:completed`;
        //读取缓存中的数据
        let data = await getKey(cacheKey);
        if(data) {
            return success(res, `查询 已完成 习题列表成功。`, data)
        }

        let condition = {};
        //找到answers表中的student_id为req.userId的记录，再查询excercise表中对应id的记录
        const answers = await Answer.findAll({
            where: {
                student_id: req.query.userId
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
        data = {
            excercises:rows.map(excercise => ({
                id: excercise.id,
                title: excercise.title,
                publisher: excercise.publisher,
                publisherName: excercise.ex.uname,
                publishTime: excercise.createdAt,
                type: req.query.excerciseType
            })),
            pagination: {
                total: count,
                currentPage:currentPage,
                pageSize:pageSize,
                totalPage: Math.ceil(count / pageSize)
            }
        }
        await setKey(cacheKey, data);
        success(res, '查询已完成的习题列表成功。', {
            excercises: rows.map(excercise => ({
                id: excercise.id,
                title: excercise.title,
                publisher: excercise.publisher,
                publisherName: excercise.ex.uname,
                publishTime: excercise.createdAt,
                type: req.query.excerciseType
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

        //定义带有[当前页码]和[每页条数]的cacheKey作为缓存的键
        const cacheKey = `excercises:${currentPage}:${pageSize}:${req.query.excerciseType}:uncompleted`;
        //读取缓存中的数据
        let data = await getKey(cacheKey);
        if(data) {
            return success(res, `查询 未完成 习题列表成功。`, data)
        }

        const condition = {
            limit: pageSize,
            offset: offset
        };
        //查询该学生的所有老师，然后查询所有老师发布的所有习题excercises，查询answers表中该学生的所有记录answers，excercises.id不在answers.excercise_id中，则表示该学生未完成该习题
        const teachers = await TeacherAndStudent.findAll({
            where: {
                student_id: req.query.userId
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
                student_id: req.query.userId
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
        //缓存数据
        data = {
            excercises:rows.map(excercise => ({
                id: excercise.id,
                title: excercise.title,
                publisher: excercise.publisher,
                publisherName: excercise.ex.uname,
                publishTime: excercise.createdAt,
                type: req.query.excerciseType
            })),
            pagination: {
                total: count,
                currentPage:currentPage,
                pageSize:pageSize,
                totalPage: Math.ceil(count / pageSize)
            }
        }
        await setKey(cacheKey, data);

        success(res, '查询未完成的习题列表成功。', {
            excercises: rows.map(excercise => ({
                id: excercise.id,
                title: excercise.title,
                publisher: excercise.publisher,
                publisherName: excercise.ex.uname,
                publishTime: excercise.createdAt,
                type: req.query.excerciseType
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
        const {id} = req.params;
        let excercise = await getKey(`excercise:${id}`);
        let publisherName = ''
        if(!excercise){
            excercise = await Excercise.findByPk(id);
            publisherName = await User.findOne({
                where: {
                    id: excercise.publisher
                },
                attributes: ['uname']
            })
            excercise = {
                id: excercise.id,
                title: excercise.title,
                content: excercise.content,
                type: excercise.type,
                publisher: excercise.publisher,
                publisherName: publisherName.uname,
                publishTime: excercise.createdAt,
                answer: excercise.answer
            }
            if (!excercise) {
                throw new NotFoundError(`ID: ${id}的习题未找到`);
            }
            await setKey(`excercise:${id}`, {
                excercise: {
                    id:   excercise.id,
                    title: excercise.title,
                    content: excercise.content,
                    type: excercise.type,
                    publisher: excercise.publisher,
                    publisherName: excercise.publisherName,
                    publishTime: excercise.publishTime,
                    answer: excercise.answer
                }
            });
        }
        success(res, '查询习题详情成功。', excercise);
        // const excercise = await getExcercise(req);
        // success(res, '查询习题详情成功。', {excercise});
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
/**
 * 清除缓存
 */
async function clearCache(id = null) {
    const keys = await getKeysByPattern('excercises:*');
    if(keys.length !== 0) {
        await delKey(keys);
    }
    if(id) {
        const keys = await getKeysByPattern(`excercise:${id}`);
        await delKey(keys);
    }
}

module.exports = router;