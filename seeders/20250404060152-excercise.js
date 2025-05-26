'use strict';
const bcrypt = require('bcryptjs');
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const excercises =[];
    const counts = 10;
    for (let i = 0; i < counts; i++) {
      const excercise = {
        title:`250 标题 ${i}`,
        content: '1',
        image_url: `https://picsum.photos/id/${i}/200/300`,
        publisher: '272',
        answer: '1',
        type: '正则表达式',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      excercises.push(excercise);
    }
    for (let i = 0; i < counts; i++) {
      const excercise = {
        title:`251 标题 ${i}`,
        content: '1',
        image_url: `https://picsum.photos/id/${i}/200/300`,
        publisher: '272',
        answer: '1',
        type: '有限自动机',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      excercises.push(excercise);
    }
    await queryInterface.bulkInsert('excercises', excercises, {});
  },

  async down (queryInterface, Sequelize) {
  }
};
