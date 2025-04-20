const { createClient } = require('redis');

//创建全局的redis客户端
let client;

/**
 * 初始化redis客户端
 */
const redisClient = async () => {
  if(client) return;//如果已经初始化过了，就不再初始化

    client = await createClient({url: 'redis://127.0.0.1:6379'})
        .on('error', err => console.log('连接失败', err))
        .connect();
};

/**
 * 存入数组或对象，并可选地设置过期时间
 * @param  key 键名
 * @param  value 值
 * @param  ttl 过期时间，单位秒，默认为null, 表示不设置过期时间
 */
const setKey = async (key, value, ttl = null) => {
    if(!client) await redisClient();//确保客户端已经初始化
    value = JSON.stringify(value);//将对象转换为JSON字符串
    await client.set(key,value);

    //如果提供了ttl，则设置过期时间
    if(ttl !== null) {
        await client.expire(key, ttl);
    }
};

/**
 * 读取数组或对象
 * @param  key 键名
 * @returns {Promise<any>} 解析后的JSON对象
 */
const getKey = async (key) => {
    if(!client) await redisClient();//确保客户端已经初始化
    const value = await client.get(key);//将获取到的JSON字符串转换为对象
    return value? JSON.parse(value) : null;//如果value为空，则返回null而是抛出错误
};

/**
 * 清除缓存数据
 * @param  key 键名
 * @returns {Promise<void>}
 */
const delKey = async (key) => {
    if(!client) await redisClient();//确保客户端已经初始化
    await client.del(key);
};

/**
 * 获取匹配模式的所有键名
 * @param  pattern
 * @returns {Promise<*>}
 */
const getKeysByPattern = async (pattern) => {
    if(!client) await redisClient();//确保客户端已经初始化
    return await client.keys(pattern);
};
/**
 * 清空所有缓存数据
 * @returns {Promise<void>}
 */
const flushAll = async () => {
    if(!client) await redisClient();//确保客户端已经初始化
    await client.flushAll();
};

module.exports = {
    redisClient,
    setKey,
    getKey,
    delKey,
    getKeysByPattern,
    flushAll
};