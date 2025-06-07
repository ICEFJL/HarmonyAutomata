const express = require('express');
const router = express.Router();
const { Answer,User,Excercise,TeacherAndStudent } = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');
const { redisClient,setKey, getKey,delKey, getKeysByPattern} = require('../../utils/redis');
/**
 * 查看对应题目的学生的答题情况
 * @route GET /teacher/answers/:exerciseId
 */
router.get('/:exerciseId', async (req, res) => {
    try {
        //查看该习题是否为用户所发布的，如果不是则报错
        const excercise = await Excercise.findOne({
            where: {
                id: req.params.exerciseId,
                publisher: req.query.userId
            }
        });
        if (!excercise) {
            throw new BadRequestError(`您无权查看ID: ${req.params.exerciseId}的习题。`);
        } else {
            //查询该习题下的所有答题记录
            const answers = await Answer.findAll({
                attributes: ['id','student_id', 'answer', 'score', 'createdAt'],
                where: {
                    excercise_id: req.params.exerciseId
                },
                include: [
                    {
                        model: User,
                        attributes: ['uname']
                    }
                ]
            });
            const students = await TeacherAndStudent.findAll({
                attributes: ['student_id'],
                where: {
                    teacher_id: req.query.userId
                },
                include: [
                    {
                        model: User,
                        attributes: ['uname']
                    }
                ],
            });
            const result = [];
            for (let i = 0; i < students.length; i++) {
                const student = students[i];
                const answer = answers.find(answer => answer.student_id === student.student_id);
                if (answer) {
                    result.push({
                        answer_id: answer.id,
                        student_id: student.student_id,
                        publishName: answer.uname,
                        answer: answer.answer,
                        score: answer.score,
                        createdAt: answer.createdAt
                    });
                } else {
                    result.push({
                        answer_id: null,
                        student_id: student.student_id,
                        publishName: student.uname,
                        answer: null,
                        score: null,
                        createdAt: null
                    });
                }
            }
            success(res, '查询答题情况成功',{result})
        }


    } catch (error) {
        failure(res, error);
    }

});
module.exports = router;