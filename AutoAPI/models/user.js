'use strict';
const {
  Model
} = require('sequelize');
const bcrypt = require('bcryptjs');
module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.STRING,
      primaryKey: true,
      autoIncrement: true
    },
    uname: DataTypes.STRING,
    upassword: DataTypes.STRING,
    role: DataTypes.STRING
  });
  User.associate = (models) => {
    User.hasMany(models.Answer, {foreignKey: 'student_id'});
    User.hasMany(models.TeacherAndStudent, {foreignKey: 'teacher_id'});
    User.hasMany(models.Excercise, {foreignKey: 'publisher'});
  };
  User.init({
    uname: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    upassword: {
      type: DataTypes.STRING,
      allowNull: false,
      set(value){
        if(value.length >= 6 && value.length <= 45){
          this.setDataValue('upassword',bcrypt.hashSync(value,10));
        }else{
          throw new Error('密码长度必须在6-45之间');
        }
      }
    },
    role: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'User',
  });
  return User;
};
