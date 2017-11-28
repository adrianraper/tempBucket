$(window).load(function() {
	if (thisMovie("bento"))
        thisMovie("bento").focus();
	
	// gh#182 - apparently jQuery is weird with beforeunload so bind directly.
	window.onbeforeunload = function() {
        if (thisMovie("bento")) {
            if (thisMovie("bento").isDirty()) {
                return thisMovie("bento").getDirtyMessage();
            }
            
            // TODO: #224 this should be removed and replaced with the new clean/dirty system at some point
            if (thisMovie("bento").isExerciseDirty()) {
                return "If you close this window now you may lose data you are working on and will need to start again.";
            }
        }
	};
	
	// #295
	log = function(message) {
		console.log(message);
	};
	
	// #255
	// issues: 
	//	 IE8 on Win XP. 
	//		Centering not correct. If I resize window and make it smaller than screen
	//		then when I maximise it stays left. Kind of ok. If I then restore down it
	//		I can end up with it a bit off right. The moment I resize it is immediately fine.
	onResize = function() {
		// Resize the flash object within the minima and maxima
		var width = $(window).width();
		var height = $(window).height();
		
		if (jsCoordsMinWidth) width = Math.max(width, jsCoordsMinWidth);
		if (jsCoordsMaxWidth) width = Math.min(width, jsCoordsMaxWidth);
		
		if (jsCoordsMinHeight) height = Math.max(height, jsCoordsMinHeight);
		if (jsCoordsMaxHeight) height = Math.min(height, jsCoordsMaxHeight);
		
		// Deal with the scrollbars in a cross-browser friendly way
		if (!$.browser.mozilla) {
			$("html").css("overflow-x", (width < $(window).width()) ? "hidden" : "auto");
			$("html").css("overflow-y", (height < $(window).height()) ? "hidden" : "auto");
		}
		
		// Size the flash object
		$("#bento").width(width).height(height);
		
		// Center the flash object
		$("#bento").css("left", Math.max(0, ($(window).width() - width) / 2))
				   .css("top", Math.max(0, ($(window).height() - height) / 2));
	};
	
	$(window).on("resize", onResize);
	onResize();
});