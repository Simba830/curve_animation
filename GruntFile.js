module.exports = function(grunt) {
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		concat: {
			options: {

			},
			dist: {
				src: ['src/*.pde', 'src/*/*.pde'],
				dest: 'web-export/curveAnimation.pde'
			}
		}
	});

	grunt.loadNpmTasks('grunt-contrib-concat');
	grunt.registerTask('default', ['concat']);
}