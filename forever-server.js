 var forever = require('forever-monitor');

 var child = new(forever.Monitor)('server.js', {
    'silent': false,
    'pidFile': '../pids/app.pid',
    'sourceDir': '.',
    'watch': true,
    'watchDirectory': '.',
    'watchIgnoreDotFiles': null,
    'watchIgnorePatterns': null
});
child.start();