/* Demo verison popup frame */ 
$(document).ready(function() { 
						   
	
						   
	$("a#choose_contact").fancybox({
				'width'				: 310,
				'height'			: 290,
				'autoScale'			: false,
				'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'scrolling'			: 'no',
				'type'				: 'iframe'
			});
	
		$("a.popup_iframe").fancybox({
				'width'				: 740,
				'height'			: 370,
				'autoScale'			: false,
				'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'scrolling'			: 'no',
				'type'				: 'iframe'
			});
		
		
		$("a.demopop_iframe").fancybox({
				'width'				: 380,
				'height'			: 280,
				'autoScale'			: false,
				'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'scrolling'			: 'no',
				'type'				: 'iframe'
			});
		
		

	
	

});