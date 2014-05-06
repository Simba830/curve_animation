module.exports = function(grunt) {
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		concat: {
			options: {

			},
			dist: {
				src: ['src/*.pde', 'src/**/*.pde'],
				dest: 'web-export/curveAnimation.pde'
			}
		},

		watch: {
			default: {
	          files: [
	            //watched files
	            'src/**/*.pde',
	            'src/*.pde',
	            'web-export/**/*.css',
	            'web-export/**/*.js'
	            ],   
	          tasks: ['concat'],     //tasks to run
	          options: {
	            livereload: true                        //reloads the browser
	          }
	        }
		}
	});

	grunt.loadNpmTasks('grunt-contrib-concat');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.registerTask('default', ['watch']);
}