'use strict';

module.exports = function(grunt) {

  //--------------------------------------------------------------------------
  // SETUP CONFIG
  //--------------------------------------------------------------------------
  var testOpts = {execOptions: {maxBuffer: 20 * 1024 * 1024}};
  var testCommand = 'node_modules/bats/libexec/bats ${CI:+--tap}';

  // Setup task config
  var config = {

    shell: {
      install: {
        options: testOpts,
        command: testCommand + ' ./test/install.bats'
      },
      apidev: {
        options: testOpts,
        command: testCommand + ' ./test/apidev.bats'
      },
      apiprod: {
        options: testOpts,
        command: testCommand + ' ./test/apiprod.bats'
      },
      appdev: {
        options: testOpts,
        command: testCommand + ' ./test/appdev.bats'
      },
      appprod: {
        options: testOpts,
        command: testCommand + ' ./test/appprod.bats'
      }
    }

  };

  //--------------------------------------------------------------------------
  // LOAD TASKS
  //--------------------------------------------------------------------------

  // load task config
  grunt.initConfig(config);

  // load external tasks
  //grunt.loadTasks('tasks');

  // load grunt-* tasks from package.json dependencies
  require('matchdep').filterAll('grunt-*').forEach(grunt.loadNpmTasks);

  //--------------------------------------------------------------------------
  // SETUP WORKFLOWS
  //--------------------------------------------------------------------------

  /*
   * Tests
   */
  grunt.registerTask('test:install', [
    'shell:install'
  ]);
  grunt.registerTask('test:apidev', [
    'shell:apidev'
  ]);
  grunt.registerTask('test:apiprod', [
    'shell:apiprod'
  ]);
  grunt.registerTask('test:appdev', [
    'shell:appdev'
  ]);
  grunt.registerTask('test:appprod', [
    'shell:appprod'
  ]);
  grunt.registerTask('test', [
    'shell:install',
    'shell:apidev',
    'shell:apiprod',
    'shell:appdev',
    'shell:appprod'
  ]);

};
