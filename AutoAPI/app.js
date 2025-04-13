const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const admin_auth = require('./middlewares/admin_auth');
const student_auth = require('./middlewares/student_auth');
const teacher_auth = require('./middlewares/teacher_auth');
const cors = require('cors');
require('dotenv').config();

const indexRouter = require('./routes/index');
//学生端路由
const studentAuthRouter = require('./routes/student/auth');
const studentUsersRouter = require('./routes/student/users');
const studentExcercisesRouter = require('./routes/student/excercises');
const studentAnswersRouter = require('./routes/student/answers');
//教师端路由
const teacherAuthRouter = require('./routes/teacher/auth');
const teacherUsersRouter = require('./routes/teacher/users');
const teacherExcercisesRouter = require('./routes/teacher/excercises');
const teacherAnswersRouter = require('./routes/teacher/answers');
//后台路由
const adminUsersRouter = require('./routes/admin/users');
const adminAuthRouter = require('./routes/admin/auth');
const adminExcercisesRouter = require('./routes/admin/excercises');
const adminAnswersRouter = require('./routes/admin/answers');

const app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

//CORS解决跨域问题
app.use(cors());

app.use('/', indexRouter);
//学生端路由配置
app.use('/student/auth', studentAuthRouter);
app.use('/student/users',student_auth, studentUsersRouter);
app.use('/student/excercises',student_auth, studentExcercisesRouter);
app.use('/student/answers',student_auth, studentAnswersRouter);
//教师端路由配置
app.use('/teacher/auth', teacherAuthRouter);
app.use('/teacher/users', teacher_auth,teacherUsersRouter);
app.use('/teacher/excercises', teacher_auth,teacherExcercisesRouter);
app.use('/teacher/answers', teacher_auth,teacherAnswersRouter);
//后台路由配置
app.use('/admin/auth', adminAuthRouter);
app.use('/admin/users', admin_auth,adminUsersRouter);
app.use('/admin/excercises',admin_auth,adminExcercisesRouter);
app.use('/admin/answers',admin_auth,adminAnswersRouter);


module.exports = app;
