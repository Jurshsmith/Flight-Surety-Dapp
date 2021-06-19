const { watch } = require('gulp');
const run = require('gulp-run');


module.exports = function () {
  watch('contracts/**/*.sol', { delay: 500 }, () => {
    run('echo Restarting...').exec();
    process.exit();
  });
};