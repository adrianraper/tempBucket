function loadDIV(id){
	var xmlhttp=null;
	var page, place;

	if (window.XMLHttpRequest){
		xmlhttp=new XMLHttpRequest();
	}else if (window.ActiveXObject){
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp!=null){
		page = "content/u" + id + ".php";
		xmlhttp.open("GET",page,false);
		xmlhttp.send(null);
		place = document.getElementById('content_box');
		place.innerHTML = xmlhttp.responseText;
		
	$("a.video_iframe").fancybox({
				'width'				: 660,
				'height'			: 380,
				'autoScale'			: false,
				'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'scrolling'			: 'no',
				'type'				: 'iframe'
			});
	
	$("a.audio_iframe").fancybox({
				'width'				: 420,
				'height'			: 420,
				'autoScale'			: false,
				'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'scrolling'			: 'no',
				'type'				: 'iframe'
			});
		
		
		
	}else{
		alert("Your browser does not support XMLHTTP.");
	}
	setActive(id);
}

function setActive(id){
	var menuitem;
	var i;
	for (i=1; i<=8; i++) {
		menuitem = document.getElementById('U' + i);
		$(menuitem).removeClass().addClass('menu_u' + i);
	}
		menuitem = document.getElementById('U' + id);
		$(menuitem).removeClass().addClass('menu_u' + id + '_on');
}