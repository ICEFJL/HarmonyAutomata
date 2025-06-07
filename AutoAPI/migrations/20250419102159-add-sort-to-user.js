'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.addColumn('users', 'email_address', {
      type: Sequelize.STRING,
      unique: true,
      allowNull: false
  })
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.removeColumn('users', 'email')
  }
};
