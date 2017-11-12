module.exports = function (config) {
  'use strict';
  var saucelabsBrowsers = require('./browsers').browsers
  var browsers = ['PhantomJS']
  if (process.env.SAUCE_USERNAME) {
    browsers = Object.keys(saucelabsBrowsers)
  }

  config.set({
    basePath: '',
    frameworks: ['browserify','mocha', 'chai','sinon'],
    files: [
      './node_modules/simulant/dist/simulant.js',
      './test/*.coffee'
    ],
    preprocessors: {
      './test/*.coffee': [ 'browserify'],
      './lib/*.js': [ 'browserify']
    },
    "browserify": {
      "debug": true,
      "transform": ["browserify-istanbul"],
      extensions: ['.js', '.tag', '.coffee']
    },
    reporters: ['spec', "coverage",'saucelabs'],
    //hostname:'192.168.1.7',
    port: 9876,
    colors: true,
    autoWatch: true,
    singleRun: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,

    browsers: browsers,
    coverageReporter: {
      dir: 'coverage/',
      reporters: [{type:'lcov',subdir: 'report-lcov'},{type:'text-summary'}]
    },
    sauceLabs: {
      build: 'TRAVIS #' + process.env.TRAVIS_BUILD_NUMBER + ' (' + process.env.TRAVIS_BUILD_ID + ')',
      tunnelIdentifier: process.env.TRAVIS_JOB_NUMBER,
      testName: 'riot-routehandler',
      connectOptions: {
        port: 5757,
        logfile: 'sauce_connect.log'
      },
      startConnect: true,
      recordVideo: false,
      recordScreenshots: false,
    },
    captureTimeout: 120000,// Increase timeout in case connection in CI is slow
    customLaunchers: saucelabsBrowsers
  });
};