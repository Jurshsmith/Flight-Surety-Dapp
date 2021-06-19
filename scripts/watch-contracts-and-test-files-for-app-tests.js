const { watch, task, series } = require("gulp");
const run = require('gulp-run');

module.exports = function () {
  task(
    "watchContractsAndTestFilesForAppTests",
    series(() => run("npm run test:contracts:app", { verbosity: 3 }).exec(), () => {
      watch(["contracts/**/*.sol", "tests/**/*.js"], { delay: 500 }, async (done) => {
        await run("npm run test:contracts:app", { verbosity: 3 }).exec();
        done();
      });
    })
  );
};

