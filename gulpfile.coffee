gulp = require('gulp')
gulp.sass = require('gulp-sass')
gulp.jade = require('gulp-jade')
gulp.coffee require('gulp-coffee')
gulp.concat = require('gulp-concat')

gulp.task('vendor:js', ->
  gulp.src(['bower_components/jquery/dist/jquery.min.js'
    'bower_components/jquery/dist/jquery.min.map'
    'bower_components/bootstrap/dist/js/bootstrap.min.js'
    'bower_components/angular/angular.min.js'
    'bower_components/angular/angular.min.js.map'
    'bower_components/angular-route/angular-route.min.js'
    'bower_components/angular-route/angular-route.min.map'
  ])
    .pipe(gulp.dest('www/vendor/scripts/'))
)

gulp.task('vendor:css', ->
  gulp.src(['bower_components/bootstrap/dist/css/bootstrap.min.css'
    'bower_components/bootstrap/dist/fonts/*'
  ])
  .pipe(gulp.dest('www/vendor/stylesheets/'))
)

gulp.task('vendor', ['vendor:css', 'vendor:js'])

gulp.task('sass', ->
  gulp.src(['src/stylesheets/style.sass'])
    .pipe(gulp.sass())
    .pipe(gulp.dest('www/vendor/stylesheets/'))
)

gulp.task('coffee', ->
  gulp.src(['src/scripts/app.coffee'
    'src/scripts/modules/**/*.coffee'
    'src/scripts/factories/**/*.coffee'
  ])
    .pipe(gulp.concat('app.coffee'))
    .pipe(gulp.coffee())
    .pipe(gulp.dest('www/vendor/scripts/'))
)

gulp.task('jade', ->
  gulp.src(['src/jade/index.jade'])
    .pipe(gulp.jade())
    .pipe(gulp.dest('www/'))
)

gulp.task('default', ['vendor', 'coffee', 'sass', 'jade'])

gulp.task('watch:sass', ->
  gulp.src(['src/scripts/**/*.coffee'])
)

