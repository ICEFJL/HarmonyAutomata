'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  const TeacherAndStudent = sequelize.define('TeacherAndStudent', {
    teacher_id: DataTypes.STRING,
    student_id: DataTypes.STRING
  });
  TeacherAndStudent.associate = (models) => {
    TeacherAndStudent.belongsTo(models.User,{foreignKey: 'teacher_id'})
  };
  TeacherAndStudent.init({
    teacher_id: {
      type:DataTypes.STRING,
      allowNull: false
    },
    student_id: {
      type: DataTypes.STRING,
      allowNull: false
    }
  }, {
    sequelize,
    modelName: 'TeacherAndStudent',
  });
  return TeacherAndStudent;
};