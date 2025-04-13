const express = require('express');
const  router = express.Router();
const { User } = require('../../models');
const { Op}  = require('sequelize');
const { BadRequestError, NotFoundError,UnauthorizedError } = require('../../utils/errors');
const { success, failure } = require('../../utils/responses');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

/**
 * 用户注册
 * POST /api/auth/sign_up
 */
router.post('/sign_up', async (req, res, next) => {
  try {
    const body = {
        uname: req.body.uname,
        upassword: req.body.upassword
    };

    const user = await User.create(body);
    //去除返回数据中的加密后密码
    delete user.dataValues.upassword;
    success(res, '注册成功。', {user}, 201);
  }catch (error){
      failure(res, error);
  }
});
/**
 * 用户登录
 * POST /auth/sign_in
 */
router.post('/sign_in', async (req, res, next) => {
    try{
        const { login, upassword } = req.body;
        if(!login){
            throw new BadRequestError('用户名不能为空。');
        }
        if(!upassword){
            throw new BadRequestError('密码不能为空。');
        }
        const condition = {
            where:{
                [Op.or]: [
                    {id:login}
                ]
            }
        }
        //通过id查询用户是否存在
        const user = await User.findOne(condition);
        if(!user){
            throw new NotFoundError(`ID: ${login}的用户未找到`);
        }
        //验证密码
        const isPasswordValid = bcrypt.compareSync(upassword, user.upassword);
        if(!isPasswordValid){
            throw new UnauthorizedError('密码不正确。');
        }

        //生成token
        const token = jwt.sign({
            id: user.id
        }, process.env.SECRET, {expiresIn: '30d'});
        success(res, '登录成功。', {token})
    }catch (error){
        failure(res, error);
    }
});

module.exports = router;