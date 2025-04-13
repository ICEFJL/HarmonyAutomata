const express = require('express');
const router = express.Router();
const { Answer } = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');

/**
 * 向answers表提交答案
 * POST /student/answers
 */
router.post('/', async function (req, res, next) {
    try {
        try {
            const body = filterBody(req);
            const answer = await Answer.create(body);
            success(res, '答案提交成功。', {answer}, 201);
        } catch (error) {
            failure(res, error);
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
        student_id: req.userId
    }
}

module.exports = router;