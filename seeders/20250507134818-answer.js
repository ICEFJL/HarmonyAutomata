'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    return queryInterface.bulkInsert('Answers', [
      {
        answer: 'test1',
        excercise_id: '196',
        student_id: '281',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        answer: 'test1',
        excercise_id: '197',
        student_id: '281',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        answer: 'test1',
        excercise_id: '196',
        student_id: '283',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        answer: 'test1',
        excercise_id: '197',
        student_id: '283',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        answer: 'test1',
        excercise_id: '198',
        student_id: '281',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        answer: 'test1',
        excercise_id: '199',
        student_id: '283',
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});
  },

  async down (queryInterface, Sequelize) {
    /**
     * Add commands to revert seed here.
     *
     * Example:
     * await queryInterface.bulkDelete('People', null, {});
     */
  }
};
