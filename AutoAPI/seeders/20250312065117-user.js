'use strict';
const bcrypt = require('bcryptjs');
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const users =[];
    const counts = 10;
    for (let i = 0; i < counts; i++) {
      const user = {
        uname:`用户名 ${i}`,
        upassword: bcrypt.hashSync(`123123`,10),
        createdAt: new Date(),
        updatedAt: new Date()
      };
      users.push(user);
    }
    const user = {
      uname:`admin`,
      upassword:bcrypt.hashSync(`admin`,10),
      role:'admin',
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
