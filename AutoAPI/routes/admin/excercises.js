const express = require('express');
const router = express.Router();
const { Excercise, User} = require('../../models');
const { success, failure } = require('../../utils/responses');
const { BadRequestError, NotFoundError } = require('../../utils/errors');
const bcrypt = require('bcryptjs');
const { redisClient,setKey, getKey,delKey, getKeysByPattern} = require('../../utils/redis');

/**
 * 查询习题列表
 * GET Excercises listing.
 * get /admin/excercises
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
        const cacheKey = `excercises:${currentPage}:${pageSize}`;
        //读取缓存中的数据
        let data = await getKey(cacheKey);
        if(data) {
            return success(res, '查询习题列表成功。', data)
        }


        const condition = {
            limit: pageSize,
            offset: offset
        };
        condition.include = [{
            model: User,
            as: 'ex',
            attributes: ['uname']
        }];

        const {count, rows} = await Excercise.findAndCountAll(condition);
        data = {
            excercises: rows.map(excercise => ({
            id: excercise.id,
            title: excercise.title,
            type: excercise.type,
            publishTime: excercise.createdAt,
            publisher: excercise.publisher,
            publisherName: excercise.ex.uname
            })),
            pagination: {
                total: count,
                currentPage,
                pageSize,
                totalPage: Math.ceil(count / pageSize)
            }
        }
        await setKey(cacheKey, data);

        // if (query.title) {
        //     condition.where = {
        //         title: {
        //             [Op.like]: `%${query.title}%`
        //         }
        //     }
        // }

        success(res, '查询习题列表成功。', data);
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
        const {id} = req.params;
        let excercise = await getKey(`excercise:${id}`);
        if(!excercise){
            excercise = await Excercise.findByPk(id);
            if (!excercise) {
                throw new NotFoundError(`ID: ${id}的习题未找到`);
            }
            await setKey(`excercise:${id}`, excercise);
        }
        success(res, '查询习题详情成功。', excercise);
    } catch (error) {
        failure(res, error);
    }
})
/**
 * 删除习题
 * delete /admin/excercises/:id
 */
router.delete('/:id', async function (req, res, next) {
    try {
        const excercise = await getExcercise(req);
        await excercise.destroy();
        await clearCache();
        success(res, '删除习题成功。')
    } catch (error) {
        failure(res, error);
    }
})

/**
 * 发布习题
 * post /admin/excercises/
 */
router.post('/', async function (req, res, next) {
    try {
        const body = filterBody(req);
        const excercise = await Excercise.create(body);
        await clearCache();
        success(res, '添加习题成功。', {excercise}, 201);
    } catch (error) {
        failure(res, error);
    }
})

/**
 * 公共方法：白名单过滤
 */
function filterBody(req) {
    return {
        title: req.body.title,
        content: req.body.content,
        image_url: req.body.image_url,
        type: req.body.type,
        publisher: req.body.publisher,
        answer: req.body.answer
    }
}

/**
 * 公共方法：查询当前习题
 */
async function getExcercise(req) {
    //获取习题id
    const { id } = req.params;
    //查询习题
    const excercise = await Excercise.findByPk(id);
    //如果没有找到，抛出异常
    if (!excercise) {
        throw new NotFoundError(`ID: ${id}的用户未找到`);
    }
    return excercise;
}


/**
 * 清除缓存
 */
async function clearCache(id = null) {
    const keys = await getKeysByPattern('excercises:*');
    if(keys.length !== 0) {
        await delKey(keys);
    }
    if(id) {
        const keys = await getKeysByPattern(`excercise:${id}`);
        await delKey(keys);
    }
}
module.exports = router;