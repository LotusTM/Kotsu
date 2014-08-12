module.exports = function (grunt) {
	'use strict';

	// Load grunt tasks automatically
	require('load-grunt-tasks')(grunt);

	// Define the configuration for all the tasks
	grunt.initConfig({

		pkg: grunt.file.readJSON('package.json'),

		// Specify your app and build directory structure
		path: {
			app: {
				root: '.',
					sass:    '<%= path.app.root %>/sass',
					sprites: '<%= path.app.root %>/sprites'
					// templates: '<%= path.app.root %>/templates'
			},
			build: {
				root: 'www',
					assets:    '<%= path.build.root %>/assets',
					css:       '<%= path.build.root %>/css',
					js:        '<%= path.build.root %>/js'
					// templates: '<%= path.build.root %>/templates'
			}
		},

		// Specify css files
		css: {
			app: {
				style: '<%= path.app.sass %>/style.scss'
			},
			build: {
				style: {
					compiled: '<%= path.build.css %>/style.compiled.css',
					prefixed: '<%= path.build.css %>/style.prefixed.css',
					tidy:     '<%= path.build.css %>/style.tidy.css',
					min:      '<%= path.build.css %>/style.min.css'
				}
			}
		},

		/**
		 * Spritesmith
		 * https://github.com/Ensighten/grunt-spritesmith
		 * Generates sprites and scss from set of images
		 */
		'sprite': {
			'all': {
				'src': ['<%= path.app.sprites %>/*.png'],
				'destImg': '<%= path.build.assets %>/images/sprites.png',
				'destCSS': '<%= path.app.sass %>/generic/_sprites.map.scss',
				'padding': 2,
				'engine': 'pngsmith',
				'algorithm': 'binary-tree',
				'cssTemplate': '<%= path.app.sass %>/generic/_sprites.map.mustache',
				'cssVarMap': function (sprite) {
					// `sprite` has `name`, `image` (full path), `x`, `y`
					// `width`, `height`, `total_width`, `total_height`
					sprite.name = 'sprite--' + sprite.name;
				},
				// OPTIONAL: settings for algorithm
				// 'algorithmOpts': {
				// 	Skip sorting of images for algorithm (useful for sprite animations)
				// 	'sort': false
				// },
			}
		},

		/**
		 * Autoprefixer
		 * https://github.com/nDmitry/grunt-autoprefixer
		 * Auto prefixes CSS using caniuse data
		 */
		autoprefixer: {
			build: {
				options: {
					browsers: ['last 2 versions', '> 1%']
				},
				files: {
					'<%= css.build.style.prefixed %>': '<%= css.build.style.compiled %>'
				}
			}
		},

		/**
		 * CSSO
		 * https://github.com/t32k/grunt-csso
		 * Minify CSS files with CSSO
		 */
		csso: {
			build: {
				files: {
					'<%= css.build.style.min %>': '<%= css.build.style.prefixed %>'
				}
			}
		},

		uncss: {
			dist: {
				files: {
					'<%= css.build.style.tidy %>': ['<%= path.build.root %>/*.html']
				}
			}
		},

		/**
		 * Browser Sync
		 * https://github.com/shakyshane/grunt-browser-sync
		 * Keep multiple browsers & devices in sync
		 */
		browserSync: {
			options: {
				open: true,
				notify: true,
				watchTask: true,
				debugInfo: true,
				ghostMode: {
					clicks: true,
					links: true,
					forms: true,
					scroll: true
				},
				server: {
					baseDir: '<%= path.build.root %>'
				}
			},
			files: {
				src: [
					// '<%= path.build.templates %>/*',
					'<%= path.build.root %>/*',
					'<%= path.build.css %>/*',
					'<%= path.build.js %>/*'
				]
			}
		},


		/**
		 * contrib-sass
		 * https://github.com/gruntjs/grunt-contrib-sass
		 * Compiles SASS with Ruby gem
		 */
		sass: {
			dist: {
				options: {
					style: 'nested',
					sourcemap: true
				},
				files: {
					'<%= css.build.style.compiled %>': '<%= css.app.style %>'
				}
			}
		},

		/**
		 * Watch
		 * https://github.com/gruntjs/grunt-contrib-watch
		 * Watches scss, js etc for changes and compiles them
		 */
		watch: {
			scss: {
				files: ['<%= path.app.sass %>/**/*.scss'],
				tasks: ['sass', 'autoprefixer']
			},
			sprite: {
				files: ['sprites/*.png'],
				tasks: ['sprite']
			},
		}

	});

	/**
	 * Default task
	 */
	grunt.registerTask('default', ['sprite', 'sass', 'autoprefixer', 'browserSync', 'watch']);

	/**
	 * A task for your production environment
	 * run jshint, uglify and sass
	 */
	grunt.registerTask('production', ['sprite', 'sass', 'autoprefixer', 'csso', 'uncss']);

	/**
	 * A task for for a static server with a watch
	 * run connect and watch
	 */
	grunt.registerTask('serve', ['browserSync', 'watch']);

};