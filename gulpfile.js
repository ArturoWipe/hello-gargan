'use strict';

var gulp = require('gulp');
var sass = require('gulp-dart-sass');
var header = require('gulp-header');
var footer = require('gulp-footer');
var foreach = require('gulp-foreach');
var del = require('del');
var path = require('path');
var replace = require('gulp-replace');
var sourcemaps = require('gulp-sourcemaps');

var ROOT    = __dirname;
var BUILD   = '.build';
var SOURCE  = 'src';
var DIST    = 'dist';

var main       = SOURCE + '/assets/sass/main/main.scss';
var bootstrap  = SOURCE + '/assets/sass/bootstrap/bootstrap.scss';
var components = SOURCE + '/components'
var pages      = SOURCE + '/pages';
var layouts    = SOURCE + '/layouts';
var abstract   = SOURCE + '/assets/sass/main/_abstract';
var glob       = '/**/*.{sass,scss}';

gulp.task('cleanBuild', cleanBuild);
gulp.task('copySource', copySource);
gulp.task('forwardStyles', forwardStyles);
gulp.task('injectAbstract', injectAbstract);
gulp.task('replacePaths', replacePaths);
gulp.task('compileMain', compileMain);
gulp.task('compileBootstrap', compileBootstrap);

gulp.task('styles-basic', gulp.series(
  'cleanBuild',
  'copySource',
  'forwardStyles',
  'injectAbstract',
  'replacePaths',
  'compileMain',
));

// (?) Create separate task to run it once in a while
//     Main reason is due to the amount of warning regarding SASS and Bootstrap
//     and the lack of "silent warnings flag"
//    (eg. [1])
//
//  @link https://github.com/twbs/bootstrap/issues/34051 [1]
gulp.task('styles-complete', gulp.series(
  'cleanBuild',
  'copySource',
  'forwardStyles',
  'injectAbstract',
  'replacePaths',
  'compileMain',
  'compileBootstrap'
))

function cleanBuild() {
  return del(path.join(BUILD));
}

function copySource() {
  return gulp.src(path.join(SOURCE, glob))
    .pipe(gulp.dest(path.join(BUILD, SOURCE)));
}

function forwardStyles() {
  return gulp.src([
      path.join(BUILD, components + glob),
      path.join(BUILD, pages + glob),
      path.join(BUILD, layouts + glob)
    ])
    .pipe(foreach(function(stream, file) {
      return gulp.src(path.join(BUILD, main))
        .pipe(footer('@forward "' + file.path + '";\n'))
        // @XXX: Gulp "src/dest" not suitable for targeting single file
        .pipe(gulp.dest(path.join(BUILD, main + '/../')));
    }));
}

// @XXX: Gulp unable to handle "src: `n ^ paths` input => dest: `n ^ paths` output"
function injectAbstract() {
    // components
  return gulp.src(path.join(BUILD, components + '/**/*.scss'))
    .pipe(header('@use "~' + abstract + '" as *;\n'))
    .pipe(gulp.dest(path.join(BUILD, components)))
    .pipe(gulp.src(path.join(BUILD, components + '/**/*.sass')))
    .pipe(header('@use "~' + abstract + '" as *\n'))
    .pipe(gulp.dest(path.join(BUILD, components)))
    // pages
    .pipe(gulp.src(path.join(BUILD, pages + '/**/*.scss')))
    .pipe(header('@use "~' + abstract + '" as *;\n'))
    .pipe(gulp.dest(path.join(BUILD, pages)))
    .pipe(gulp.src(path.join(BUILD, pages + '/**/*.sass')))
    .pipe(header('@use "~' + abstract + '" as *\n'))
    .pipe(gulp.dest(path.join(BUILD, pages)))
    // layouts
    .pipe(gulp.src(path.join(BUILD, layouts + '/**/*.scss')))
    .pipe(header('@use "~' + abstract + '" as *;\n'))
    .pipe(gulp.dest(path.join(BUILD, layouts)))
    .pipe(gulp.src(path.join(BUILD, layouts + '/**/*.sass')))
    .pipe(header('@use "~' + abstract + '" as *\n'))
    .pipe(gulp.dest(path.join(BUILD, layouts)))
}

function replacePaths() {
  var _injectPath = function(s) {
    return s
      .replace(/~$/, ROOT + '/' + BUILD + '/')
      .replace(/@$/, ROOT + '/');
  }

  return gulp.src(path.join(BUILD, '**/*.{sass,scss}'))
    .pipe(replace(
      /^@(import|use|forward)( )*(\'|\")(~|@)/gm,
      _injectPath
    ))
    .pipe(replace(
      /^@include( )*(meta\.)?load\-css( )*\((\'|\")(~|@)/gm,
      _injectPath
    ))
    .pipe(gulp.dest(path.join(BUILD)));
}

function compileMain() {
  return gulp.src(path.join(BUILD, main))
    .pipe(sourcemaps.init())
    // @XXX: Bootstrap still not compliant with lastest SASS API
    //       Commenting the error log due to the amount of warning regarding
    //       deprecation (mostly towarding the use of `/` division symbol)
    .pipe(sass().on('error', sass.logError))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(path.join(DIST, 'styles')));
}

function compileBootstrap() {
  return gulp.src(path.join(BUILD, bootstrap))
    .pipe(sourcemaps.init())
    // @XXX: Bootstrap triggers a lot of warning with latest SASS release
    .pipe(sass().on('error', sass.logError))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(path.join(DIST, 'styles')));
}
