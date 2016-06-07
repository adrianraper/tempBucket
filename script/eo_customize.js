// English online: JavaScript Document

// Content panel hide / show
 $(document).ready(function() {
	$('.module .article').hide();
	
	$('.module-content-arrow').click(function() {
		var article = $(this).parent().parent().parent().children('.article');
		$('.module .article').not(article).slideUp();
		article.slideToggle('slow');
		
		$(this).toggleClass("module-arrow-up"); 
		
		
	});
	
	
	
});
