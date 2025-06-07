const jwt = require('jsonwebtoken');
const { User } = require('../models');
const { UnauthorizedError, NotFoundError } = require('../utils/errors');
const { success,failure } = require('../utils/responses');

module.exports = async (req, res, next) => {
    try {
        //判断token是否存在
        const { token } = req.headers;
        if(!token){
            throw new UnauthorizedError('当前接口需要认证才能访问。');
        }
        //验证token是否正确
        const decoded = jwt.verify(token, process.env.SECRET);
        //从jwt中，解析出之前存入的userid
        const { id } = decoded;
        //查询一下当前用户
        const user = await User.findByPk(id);
        if(!user){
            throw new NotFoundError(`ID: ${id}的用户未找到`);
        }
        //验证当前用户是否为教师
        if(user.role !== 'teacher'){
            throw new UnauthorizedError('当前接口需要教师权限才能访问。');
        }
        //如果通过验证，将user对象挂载到req上，便于后续使用
        req.userId = id;
        //继续执行后续的请求处理程序
        next();
    }catch (error) {
        failure(res, error);
    }
};