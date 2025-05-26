const jwt = require('jsonwebtoken');
const { User } = require('../models');
const { UnauthorizedError, NotFoundError } = require('../utils/errors');
const { success,failure } = require('../utils/responses');

module.exports = async (req, res, next) => {
    try {
        //判断token是否存在
        const query = req.query;
        const { token } = query.userToken;
        if(!token){
            //throw new UnauthorizedError('当前接口需要认证才能访问。');
            console.log('token不存在',token)
        }
        //验证token是否正确
        const decoded = jwt.verify(token, process.env.SECRET);
        //从jwt中，解析出之前存入的userid
        const { id } = decoded;
        //如果通过验证，将userid挂载到req上，便于后续使用
        req.userId = id;
        //继续执行后续的请求处理程序
        next();
    }catch (error) {
        failure(res, error);
    }
};