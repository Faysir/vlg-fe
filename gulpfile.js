/**
 * Created by cosmo on 16-10-4.
 */

require('coffee-script/register');
require('./gulpfile.coffee');
/*
//引入webserver插件
var webserver = require('gulp-webserver'); 
var gulp = require('gulp');

gulp.task('webserver', function(){
gulp.src('./www/')
.pipe(webserver({
port: 8088,//端口
host: 'localhost',//域名
liveload: true,//实时刷新代码。不用f5刷新
directoryListing: {
path: './www/',
enable: true,
open: true,
fallback: 'index.html'
}
}))
});*/