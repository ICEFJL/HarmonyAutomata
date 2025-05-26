const express = require('express');
const router = express.Router();
const { User } = require('../../models');
const { TeacherAndStudent } = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');
const {Op} = require("sequelize");
const { redisClient,setKey, getKey,delKey, getKeysByPattern} = require('../../utils/redis');

/**
 * 查询当前登录用户详情
 * @route GET /teacher/users/me
 */
router.get('/me', async (req, res) => {
    try {
        const user = await getUser(req);
        success(res, '查询用户详情成功。', user)
    }catch (error) {
        failure(res, error);
    }
});
/**
 * 修改当前登录用户密码
 * @route PUT /teacher/users/account
 */
router.put('/account', async (req, res) => {
    try {

        const body = {
            uname: req.body.uname,
            current_upassword: req.body.current_upassword,
            upassword: req.body.upassword,
            upasswordConfirmation: req.body.upasswordConfirmation
        };
        if(!body.current_upassword){
            throw new BadRequestError('当前密码必须填写。');
        }
        if(body.upassword !== body.upasswordConfirmation){
            throw new BadRequestError('两次密码不一致。');
        }
        const user = await getUser(req,true);
        //验证当前密码是否正确
        const isPasswordValid = bcrypt.compareSync(body.current_upassword, user.upassword);
        if(!isPasswordValid){
            throw new BadRequestError('当前密码不正确。');
        }
        await user.update(body);
        delete user.dataValues.upassword;
        success(res, '修改信息成功。', { user });
    } catch (error) {
        failure(res, error);
    }
});

/**
 * 查询名下所有学生
 * @route GET /teacher/users/students
 */
router.get('/students', async (req, res) => {
    try {
        const query = req.query;
        //当前是第几页，如果不传，默认第一页
        const currentPage = Math.abs(Number(query.currentPage)) || 1;
        const pageSize = Math.abs(Number(query.pageSize)) || 2;
        //计算offset
        const offset = (currentPage - 1) * pageSize;

        //定义带有[教师id][当前页码]和[每页条数]的cacheKey作为缓存的键
        const cacheKey = `users:${req.query.userId}:${currentPage}:${pageSize}`;
        //读取缓存中的数据
        let data = await getKey(cacheKey);
        if(data) {
            return success(res, '查询学生列表成功。', data)
        }

        const students = await getStudents(req);
        const {count,rows} = await User.findAndCountAll({
            limit: pageSize,
            offset: offset,
            where: {
                id: students.map(student => student.student_id)
            },
            attributes: { exclude: ['upassword'] }
        });
        data = {
            users:rows,
            pagination: {
                total: count,
                currentPage: currentPage,
                pageSize:pageSize,
                totalPage: Math.ceil(count / pageSize)
            }
        }
        await setKey(cacheKey, data);
        success(res, '查询名下所有学生成功。', {
            users: rows.map(user => ({
                id: user.id,
                uname: user.uname,
                email: user.email,
                role: user.role,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt
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
 * 添加老师学生关系
 * @route POST /teacher/users/ts
 */
router.post('/ts', async (req, res) => {
    try {
        const studentId = req.body.id;
        const teacherId = req.query.userId;
        let condition = {
            where: {
                id: studentId,
                role: 'student'
            }
        }
        const student = await User.findOne(condition);
        if (!student) {
            throw new NotFoundError(`ID: ${ studentId } 学生不存在。`);
        }
        condition = {
            where: {
                id: teacherId,
                role: 'teacher'
            }
        }
        const teacher = await User.findOne(condition);
        if (!teacher) {
            throw new NotFoundError(`ID: ${ teacherId } 老师不存在。`);
        }
        condition = {
            where: {
                teacher_id: teacherId,
                student_id: studentId
            }
        }
        let teacherAndStudent = await TeacherAndStudent.findOne(condition);
        if (!teacherAndStudent) {
            teacherAndStudent = await TeacherAndStudent.create({
                teacher_id: teacherId,
                student_id: studentId
            });
        } else {
            throw new BadRequestError(`ID: ${ studentId } 学生已添加老师关系。`);
        }
        await clearCache(req)
        success(res, '添加老师学生关系成功。',{},201)
    } catch (error) {
        failure(res, error);
    }
});
/**
 * 公共方法:查询当前用户
 */
async function getUser(req,showPassword=false) {
    const id = req.query.userId;
    let condition = {};
    if(!showPassword){
        condition = {
            attributes: { exclude: ['upassword'] },
        };
    }
    const user = await User.findByPk(id, condition);
    if (!user) {
        throw new NotFoundError(`ID: ${ id } 用户不存在。`);
    }
    return user;
}

/**
 * 公共方法：查询名下学生
 */
async function getStudents(req) {
    const teacherId = req.query.userId;
    let condition = {
        where: {
            teacher_id: teacherId
        },
        attributes: ['student_id']
    }
    const students = await TeacherAndStudent.findAll(condition);
    return students;
}
/**
 * 清除缓存
 */
async function clearCache(id = null,req) {
    const keys = await getKeysByPattern(`users:${req.query.userId}:*`);
    if(keys.length !== 0) {
        await delKey(keys);
    }
}
module.exports = router;