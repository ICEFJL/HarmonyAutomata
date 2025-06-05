'use strict';

const Sequelize = require('sequelize');
const process = require('process');
const env = process.env.NODE_ENV || 'development';

// 关键修改1：使用静态路径加载配置文件
const config = require('../config/config.json')[env];

const db = {};

let sequelize;
if (config.use_env_variable) {
  sequelize = new Sequelize(process.env[config.use_env_variable], config);
} else {
  sequelize = new Sequelize(config.database, config.username, config.password, config);
}

// 关键修改2：手动导入所有模型（静态方式）
db.User = require('./User')(sequelize, Sequelize.DataTypes);
db.Answer = require('./answer')(sequelize, Sequelize.DataTypes);
db.TeacherAndStudent = require('./teacherAndStudent')(sequelize, Sequelize.DataTypes);
db.Excercise = require('./excercise')(sequelize, Sequelize.DataTypes);
// 继续添加其他模型...

// 模型关联
Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;