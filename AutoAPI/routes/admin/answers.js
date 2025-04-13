const express = require('express');
const router = express.Router();
const { Answer } = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');

/**
 * 查询答案列表
 * GET Answers listing.
 * get /admin/answers
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
        if (query.title) {
            condition.where = {
                title: {
                    [Op.like]: `%${query.title}%`
                }
            }
        }
        const {count, rows} = await Answer.findAndCountAll(condition);
        success(res, '查询答案列表成功。', {
            excercises: rows.map(answer => ({
                id: answer.id,
                answer: answer.answer,
                excercise_id: answer.excercise_id,
                student_id: answer.student_id,
                score: answer.score,
                createdAt: answer.createdAt
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
 * get /admin/excercises/:id
 */
router.get('/:id', async function (req, res, next) {
    try {
        const answer = await getAnswer(req);
        success(res, '查询答案详情成功。', {answer});
    } catch (error) {
        failure(res, error);
    }
})


/**
 * 公共方法：查询当前习题
 */
async function getAnswer(req) {
    //获取习题id
    const { id } = req.params;
    //查询习题
    const answer = await Answer.findByPk(id);
    //如果没有找到，抛出异常
    if (!answer) {
        throw new NotFoundError(`ID: ${id}的用户未找到`);
    }
    return answer;
}


module.exports = router;