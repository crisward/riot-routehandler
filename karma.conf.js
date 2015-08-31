module.exports = function (config) {
  
  'use strict';
  config.set({
    basePath: '',
    frameworks: ['browserify','mocha', 'chai','sinon'],
    files: [
      './node_modules/simulant/dist/simulant.js',
      './test/*.coffee'
    ],
    preprocessors: {
      './test/*.coffee': [ 'browserify' ],
      './src/*.tag': [ 'browserify']
    },
    "browserify": {
      "debug": true,
      extensions: ['.js', '.tag', '.coffee']
    },
    reporters: ['spec', "coverage"],
    //hostname:'192.168.1.7',
    port: 9876,
    colors: true,
    autoWatch: true,
    singleRun: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_ERROR,

    browsers: ['PhantomJS']//,'Chrome']

  });
};