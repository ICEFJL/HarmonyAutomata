'use strict';
const bcrypt = require('bcryptjs');
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const users =[];
    const counts = 1;
    for (let i = 0; i < counts; i++) {
      const user = {
        uname:`学生 ${i}`,
        upassword: bcrypt.hashSync(`student`,10),
        email:`${i}@student.com`,
        role:'student',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      users.push(user);
    }
    for (let i = 0; i < counts; i++) {
      const user = {
        uname:`教师 ${i}`,
        upassword: bcrypt.hashSync(`teacher`,10),
        email:`${i}@teacher.com`,
        role:'teacher',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      users.push(user);
    }
    const user = {
      uname:`admin`,
      upassword:bcrypt.hashSync(`admin`,10),
      role:'admin',
      email:'admin@admin.com',
      createdAt: new Date(),
      updatedAt: new Date()
    }
    users.push(user);
    await queryInterface.bulkInsert('users', users, {});
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.bulkDelete('users', users, {});
  }
};
