var processing;

function init(){
	$.get("curveAnimation.pde", function(code) {
		processing = new Processing( $("#canvas")[0], code);
	});
}

$(function(){
	init();
	var divInterface = $("#interface");
	var canvas = $("#curveAnimation");
});

$(".menu-control").click(function(){
	$(this).siblings( "button" ).slideToggle();
});