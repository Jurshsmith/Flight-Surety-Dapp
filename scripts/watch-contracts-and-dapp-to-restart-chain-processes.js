const { watch, task } = require('gulp');
const run = require('gulp-run');


module.exports = function () {
  task("watchContractsForDapp", () => {
    watch('contracts/**/*.sol', { delay: 500 }, () => {
      run('echo Restarting...').exec();
      process.exit();
    });
  });
};