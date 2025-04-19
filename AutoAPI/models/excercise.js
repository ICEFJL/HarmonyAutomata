'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  const Excercise = sequelize.define('Excercise', {
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    image_url: DataTypes.STRING,
    publisher: DataTypes.STRING,
    answer: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    type: DataTypes.STRING
  });
  Excercise.associate = (models) => {
    Excercise.hasMany(models.Answer,{foreignKey: 'excercise_id'});
    Excercise.belongsTo(models.User, {as: 'ex',foreignKey: 'publisher', targetKey: 'id'})
  };
  Excercise.init({
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    image_url: DataTypes.STRING,
    publisher: DataTypes.STRING,
    answer: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    type: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Excercise',
  });
  return Excercise;
};