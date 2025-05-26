const express = require('express');
const router = express.Router();
const {User, Excercise} = require('../../models');
const {Op} = require('sequelize');
const {
    success,
    failure,
} = require('../../utils/responses');
const {NotFoundError} = require('../../utils/errors');
const { redisClient,setKey, getKey,delKey, getKeysByPattern} = require('../../utils/redis');


/**
 * 查询用户列表（模糊查询）
 * GET users listing.
 */
router.get('/', async function (req, res, next) {
    try {
        const query = req.query;
        //当前是第几页，如果不传，默认第一页
        const currentPage = Math.abs(Number(query.currentPage)) || 1;
        const pageSize = Math.abs(Number(query.pageSize)) || 10;
        //计算offset
        const offset = (currentPage - 1) * pageSize;

        //定义带有[当前页码]和[每页条数]的cacheKey作为缓存的键
        const cacheKey = `users:${currentPage}:${pageSize}`;
        //读取缓存中的数据
        let data = await getKey(cacheKey);
        if(data) {
            return success(res, '查询用户列表成功。', data)
        }

        const condition = {
            limit: pageSize,
            offset: offset
        };
        if (query.uname) {
            condition.where = {
                uname: {
                    [Op.like]: `%${query.uname}%`
                }
            }
        }
        const {count, rows} = await User.findAndCountAll(condition);
        data = {
            excercises:rows,
            pagination: {
                total: count,
                currentPage,
                pageSize,
                totalPage: Math.ceil(count / pageSize)
            }
        }
        await setKey(cacheKey, data);
        success(res, '查询用户列表成功。', {
            users: rows,
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
 * 查询单个用户详情
 * get /admin/users/:id
 */
router.get('/:id', async function (req, res, next) {
    try {
        const {id} = req.params;
        let user = await getKey(`user:${id}`);
        if(!user){
            user = await Excercise.findByPk(id);
            if (!user) {
                throw new NotFoundError(`ID: ${id}的用户未找到`);
            }
            await setKey(`user:${id}`, user);
        }
        success(res, '查询用户详情成功。', user);
        // const user = await getUser(req);
        // success(res, '查询用户详情成功。', {user});
    } catch (error) {
        failure(res, error);
    }
})
/**
 * 添加用户
 * posy /admin/users
 */
router.post('/', async function (req, res, next) {
    try {
        const body = filterBody(req);
        const user = await User.create(body);
        await clearCache();
        success(res, '添加用户成功。', {user}, 201);
    } catch (error) {
        failure(res, error);
    }
})
/**
 * 删除用户
 * delete /admin/users/:id
 */
router.delete('/:id', async function (req, res, next) {
    try {
        const user = await getUser(req)
        await user.destroy();
        await clearCache(user.id);
        success(res, '删除用户成功。')
    } catch (error) {
        failure(res, error);
    }
})
/**
 * 修改用户
 * put /admin/users/:id
 */
router.put('/:id', async function (req, res, next) {
    try {
        const user = await getUser(req);
        const body = filterBody(req);

        await user.update(body);
        await clearCache(user.id);
        success(res, '修改用户信息成功。', {user});
    } catch (error) {
        failure(res, error);
    }
})
//白名单过滤
function filterBody(req) {
    return {
        uname: req.body.uname,
        upassword: req.body.upassword,
        role: req.body.role
    }
}

/**
 * 公共方法：查询当前用户
 */
async function getUser(req) {
    //获取用户id
    const {id} = req.params;
    //查询用户
    const user = await User.findByPk(id);
    //如果没有找到，抛出异常
    if (!user) {
        throw new NotFoundError(`ID: ${id}的用户未找到`);
    }
    return user;
}
/**
 * 清除缓存
 */
async function clearCache(id = null) {
    const keys = await getKeysByPattern('users:*');
    if(keys.length !== 0) {
        await delKey(keys);
    }
    if(id) {
        const keys = await getKeysByPattern(`user:${id}`);
        await delKey(keys);
    }
}
module.exports = router;