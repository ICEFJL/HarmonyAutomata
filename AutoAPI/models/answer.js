'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  const Answer = sequelize.define('Answer', {
    answer: DataTypes.TEXT,
    excercise_id: DataTypes.STRING,
    student_id: DataTypes.STRING,
    score: DataTypes.STRING
  });
  Answer.associate = (models) => {
    Answer.belongsTo(models.User,{foreignKey: 'student_id'})
  };
  Answer.init({
    answer: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    excercise_id: {
      type: DataTypes.STRING,
      allowNull: false
    },
    student_id: {
      type: DataTypes.STRING,
      allowNull: false
    },
    score: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Answer',
  });
  return Answer;
};