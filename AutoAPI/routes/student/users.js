const express = require('express');
const router = express.Router();
const { User } = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');


/**
 * 查询当前登录用户详情
 * @route GET /users/me
 */
router.get('/me', async (req, res) => {
  try {
      const user = await getUser(req);
      success(res, '查询用户详情成功。', {user})
  }catch (error) {
    failure(res, error);
  }
});
/**
 * 修改当前登录用户密码
 * @route PUT /users/account
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
 * 公共方法:查询当前用户
 */
async function getUser(req,showPassword=false) {
  const id = req.userId;
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

module.exports = router;

