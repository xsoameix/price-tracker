require! <[gulp]>
gutil = require \gulp-util
livescript = require \gulp-livescript

gulp.task 'build:server' ->
  gulp.src ['server/*.ls' 'server/**/*.ls']
    .pipe (livescript {+bare}).on 'error', gutil.log
    .pipe gulp.dest 'server'
