// JavaScript Document

$(document).ready(function() { 

						   
/* Demo verison popup frame */ 
$("a.demopop_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':382,
	'frameHeight':282

});

/* Screenshot popup frame */ 
$("a.screenshot_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':830,
	'frameHeight':600


});

/* Contact us popup frame */ 
$("a.contentpop_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':565,
	'frameHeight':443

});

/* Contact us popup frame */ 
$("a.forgotpw_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':570,
	'frameHeight':415	
});


/* In libClient JS
==eBook frame
$("a.eBook_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':800,
	'frameHeight':570
});

==Resources frame
$("a.res_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':705,
	'frameHeight':268,
		'overlayShow':	false
});
 */ 


/* Legal Notice*/ 
$("a.terms_msg_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':565,
	'frameHeight':505
});



/* Accounts Save + Progress display frame */ 
$("a.display_msg_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':565,
	'frameHeight':328
});

/* Accounts Contact msg - What is it? */ 
$("a.contact_explain_msg_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':565,
	'frameHeight':355
});


/* Terms - Distributor map min page*/ 
$("a.Support_dismap_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':620,
	'frameHeight':475
});

/* Terms - Request price list*/ 
$("a.price_noicon_iframe").fancybox({ 
	'centerOnScroll':false,
	'frameWidth':780,
	'frameHeight':660
});


}); 