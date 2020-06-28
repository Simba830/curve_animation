let processing;

function init(){
	$.get("curveAnimation.pde", function(code) {
		processing = new Processing( $("#canvas")[0], code);
	});

	$("#main-interface").css({ left: -$("#main-interface").outerWidth()});
	$("#element-interface").css({ right: -$("#element-interface").outerWidth()});

	$("#canvas").click(function(){

	});
}

$(function(){
	init();
	let canvas = $("#curveAnimation");
	let divInterface = $("#interface");
});

$(".menu-control").click(function(){
	$(this).siblings( "button" ).slideToggle();
});