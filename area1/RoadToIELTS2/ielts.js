$(window).load(function() {
	thisMovie("bento").focus();

	
	// #224. Extend so that we check isDirty from bento - only ask if this is true.  jQuery is weird with beforeunload so bind directly.
	window.onbeforeunload = function() {
		if (thisMovie("bento").isExerciseDirty())
			return "If you navigate away from this window during a session you may lose data you are working on and will need to log in again.";
	}
	
	// #255
	onResize = function() {
		// Resize the flash object within the minima and maxima
		var width = $(window).width();
		var height = $(window).height();
		
		if (coordsMinWidth) width = Math.max(width, coordsMinWidth);
		if (coordsMaxWidth) width = Math.min(width, coordsMaxWidth);
		
		if (coordsMinHeight) height = Math.max(height, coordsMinHeight);
		if (coordsMaxHeight) height = Math.min(height, coordsMaxHeight);
		
		// Deal with the scrollbars in a cross-browser friendly way
		if (!$.browser.mozilla) {
			if (width < $(window).width() || height < $(window).height()) {
				$("html").css("overflow", "hidden");
			} else {
				$("html").css("overflow", "auto");
			}
		}
		
		// Size the flash object
		$("#bento").width(width).height(height);
		
		// Center the flash object
		$("#bento").css("left", Math.max(0, ($(window).width() - width) / 2))
				   .css("top", Math.max(0, ($(window).height() - height) / 2));
	}
	
	$(window).on("resize", onResize);
	onResize();
});