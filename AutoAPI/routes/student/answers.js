const express = require('express');
const router = express.Router();
const { Answer } = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');
const { redisClient,setKey, getKey,delKey, getKeysByPattern} = require('../../utils/redis');
/**
 * 向answers表提交答案
 * POST /student/answers
 */
router.post('/', async function (req, res, next) {
    try {
        try {
            const body = filterBody(req);
            const answer = await Answer.create(body);
            await clearCache(req.query.studentId, body.excercise_id);
            success(res, '答案提交成功。', {answer});
        } catch (error) {
            failure(res, error);
        }
    }catch (error) {
        failure(res, error);
    }
})

/**
 * 获取answers表的score
 * GET /student/answers/:excerciseId
 */
router.get('/:excerciseId', async function (req, res, next) {
    try {
        //定义带有[当前页码]和[每页条数]的cacheKey作为缓存的键
        const cacheKey = `answers:${req.query.studentId}:${req.params.excerciseId}`;
        //读取缓存中的数据
        let data = await getKey(cacheKey);
        if(data) {
            return success(res, `查询 答案 成功。`, data)
        }

        const condition = {
            excercise_id: req.params.excerciseId,
            student_id: req.query.studentId
        }
        const answer = await Answer.findAll({
            where: condition
        });
        //缓存数据
        data = answer;
        await setKey(cacheKey, data);

        if (answer) {
            success(res, '获取答案成功。', data);
        } else {
            throw new NotFoundError('答案不存在。');
        }
    }catch (error) {
        failure(res, error);
    }
})

/**
 * 公共方法：白名单过滤
 */
function filterBody(req) {
    return {
        answer: req.body.answer,
        excercise_id: req.body.excercise_id,
        student_id: req.query.studentId
    }
}
/**
 * 清除缓存
 */
async function clearCache() {
    const keys = await getKeysByPattern(`answers:*`);
    if(keys.length !== 0){
        await delKey(keys);
    }
}
module.exports = router;