const express = require('express');
const router = express.Router();
const { Answer, Excercise} = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');
const { redisClient,setKey, getKey,delKey, getKeysByPattern} = require('../../utils/redis');

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

        //定义带有[当前页码]和[每页条数]的cacheKey作为缓存的键
        const cacheKey = `answers:${currentPage}:${pageSize}`;
        //读取缓存中的数据
        let data = await getKey(cacheKey);
        if(data) {
            return success(res, '查询答案列表成功。', data)
        }

        const condition = {
            limit: pageSize,
            offset: offset
        };
        // if (query.title) {
        //     condition.where = {
        //         title: {
        //             [Op.like]: `%${query.title}%`
        //         }
        //     }
        // }
        const {count, rows} = await Answer.findAndCountAll(condition);
        data = {
            excercises:rows,
            pagination: {
                total: count,
                currentPage,
                pageSize
            }
        }
        await setKey(cacheKey, data);

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
 * 查询单个答案详情
 * get /admin/answers/:id
 */
router.get('/:id', async function (req, res, next) {
    try {
        const {id} = req.params;
        let answer = await getKey(`answer:${id}`);
        if(!answer){
            answer = await Excercise.findByPk(id);
            if (!answer) {
                throw new NotFoundError(`ID: ${id}的答案未找到`);
            }
            await setKey(`answer:${id}`, answer);
        }
        success(res, '查询用户详情成功。', answer);
        // const answer = await getAnswer(req);
        // success(res, '查询答案详情成功。', {answer});
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
/**
 * 清除缓存
 */
async function clearCache(id = null) {
    const keys = await getKeysByPattern('answers:*');
    if(keys.length !== 0) {
        await delKey(keys);
    }
    if(id) {
        const keys = await getKeysByPattern(`answer:${id}`);
        await delKey(keys);
    }
}

module.exports = router;