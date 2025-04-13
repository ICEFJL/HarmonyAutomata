'use strict';

const bcrypt = require("bcryptjs");
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const teacherandstudents =[];
    const counts = 1;
    for (let i = 0; i < counts; i++) {
      const teacherandstudent = {
        teacher_id: `200`,
        student_id: `199`,
        createdAt: new Date(),
        updatedAt: new Date()
      };
      teacherandstudents.push(teacherandstudent);
    }

    await queryInterface.bulkInsert('teacherandstudents', teacherandstudents, {});
  },

  async down (queryInterface, Sequelize) {

  }
};
