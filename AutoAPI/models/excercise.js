'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Excercise extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
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