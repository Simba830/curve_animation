var processing;

function init(){
	$.get("curveAnimation.pde", function(code) {
		processing = new Processing( $("#canvas")[0], code);
		console.log();
	});
}

$(function(){
	init();
	var divInterface = $("#interface");
	var canvas = $("#curveAnimation");

	var canvasWidth = canvas.width();
	var canvasHeight = canvas.height();
});
