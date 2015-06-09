var xmlhttp;
var g_Content;
var g_player="flvPlayer.swf";
var g_time;
var g_currentid;
var g_courseid;
var g_videoid;
var g_audioid;
var g_focusid;
var g_audioItemID;
var g_ebookID;
var g_ebookitemID;
var tracking; // for write scores of audio;

function loadMain(url, id, courseid){
	xmlhttp=null;
	if (window.XMLHttpRequest){// code for Firefox, Opera, IE7, etc.
		xmlhttp=new XMLHttpRequest();
	}else if (window.ActiveXObject){// code for IE6, IE5
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp!=null){
		xmlhttp.onreadystatechange=state_Change;
		if(courseid == null || courseid == "") courseid = 1;
		url = url + "?id=" + id + "&courseid=" + courseid;
		xmlhttp.open("GET",url,true);
		xmlhttp.send(null);
	}else{
		alert("Your browser does not support XMLHTTP.");
	}
}

function state_Change(){
	if (xmlhttp.readyState==4){// 4 = "loaded"
		if (xmlhttp.status==200){// 200 = "OK"
			//ToDo: Display the XML content on the page.
			g_Content = xmlhttp.responseText;

			if(g_username=="iyjguest"){
				g_currentid = "08";
				setDemoUnitsStatus(10);
				displayUnitById(xmlhttp.responseText, g_currentid);
			}else{
				var xml = loadXMLString(g_Content);
				var Units = xml.getElementsByTagName('course');
				if( g_currentid == null){// First load
					for(var i=0; i<Units.length; i++){
						if(Units[i].getAttribute("current") != null){
							g_currentid = i + 1;
							break;
						}
					}
					if(g_currentid == null){// Can't get current course from XML
						g_currentid = "10";
					}
					if(g_currentid < 10){
						g_currentid = "0" + g_currentid;
					}
					
					if(g_bookmark != ""){
						g_focusid = g_bookmark;
					}else{
						if(g_frequency == "0"){
							g_focusid = "01";
						}else{
							g_focusid = g_currentid;
						}
					}
				}
				if(g_startingPoint != ""){
					var sp = searchPoint(xml, g_startingPoint);
					if(sp[0] == 10){
						g_focusid = "10";
					}else{
						g_focusid = "0" + sp[0];
					}
					setOneUnitsStatus(sp[0]);
					displayUnitById(xmlhttp.responseText, g_focusid);
					switch(sp[1]){
					case 1: // ebook
						setTimeout(function() { document.getElementById('content_ebook_link').onclick(); }, 1000);
						break;
					case 2: // video
						switch(sp[2]){
						case 1:
							setTimeout(function() { document.getElementById('content_video_q1_link').onclick(); }, 1000);
							break;
						case 2:
							setTimeout(function() { document.getElementById('content_video_q2_link').onclick(); }, 1000);
							break;
						case 3:
							setTimeout(function() { document.getElementById('content_video_q3_link').onclick(); }, 1000);
							break;
						default :
						}
						break;
					case 3: // audio
						setTimeout(function() { document.getElementById('playerplay').childNodes[0].click(); }, 1000);
						break;
					case 4: // practice
						setTimeout(function() { document.getElementById('content_exe_link').onclick(); }, 1000);
						break;
					case 5: // resource
						switch(sp[2]){
						case 1:
							setTimeout(function() { document.getElementById('a_res_mp3').click(); }, 1000);
							break;
						case 2:
							setTimeout(function() { document.getElementById('a_res_links').click(); }, 1000);
							break;
						case 3:
							setTimeout(function() { document.getElementById('a_res_tips').click(); }, 1000);
							break;
						default :
						}
						break;
					default:
					}
				}else{
					// Set the units status.
					if(g_frequency == "0"){
						setAllUnitsStatus();
					}else{
						setUnitsStatus(10, g_currentid);
					}
					displayUnitById(xmlhttp.responseText, g_focusid);
				}
			}
		}else{
			alert("Problem retrieving data:" + xmlhttp.statusText);
		}
	}
}

function loadXMLString(str){
	try{ //Internet Explorer
		xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
		xmlDoc.async = "false";
		xmlDoc.loadXML(str);
		return xmlDoc; 
	}catch(e){
		try{ //Firefox, Mozilla, Opera, etc.
			parser = new DOMParser();
			xmlDoc = parser.parseFromString(str,"text/xml");
			return xmlDoc;
		}catch(e){
			alert(e.message);
		}
	}
	return null;
}

function setUnitsStatus(total, currentid){
	var coursePlace, htmlString, courseid, unitDoc;
	var id = parseInt(currentid, 10);
	for(var i=1; i<total+1; i++){
		unitDoc = loadXMLString(g_Content).getElementsByTagName('course')[i-1];
		if(i >= 10){
			courseid = i;
			coursePlace = document.getElementById('course_' + i);
		}else{
			courseid = "0" + i;
			coursePlace = document.getElementById('course_' + "0" + i);
		}
		if(i <= id){
			coursePlace.className = "active";
			htmlString = '<div class="group_menu">';
			htmlString += '<a href="javascript:displayUnitById(g_Content, \'' + courseid + '\');">';
			htmlString += '<span class="menu_num">' + i + '</span>';
			htmlString += '<span class="menu_title">' + unitDoc.getAttribute('name') + '</span></a>';
			htmlString += '</div>';
		}else if(i==id){
			coursePlace.className = "current";
			htmlString = '<div class="group_menu">';
			htmlString += '<a href="javascript:displayUnitById(g_Content, \'' + courseid + '\');">';
			htmlString += '<span class="menu_num">' + i + '</span>';
			htmlString += '<span class="menu_title">' + unitDoc.getAttribute('name') + '</span></a>';
			htmlString += '<div class="menu_icon_new_png" id="course_new_icon"></div></div>';
		}else{
			coursePlace.className = "";
			htmlString = '<div class="group_menu">';
			htmlString += '<span class="menu_num">' + i + '</span>';
			htmlString += '<span class="menu_title">' + unitDoc.getAttribute('name') + '</span>';
			htmlString += '</div>';
		}
		document.getElementById('course_' + courseid).innerHTML = htmlString;
	}
}

function setAllUnitsStatus(){
	var coursePlace, htmlString, courseid, unitDoc;
	for(var i=1; i<11; i++){
		unitDoc = loadXMLString(g_Content).getElementsByTagName('course')[i-1];
		if(i >= 10){
			courseid = i;
			coursePlace = document.getElementById('course_' + i);
		}else{
			courseid = "0" + i;
			coursePlace = document.getElementById('course_' + "0" + i);
		}
		if(i == 1){
			coursePlace.className = "current";
			htmlString = '<div class="group_menu">';
			htmlString += '<a href="javascript:displayUnitById(g_Content, \'' + courseid + '\');">';
			htmlString += '<span class="menu_num">' + i + '</span>';
			htmlString += '<span class="menu_title">' + unitDoc.getAttribute('name') + '</span></a>';
			htmlString += '</div>';
		}else{
			coursePlace.className = "active";
			htmlString = '<div class="group_menu">';
			htmlString += '<a href="javascript:displayUnitById(g_Content, \'' + courseid + '\');">';
			htmlString += '<span class="menu_num">' + i + '</span>';
			htmlString += '<span class="menu_title">' + unitDoc.getAttribute('name') + '</span></a>';
			htmlString += '</div>';
		}
		document.getElementById('course_' + courseid).innerHTML = htmlString;
	}
}

function setOneUnitsStatus(id){
	var coursePlace, htmlString, courseid, unitDoc;
	for(var i=1; i<11; i++){
		unitDoc = loadXMLString(g_Content).getElementsByTagName('course')[i-1];
		if(i >= 10){
			courseid = i;
			coursePlace = document.getElementById('course_' + i);
		}else{
			courseid = "0" + i;
			coursePlace = document.getElementById('course_' + "0" + i);
		}
		if(i == id){
			coursePlace.className = "current";
			htmlString = '<div class="group_menu">';
			htmlString += '<a href="javascript:displayUnitById(g_Content, \'' + courseid + '\');">';
			htmlString += '<span class="menu_num">' + i + '</span>';
			htmlString += '<span class="menu_title">' + unitDoc.getAttribute('name') + '</span></a>';
			htmlString += '</div>';
		}else{
			coursePlace.className = "";
			htmlString = '<div class="group_menu">';
			htmlString += '<span class="menu_num">' + i + '</span>';
			htmlString += '<span class="menu_title">' + unitDoc.getAttribute('name') + '</span>';
			htmlString += '</div>';
		}
		document.getElementById('course_' + courseid).innerHTML = htmlString;
	}
}

function setDemoUnitsStatus(total){
	var coursePlace, htmlString, courseid, unitDoc;
	for(var i=1; i<total+1; i++){
		unitDoc = loadXMLString(g_Content).getElementsByTagName('course')[i-1];
		if(i >= 10){
			courseid = i;
			coursePlace = document.getElementById('course_' + i);
		}else{
			courseid = "0" + i;
			coursePlace = document.getElementById('course_' + "0" + i);
		}
		if(i==8){
			coursePlace.className = "current";
			htmlString = '<div class="group_menu">';
			htmlString += '<a href="javascript:displayUnitById(g_Content, \'' + courseid + '\');">';
			htmlString += '<span class="menu_num">' + i + '</span>';
			htmlString += '<span class="menu_title">' + unitDoc.getAttribute('name') + '</span></a>';
			htmlString += '<div class="menu_icon_demo_png" id="course_demo_icon"></div></div>';
		}else{
			coursePlace.className = "";
			htmlString = '<div class="group_menu">';
			htmlString += '<span class="menu_num">' + i + '</span>';
			htmlString += '<span class="menu_title">' + unitDoc.getAttribute('name') + '</span>';
			htmlString += '</div>';
		}
		document.getElementById('course_' + courseid).innerHTML = htmlString;
	}
}

function displayUnitById(xmlString, id){
	if(checkDbLogin() == false && g_username!='iyjguest'){
		$("a.contact_explain_msg_iframe").fancybox({ 
			 'centerOnScroll':false,
			 'frameWidth':565,
			 'frameHeight':355
			}).trigger('click');
	}else{
		saveBookmark(id);
		// Get the information from responseText and then display in the right place.
		g_focusid = id;
		var xmlDoc = loadXMLString(xmlString);
		var docElm = document.getElementById('course_' + id);
		var unitDoc = xmlDoc.getElementsByTagName('course')[parseInt(id, 10)-1];
		g_courseid = unitDoc.getAttribute('id');
		// Show left menu.
		var xmlVal = unitDoc.getAttribute("name");
		// Change style of left menu
		docElm.className = "current";
		if(g_username != "iyjguest" && g_startingPoint == ""){
			for(var i=1; i<=parseInt(g_currentid, 10); i++){
				if(i != parseInt(id, 10)){
					if(i==10){
						document.getElementById('course_' + i).className = "active";
					}else{
						document.getElementById('course_' + "0" + i).className = "active";
					}
				}
			}
		}
			
		var course_title = document.getElementById("course_title");
		course_title.innerHTML = xmlVal;
		
		if(unitDoc.getAttribute("endDate") != null){
			g_time = unitDoc.getAttribute("enableDate") + " to " + unitDoc.getAttribute("endDate");
		}else{
			g_time = unitDoc.getAttribute("enableDate") + " to " + unitDoc.getAttribute("disableDate");
		}	
		// Show the weekly time
		document.getElementById('subscrib_period').innerHTML = "Unit " + parseInt(id, 10) + ": " + xmlVal + " (" + g_time + ")";
		// Show the actual content
		displayUnitContent(unitDoc);
		
		// Change resource
		document.getElementById('a_res_mp3').href = "resources/index.php?tab-topics-container=1&unitID=" + parseInt(id, 10);
		document.getElementById('a_res_links').href = "resources/index.php?tab-topics-container=2&unitID=" + parseInt(id, 10);
		document.getElementById('a_res_tips').href = "resources/index.php?tab-topics-container=3&unitID=" + parseInt(id, 10);
		document.getElementById('a_ares_recorder').href = "resources/index.php?tab-topics-container=4&unitID=" + parseInt(id, 10);
		document.getElementById('a_res_mp3').onclick = onClickEbook;
		document.getElementById('a_res_links').onclick = onClickEbook;
		document.getElementById('a_res_tips').onclick = onClickEbook;
		document.getElementById('a_ares_recorder').onclick = onClickEbook;
	}
}

function displayUnitContent(parentDom){
	var dom, itemType;
	var childDoms = parentDom.getElementsByTagName('unit');
	for(var i=0; i<childDoms.length; i++){
		dom = childDoms[i];
		itemType = dom.getAttribute("type");
		switch(itemType){
		case "ebook":
			displayEbook(dom);
			break;
		case "video":
			displayVideo(dom);
			break;
		case "AuthorPlus":
			displayPractice(dom);
			break;
		case "audio":
			displayAudio(dom);
			break;
		default:
			continue;
		}
	}
}

function displayEbook(dom){
	if(dom == null){
		return false;
	}else{
		var title, des, link;
		g_ebookID = dom.getAttribute('id');
		title = document.getElementById('content_ebook_title');
		title.innerHTML = dom.getAttribute("name");
		des = document.getElementById('content_ebook_describe');
		des.innerHTML = dom.getAttribute("description");
		link = document.getElementById('content_ebook_link');
		g_ebookitemID = dom.getElementsByTagName('item')[0].getAttribute("id");
		link.href = "#";
		
		link.onclick = function(){
			if(checkDbLogin() == false && g_username!='iyjguest'){
				$("a.contact_explain_msg_iframe").fancybox({ 
					 'centerOnScroll':false,
					 'frameWidth':565,
					 'frameHeight':355
					}).trigger('click');
				return false;
			}else{
				// Stop video
				if(thisFlash("flvPlayer")){
					flvPlayerControl("STOP");
				}
				
				// Stop audio
				stop();
				
				EbookpopUp(dom.getElementsByTagName('item')[0].getAttribute("contentPath")
						  + "?e="+g_ebookID+"&i="+g_ebookitemID+"&o="+g_courseid);
				
				return false;
			}
		};
		return true;
	}
}

function displayVideo(dom){
	var currentDom, index;
	var q, q_des, q_link, q_video;
	// Display description for video.
	document.getElementById('content_video_describe').innerHTML = dom.getAttribute('description');
	
	// Display the videos
	var childDoms = dom.getElementsByTagName('item');
	g_videoid = dom.getAttribute('id');

	currentDom = childDoms[0];
	q = document.getElementById('content_video_q1');
	q.innerHTML = currentDom.getAttribute('name');
	q_des = document.getElementById('content_video_q1_describe');
	q_des.innerHTML = currentDom.getAttribute('description');
	q_link1 = document.getElementById('content_video_q1_link');
	q_link1.onclick = function(){
		if(checkDbLogin() == false && g_username!='iyjguest'){
			$("a.contact_explain_msg_iframe").fancybox({ 
				 'centerOnScroll':false,
				 'frameWidth':565,
				 'frameHeight':355
				}).trigger('click'); 
			return false;
		}else{
			stop();
			onClickQuestion(1);
			showVideo(childDoms[0].getAttribute('contentPath'), xmlToString(childDoms[0]));
			return false;
		}
	};
	
	currentDom = childDoms[1];
	q = document.getElementById('content_video_q2');
	q.innerHTML = currentDom.getAttribute('name');
	q_des = document.getElementById('content_video_q2_describe');
	q_des.innerHTML = currentDom.getAttribute('description');
	var q_link2 = document.getElementById('content_video_q2_link');
	q_link2.onclick = function(){
		if(checkDbLogin() == false && g_username!='iyjguest'){
			$("a.contact_explain_msg_iframe").fancybox({ 
				 'centerOnScroll':false,
				 'frameWidth':565,
				 'frameHeight':355
				}).trigger('click');
			return false;
		}else{
			stop();
			onClickQuestion(2);
			showVideo(childDoms[1].getAttribute('contentPath'), xmlToString(childDoms[1]));
			return false;
		}
	};
	
	document.getElementById('ul_video3').style.display = "block";
	currentDom = childDoms[2];
	q = document.getElementById('content_video_q3');
	q.innerHTML = currentDom.getAttribute('name');
	q_des = document.getElementById('content_video_q3_describe');
	q_des.innerHTML = currentDom.getAttribute('description');
	var q_link3 = document.getElementById('content_video_q3_link');
	q_link3.onclick = function(){
		if(checkDbLogin() == false && g_username!='iyjguest'){
			$("a.contact_explain_msg_iframe").fancybox({ 
				 'centerOnScroll':false,
				 'frameWidth':565,
				 'frameHeight':355
				}).trigger('click');
			return false;
		}else{
			stop();
			onClickQuestion(3);
			showVideo(childDoms[2].getAttribute('contentPath'), xmlToString(childDoms[2]));
			return false;
		}
	};

	if(g_version=='NAMEN'){
		document.getElementById('content_video').innerHTML = '<img src="images/video_template_north.jpg">';
	}else if(g_version == 'INDEN'){
		document.getElementById('content_video').innerHTML = '<img src="images/video_template_indian.jpg">';
	}else{
		document.getElementById('content_video').innerHTML = '<img src="images/video_template.jpg">';
	}
	clearHighlight();
	changeTitle("Through an employer's eyes");
}

function displayPractice(dom){
	if(dom == null){
		return false;
	}else{
		var title, des, link;
		title = document.getElementById('content_exe');
		title.innerHTML = dom.getAttribute("name");
		des = document.getElementById('content_exe_describe');
		des.innerHTML = dom.getAttribute("description");
		link = document.getElementById('content_exe_link');
		//link.href = "javascript:ProgrampopUp('" + dom.getElementsByTagName('item')[0].getAttribute("contentPath")
		//			+ "?" + "rootID=" + g_rootid + "&" + "userID=" + g_userid + "&" + dom.getElementsByTagName('item')[0].getAttribute("startingPoint") + "')";
		//link.onclick = onClickPractice;
		link.href = "#";
		link.onclick = function(){
			if(checkDbLogin() == false && g_username!='iyjguest'){
				$("a.contact_explain_msg_iframe").fancybox({ 
					 'centerOnScroll':false,
					 'frameWidth':565,
					 'frameHeight':355
					}).trigger('click');
				return false;
			}else{
				// Stop video
				if(thisFlash("flvPlayer")){
					flvPlayerControl("STOP");
				}
				
				// Stop audio
				stop();
				if(g_username=="iyjguest"){
					//ProgrampopUp('http://' + g_domain + '/area1/ItsYourJob/Start.php?prefix=IYJ-DEMO&username=iyjguest&course=1249436487189&startingPoint=ex:1252280112489');
					ProgrampopUp('http://' + g_domain + '/area1/ItsYourJob/Start.php?prefix=IYJ-DEMO&username=iyjguest&' + dom.getElementsByTagName('item')[0].getAttribute("startingPoint"));
				}else{
					if(g_prefix == "" || g_prefix == null){
					ProgrampopUp(dom.getElementsByTagName('item')[0].getAttribute("contentPath")	+ "?" + "rootID=" + g_rootid + "&" + "userID=" + g_userid + "&" + dom.getElementsByTagName('item')[0].getAttribute("startingPoint"));
					}else{
						ProgrampopUp(dom.getElementsByTagName('item')[0].getAttribute("contentPath")	+ "?" + "prefix="+g_prefix+"&rootID=" + g_rootid + "&" + "userID=" + g_userid + "&" + dom.getElementsByTagName('item')[0].getAttribute("startingPoint"));
					}
				}
				return false;
			}
		};
		return true;
	}
}

function displayAudio(dom){
	if(dom == null){
		return false;
	}else{
		var title, des, mp3player, ico;
		g_audioid = dom.getAttribute("id");
		g_audioItemID = dom.getElementsByTagName('item')[0].getAttribute("id");
		title = document.getElementById('content_audio_title');
		title.innerHTML = dom.getAttribute("name");
		des = document.getElementById('content_audio_describe');
		des.innerHTML = dom.getAttribute("description");
		ico = document.getElementById('content_audio_icon');
		ico.className = dom.getAttribute("icon");
		// Change the audio files.
		mp3player = document.getElementById('altFlashContent');
		var mp3 = '<object id="myMP3Player" type="application/x-shockwave-flash" data="mp3player.swf" width="1" height="1">';
		mp3 += '<param name="AllowScriptAccess" value="always" />';
		mp3 += '<param name="movie" value="mp3player.swf" />';
		mp3 += '<param name="FlashVars" value="listener=myListener&amp;interval=500" />';
		mp3 += '</object>';
		mp3 += '<div id="player">';
		mp3 += '<div id="playerplay" class="button play"><a href="#" onclick="javascript:play(\''+dom.getElementsByTagName('item')[0].getAttribute("contentPath")+'\');return false;">PLAY</a></div>';
		mp3 += '<div id="playerpause" class="button pause"><a href="#" onclick="javascript:pause();return false;">PAUSE</a></div>';
		mp3 += '<div id="playerstop" class="button stop"><a href="#" onclick="javascript:stop(); return false;">STOP</a></div>';
		mp3 += '</div>';
		mp3player.innerHTML = mp3;
		tracking = 1;
		return true;
	}	
}

function showVideo(name, xmlString){
	var cueNodes, cueID, cueTime, cpArray;
	var videoPlace = document.getElementById("content_video");
	//var tag = '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="320" height="280" id="flvPlayer" name="flvPlayer" align="top">';
	var tag = '<object id="flvPlayer" type="application/x-shockwave-flash" data="' + g_player + '" width="320" height="280" align="top">';
	tag += '<param name="allowScriptAccess" value="always" />';
	tag += '<param name="allowFullScreen" value="false" />';
	tag += '<param name="movie" value="' + g_player + '" />';
	tag += '<param name="wmode" value="transparent" />';
	tag += '<param name="FlashVars" value="vsrc=' + name + '" />';
	tag += '<param name="quality" value="high" />';
	tag += '<param name="bgcolor" value="#03022e" />';
	tag += '<param name="loop" value="false" />';
	tag += '<param name="menu" value="false" />';
	//tag += '<embed src="' + g_player + '" FlashVars="vsrc=' + name + '" loop="false" menu="false" wmode="transparent" quality="high" bgcolor="#03022e" id="flvPlayer" name="flvPlayer" width="320" height="280" align="top" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />';
	tag += '</object>';
	videoPlace.innerHTML = tag;
	// Insert cuepoints to video
	var cDom = loadXMLString(xmlString);
	var itemID = cDom.childNodes[0].getAttribute('id');
	cueNodes = cDom.getElementsByTagName('cuepoint');
	swfCallback = function(cpname, playTime){
		if(cpname == "end"){
			changeTitle("Through an employer's eyes");
			var correct = cueNodes.length;
			var wrong = 0;
			var skipped = 1;
			var duration = Math.round(playTime);
			var score = 100;
			writeScore(g_courseid, g_videoid, itemID, score, correct, wrong, skipped, duration);
		}else{
			for(var i=0; i<cueNodes.length; i++){
				if((parseInt(cpname, 10)-1) == i){
					changeTitle(cueNodes[i].getAttribute("value"));
					if(playTime >= 0){
						var correct = i;
						var wrong = 0;
						var skipped = cueNodes.length - i + 1;
						var duration = Math.round(playTime);
						var score = Math.round(100 * ( correct / (cueNodes.length) ));
						writeScore(g_courseid, g_videoid, itemID, score, correct, wrong, skipped, duration);
					}
				}
			}
		}
	};
	onVideoReady = function(){
		for(var i=0; i<cueNodes.length; i++){
			cueID = cueNodes[i].getAttribute("id");
			cueTime = cueNodes[i].getAttribute("time");
			addCuePoints(cueID, cueTime);
		}
	};
}

function highlight(id){
	var qtmp = document.getElementById('content_video_q' + id);
	qtmp.parentNode.className = "unit_content_box_left_ques_current";
}

function clearHighlight(){
	var i = 1;
	var qtmp;
	for(i=1; i < 4; i++){
		qtmp = document.getElementById('content_video_q' + i + '_describe');
		qtmp.parentNode.className = "unit_content_box_left_ques";
	}
}

function onClickQuestion(id){
	clearHighlight();
	highlight(id);
}

function changeTitle(name){
	var title = document.getElementById('video_middle_title');
	title.innerHTML = name;
}

function loadPage(name){
	if(checkDbLogin() == false && g_username!='iyjguest'){
		$("a.contact_explain_msg_iframe").fancybox({ 
			 'centerOnScroll':false,
			 'frameWidth':565,
			 'frameHeight':355
			}).trigger('click');
	}else{
		if(name == "My_Progress"){
			// Stop video
			if(thisFlash("flvPlayer")){
				flvPlayerControl("STOP");
			}
			
			// Stop audio
			try{
				stop();
			}catch(e){}
			document.getElementById("a_course").className = "";
			document.getElementById("a_account").className = "";
			document.getElementById("a_progress").className = "current";
			document.getElementById('My_mainPannel').style.display = "none";
			document.getElementById('My_progressPannel').style.display = "block";
			if(isDemo){
				try{
					document.getElementById('altContent').style.display = "none";
					document.getElementById('done_box').src = "images/progress2.jpg";
					document.getElementById('img_compare_box').src = "images/progress1.jpg";
					document.getElementById('compare_box').style.display = "none";
					document.getElementById('done_box').style.display = "block";
				}catch(e){
				}
			}else{
				try{
					swfobject.embedSWF(progressControl + "ProgressWidget.swf", "altContent", coordsWidth, coordsHeight, "9.0.28", expressInstall, flashvars, params, attr);
					document.getElementById('altContent').style.display = "block";
					document.getElementById('done_box').style.display = "none";
				}catch(e){
				}
			}
		}else{
			document.getElementById('My_progressPannel').style.display = "none";
			document.getElementById('My_mainPannel').style.display = "block";
			var xmlhttp=null;
			var a_tag = null;
			if (window.XMLHttpRequest){// code for Firefox, Opera, IE7, etc.
				xmlhttp=new XMLHttpRequest();
			}else if (window.ActiveXObject){// code for IE6, IE5
				xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
			}
			if(xmlhttp!=null){
				var page = "script/frame.php" + "?t=" + name;
				xmlhttp.open("GET",page,false);
				xmlhttp.send(null);
				var place = document.getElementById("My_mainPannel");
				place.innerHTML = xmlhttp.responseText;
				if(g_frequency == "0"){
					document.getElementById('subscrib_period').style.display = "none";
				}
				if(name == "My_Course"){
					document.getElementById("a_course").className = "current";
					document.getElementById("a_account").className = "";
					document.getElementById("a_progress").className = "";
					document.getElementById('subscrib_version_IntE').style.display = "none";
					document.getElementById('subscrib_version_IndianE').style.display = "none";
					document.getElementById('subscrib_version_NAme').style.display = "none";
					if(g_version == 'NAMEN'){
						document.getElementById('subscrib_version_NAme').style.display = "block";
					}else if(g_version == 'INDEN'){
						document.getElementById('subscrib_version_IndianE').style.display = "block";
					}else{
						document.getElementById('subscrib_version_IntE').style.display = "block";
					}
					loadMain(g_url, g_id, "1202389918390");
					$(document).ready(function() {
						/* Resources frame */
						$("a.res_iframe").fancybox({
						    'centerOnScroll':false,
						    'frameWidth':705,
						    'frameHeight':268,
						    'overlayShow': false
						});
					}); 
				}else if(name == "My_Account"){
					document.getElementById("a_course").className = "";
					document.getElementById("a_account").className = "current";
					document.getElementById("a_progress").className = "";
					loadMyAccount(g_Content);
					$(document).ready(function() {
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
					}); 
				}else{
		
				}
			}else{
				alert("Your browser does not support XMLHTTP.");
			}
		}
	}
}

function flvPlayerControl(action){
	try{
		thisFlash("flvPlayer").flvPlayerControl(action);
	}catch(e){
	}
}

function addCuePoints(id, time){
	thisFlash("flvPlayer").addCuePoints(id, time);
}

function onVideoEnd(){
	changeTitle("Through an employer's eyes");
}

// Get the flash in the document
function thisFlash(flashName){
	return document.getElementById(flashName);
}

function xmlToString(xmlObject){
	if (navigator.appName.indexOf("Microsoft") != -1){
		return xmlString = xmlObject.xml;
	}else{
		return xmlString = (new XMLSerializer()).serializeToString(xmlObject);
	}
}

function onEbookClose(pageNumber){
	alert("close");
}

function onFlip(pageNumber, totalPages){
	alert(pageNumber);
	alert(totalPages);
}

function loadMyAccount(xmlString){
	document.getElementById('save_errmsg_area').style.display = "none";
	document.getElementById('save_okmsg_area').style.display = "none";
	document.getElementById('err_password_msg').style.display = "none";
	
	var xmlDoc = loadXMLString(xmlString);
	if(g_frequency != "0"){
		document.getElementById('li_schedule').style.display = "block";
	}
	displayAgenda(xmlDoc);
	loadAccountSetting(xmlDoc);
}

function displayAgenda(parentNode){
	var time;
	var currentid = parseInt(g_currentid, 10);
	var unitNodes = parentNode.getElementsByTagName('course');
	var agendaContent = '<ul>';
	agendaContent += '<li class="titlename">';
	agendaContent += '<p class="unit">Unit</p>';
	agendaContent += '<p class="title">Title</p>';
	agendaContent += '<p class="date">Date</p>';
	agendaContent += '</li>';
	for(var i=1; i<=unitNodes.length; i++){
		if(i<currentid){
			agendaContent += '<li class="active">';
		}else if(i==currentid){
			agendaContent += '<li class="current">';
		}else{
			agendaContent += '<li class="heading">';
		}
		agendaContent += '<p class="unit">Unit ' + i + '</p>';
		agendaContent += '<p class="title">' + unitNodes[i-1].getAttribute('name') + '</p>';
		if(unitNodes[i-1].getAttribute("endDate") != null){
			time = unitNodes[i-1].getAttribute("enableDate") + " to " + unitNodes[i-1].getAttribute("endDate");
		}else{
			time = unitNodes[i-1].getAttribute("enableDate") + " to " + unitNodes[i-1].getAttribute("disableDate");
		}
		agendaContent += '<p class="date">' + time + '</p></li>';
	}
	agendaContent +='</ul>';
	document.getElementById('set_agenda_area').innerHTML = agendaContent;
}

function loadAccountSetting(parentNode){
	var i;
	var timeControl = document.form_left_area.radio_time;
	if(g_frequency == "" || g_frequency == null){
		g_frequency = "0";
	}
	for(i=0; i<timeControl.length; i++){
		if (timeControl[i].value == g_frequency){
			timeControl[i].checked = true;
		}
	}
	
	// Language version
	var t_version = document.form_left_area.radio_version;
	if(g_version == "" || g_version == null){
		g_version = "EN";
	}
	for(i=0; i<t_version.length; i++){
		if (t_version[i].value == g_version){
			t_version[i].checked = true;
		}
	}
	
	// choices
	var t_choices = document.form_left_area.choices;
	if(g_contactMethod == "" || g_contactMethod==null){
		document.form_left_area.no_choices.checked = true;
		for(i=0; i<t_choices.length; i++){
			t_choices[i].checked = false;
			t_choices[i].disabled = true;
		}
	}else{
		t_choices[0].disabled = false;
		for(i=0; i<t_choices.length; i++){
			if (t_choices[i].value == g_contactMethod){
				t_choices[i].checked = true;
			}
		}
	}
}

function saveSetting(){
	document.getElementById('err_password_msg').style.display = "none";
	document.getElementById('save_errmsg_area').style.display = "none";
	document.getElementById('save_okmsg_area').style.display = "none";
	var isSubmit = true;
	// Time Control
	var timeControl = document.form_left_area.radio_time;
	for(i=0; i<timeControl.length; i++){
		if (timeControl[i].checked == true){
			g_frequency = timeControl[i].value;
		}
	}
	if(g_frequency==null || g_frequency==""){
		g_frequency = "0";
	}
	
	if(g_frequency == "0"){
		g_currentid = "10";
	}
	// Version
	var t_version = document.form_left_area.radio_version;
	for(i=0; i<t_version.length; i++){
		if (t_version[i].checked == true){
			g_version = t_version[i].value;
		}
	}
	if(g_version==null || g_version==""){
		g_version="EN";
	}
	
	document.getElementById('subscrib_version_IntE').style.display = "none";
	document.getElementById('subscrib_version_IndianE').style.display = "none";
	document.getElementById('subscrib_version_NAme').style.display = "none";
	if(g_version == 'NAMEN'){
		document.getElementById('subscrib_version_NAme').style.display = "block";
	}else if(g_version == 'INDEN'){
		document.getElementById('subscrib_version_IndianE').style.display = "block";
	}else{
		document.getElementById('subscrib_version_IntE').style.display = "block";
	}
	
	// Change password
	var old_pwd = document.form_left_area.ori_pwd.value;
	var new_pwd = document.form_left_area.new_pwd.value;
	var new_pwd_confirm = document.form_left_area.new_pwd_confirm.value;
	// password need change
	if(old_pwd != "" || new_pwd != "" || new_pwd_confirm != ""){
		if(old_pwd != g_pwd){
			//alert("Your original password is not correct!");
			document.getElementById('err_password_msg').innerHTML = "Your original password is not correct.";
			document.getElementById('err_password_msg').style.display = "block";
			isSubmit = false;
		}else{
			if(new_pwd != new_pwd_confirm){
				//alert("The two new password are not matched!");
				document.getElementById('err_password_msg').innerHTML = "Your new passwords do not match.";
				document.getElementById('err_password_msg').style.display = "block";
				isSubmit = false;
			}else if(new_pwd == ""){
				//alert("Password can't be blank");
				document.getElementById('err_password_msg').innerHTML = "Password can't be blank!";
				document.getElementById('err_password_msg').style.display = "block";
				isSubmit = false;
			}else{
				g_pwd = new_pwd;
			}
		}
	}
	// Contact Method
	var t_choices = document.form_left_area.choices;
	for(i=0; i<t_choices.length; i++){
		if (t_choices[i].checked == true){
			g_contactMethod = t_choices[i].value;
		}
	}
	if(g_contactMethod==null){
		g_contactMethod = "";
	}
	
	if(isSubmit){
		var svrlet = "saveSetting.php";
		svrlet += "?time=" + g_frequency;
		svrlet += "&pwd=" + g_pwd;
		svrlet += "&method=" + g_contactMethod;
		svrlet += "&language=" + g_version;
		cmdRequest(svrlet, "GET", onSetSuccess, true);
	}
}

function writeScore(courseID, unitID, itemID, score, correct, wrong, skipped, duration){
	var svrlet = "writeScore.php";
	svrlet += "?o=" + courseID;
	svrlet += "&u=" + unitID;
	svrlet += "&i=" + itemID;
	svrlet += "&s=" + score;
	svrlet += "&c=" + correct;
	svrlet += "&w=" + wrong;
	svrlet += "&m=" + skipped;
	svrlet += "&d=" + duration;
	cmdRequest(svrlet, "GET", onResponse, true);
}

function cmdRequest(svrlet, method, handle, syn){
	xmlhttp = null;
	if (window.XMLHttpRequest){// code for Firefox, Opera, IE7, etc.
		xmlhttp = new XMLHttpRequest();
	}else if (window.ActiveXObject){// code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp != null){
		if(syn){
			xmlhttp.onreadystatechange = handle;
		}
		xmlhttp.open(method, svrlet, syn);
		xmlhttp.send(null);
	}else{
		alert("Your browser does not support XMLHTTP.");
	}
}

function onResponse(){

}

function onSetSuccess(){
	if (xmlhttp.readyState==4){// 4 = "loaded"
		if (xmlhttp.status==200){// 200 = "OK"
			//ToDo: Display the XML content on the page.
			if(xmlhttp.responseText == "success"){
				document.getElementById('save_errmsg_area').style.display = "none";
				document.getElementById('save_okmsg_area').style.display = "block";
			}else{
				document.getElementById('save_okmsg_area').style.display = "none";
				document.getElementById('save_errmsg_area').style.display = "block";
			}
		}else{
			alert("Problem retrieving data:" + xmlhttp.statusText);
		}
	}
}

function do_logout(){
	if(g_referer=="iyjonline"){
		cmdRequest("stopUser.php", "GET", null, false);
		cmdRequest("logout.php", "GET", null, false);
		window.location.href="http://www.iyjonline.com/";
	}else if(g_domain=="www.clarityenglish.com"){
		if(isDirectLink != ""){
			cmdRequest("stopUser.php", "GET", null, false);
			cmdRequest("logout.php", "GET", null, false);
			window.location.href="../../area1/ItsYourJob/index.php?prefix=" + isDirectLink;		
		}else{
			return true;
		}
	}else{
		cmdRequest("stopUser.php", "GET", null, false);
		cmdRequest("logout.php", "GET", null, false);
		// Change to area1 folder, 7/6/2011 by Wei
		window.location.href="../area1/ItsYourJob/index.php";
	}
}

function logout(){
	if (xmlhttp.readyState==4){// 4 = "loaded"
		if (xmlhttp.status==200){// 200 = "OK"
			if(g_domain=="www.clarityenglish.com"){
				window.location.href="http://www.clarityenglish.com/englishonline/index.php";
			}else{
				window.location.href="../area1/ItsYourJob/index.php";
				//window.location.href="index.php";
			}
		}
	}
}

function checkDbLogin(){
	// Adrian. Quick fix until we can run AA licences. Just skip the instanceID check.
	return true;
	
	var xmlhttp = null;
	if (window.XMLHttpRequest){// code for Firefox, Opera, IE7, etc.
		xmlhttp = new XMLHttpRequest();
	}else if (window.ActiveXObject){// code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp != null){
		xmlhttp.open("GET", "checkPermission.php", false);
		xmlhttp.send(null);
		if(xmlhttp.responseText == "true"){
			return true;
		}else{
			return false;
		}
	}else{
		alert("Your browser does not support XMLHTTP.");
	}
}

function saveBookmark(m){
	g_bookmark = m;
	var xmlhttp = null;
	if (window.XMLHttpRequest){// code for Firefox, Opera, IE7, etc.
		xmlhttp = new XMLHttpRequest();
	}else if (window.ActiveXObject){// code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp != null){
		xmlhttp.open("GET", "saveBookmark.php?m="+m, false);
		xmlhttp.send(null);
		if(xmlhttp.responseText == "true"){
			return true;
		}else{
			return false;
		}
	}else{
		alert("Your browser does not support XMLHTTP.");
	}
}
/******************************************************************************
 * MP3 Player Functions
 *****************************************************************************/
var myListener = new Object();
//var isPlay_click = false;
/**
 * Initialize
 */
myListener.onInit = function(){
	_addEventListener(document, "mousemove", _sliderMove, false);
	_addEventListener(document, "mouseup", _sliderUp, false);
};
/**
 * Update
 */
myListener.onUpdate = function(){
	var isPlaying = this.isPlaying;
	var url = this.url;
	var volume = this.volume;

	isPlaying = (isPlaying == "true");
	document.getElementById("playerplay").style.display = (isPlaying)?"none":"block";
	document.getElementById("playerpause").style.display = (isPlaying)?"block":"none";
	/*
	if (isPlaying==false && isPlay_click==false){
		isPlay_click = true;
		var correct = 1;
		var wrong = 0;
		var skipped = 0;
		var dtime = Math.round(duration/1000);
		var score = 100;
		writeScore(g_courseid, g_audioid, g_audioItemID, score, correct, wrong, skipped, dtime);
	}*/
	// if all the bytes was loaded, write score
	if(this.bytesPercent == 100){
		var position = this.position;
		var duration = this.duration;
		var per = 100 * position / duration;
		if(per >= 20 && tracking == 1){
			tracking++;
			var correct = 1;
			var wrong = 0;
			var skipped = 4;
			var dtime = Math.round(position/1000);
			var score = 20;
			writeScore(g_courseid, g_audioid, g_audioItemID, score, correct, wrong, skipped, dtime);
		}
		if(per >= 40 && tracking == 2){
			tracking++;
			var correct = 2;
			var wrong = 0;
			var skipped = 2;
			var dtime = Math.round(position/1000);
			var score = 40;
			writeScore(g_courseid, g_audioid, g_audioItemID, score, correct, wrong, skipped, dtime);
		}
		if(per >= 60 && tracking == 3){
			tracking++;
			var correct = 3;
			var wrong = 0;
			var skipped = 1;
			var dtime = Math.round(position/1000);
			var score = 60;
			writeScore(g_courseid, g_audioid, g_audioItemID, score, correct, wrong, skipped, dtime);
		}
		if(per >= 80 && tracking == 4){
			tracking++;
			var correct = 4;
			var wrong = 0;
			var skipped = 1;
			var dtime = Math.round(position/1000);
			var score = 80;
			writeScore(g_courseid, g_audioid, g_audioItemID, score, correct, wrong, skipped, dtime);
		}
		if(per >= 95 && tracking == 5){
			tracking++;
			var correct = 5;
			var wrong = 0;
			var skipped = 0;
			var dtime = Math.round(position/1000);
			var score = 100;
			writeScore(g_courseid, g_audioid, g_audioItemID, score, correct, wrong, skipped, dtime);
		}
	}
};

/**
 * private functions
 */
var sliderPressed = false;
function _getFlashObject(){
	return document.getElementById("myMP3Player");
}
function _cumulativeOffset (pElement){
	var valueT = 0, valueL = 0;
	do {
		valueT += pElement.offsetTop  || 0;
		valueL += pElement.offsetLeft || 0;
		pElement = pElement.offsetParent;
	} while (pElement);
	return [valueL, valueT];
}
function _xmouse(pEvent){
	return pEvent.pageX || (pEvent.clientX + (document.documentElement.scrollLeft || document.body.scrollLeft));
}
function _ymouse(pEvent){
	return pEvent.pageY || (pEvent.clientY + (document.documentElement.scrollTop || document.body.scrollTop));
}
function _findPosX(pElement){
	if (!pElement) return 0;
	var pos = _cumulativeOffset(pElement);
	return pos[0];
}
function _findPosY(pElement){
	if (!pElement) return 0;
	var pos = _cumulativeOffset(pElement);
	return pos[1];
}
function _addEventListener(pElement, pName, pListener, pUseCapture){
	if (pElement.addEventListener) {
		pElement.addEventListener(pName, pListener, pUseCapture);
	} else if (pElement.attachEvent) {
		pElement.attachEvent("on"+pName, pListener);
	}
}
function _sliderDown(pEvent){
	sliderPressed = true;
}
function _sliderMove(pEvent){
	if (sliderPressed) {
		var timelineWidth = 160;
		var sliderWidth = 40;
    	var sliderPositionMin = 40;
    	var sliderPositionMax = sliderPositionMin + timelineWidth - sliderWidth;
		var startX = _findPosX(document.getElementById("timeline"));
		var x = _xmouse(pEvent) - sliderWidth / 2;
		
		if (x < startX) {
			var position = 0;
		} else if (x > startX + timelineWidth) {
			var position = myListener.duration;
		} else {
			var position = Math.round(myListener.duration * (x - startX - sliderWidth) / (startX + timelineWidth - sliderWidth - startX));
		}
		_getFlashObject().SetVariable("method:setPosition", position);
	}
}
function _sliderUp(pEvent){
	sliderPressed = false;
}

/**
 * public functions
 */
function play(url) {
	if(checkDbLogin() == false && g_username!='iyjguest'){
		$("a.contact_explain_msg_iframe").fancybox({ 
			 'centerOnScroll':false,
			 'frameWidth':565,
			 'frameHeight':355
			}).trigger('click');
		return false;
	}else{
		// Stop video
		if(thisFlash("flvPlayer")){
			flvPlayerControl("STOP");
		}
	/*
		isPlay_click = false;
		
		var correct = 0;
		var wrong = 0;
		var skipped = 1;
		var dtime = 0;
		var score = 0;
		writeScore(g_courseid, g_audioid, g_audioItemID, score, correct, wrong, skipped, dtime);
	*/	
		if (myListener.url == "undefined" || myListener.url == null || myListener.url != url) {
			_getFlashObject().SetVariable("method:setUrl", url);
		}
	    _getFlashObject().SetVariable("method:play", "");
		_getFlashObject().SetVariable("enabled", "true");
		return false;
	}
}
function pause() {
	//isPlay_click = true;
    _getFlashObject().SetVariable("method:pause", "");
    return false;
}
function stop() {
	//isPlay_click = true;
    _getFlashObject().SetVariable("method:stop", "");
    return false;
}
/******************************************************************************
 * End of MP3 Player Funtions
 *****************************************************************************/

function onClickEbook(){
	// Stop video
	if(thisFlash("flvPlayer")){
		flvPlayerControl("STOP");
	}
	
	// Stop audio
	stop();
	return false;
}

function onClickVideo(){
	// Stop audio
	stop();
	return false;
}

function onClickPractice(){
	// Stop video
	if(thisFlash("flvPlayer")){
		flvPlayerControl("STOP");
	}
	
	// Stop audio
	stop();	
	return false;
}

function onClickDone(){
	document.getElementById('done_but').className = 'progress_current_but';
	document.getElementById('compare_but').className = 'progress_active_but';
	if(isDemo){
		document.getElementById('done_box').style.display = "block";
		document.getElementById('compare_box').style.display = "none";
	}else{
		try{
			document.getElementById('pw').switchView('progressView');
		}catch(e){
		}
	}
	return false;
}

function onClickCompare(){
	document.getElementById('compare_but').className = 'progress_current_but';
	document.getElementById('done_but').className = 'progress_active_but';
	if(isDemo){
		document.getElementById('done_box').style.display = "none";
		//document.getElementById('img_compare_box').style.display = "block";
		document.getElementById('compare_box').style.display = "block";
	}else{
		try{
			document.getElementById('pw').switchView('comparisonView');
		}catch(e){
		}
	}
	return false;
}

function onClickSetting(){
	document.getElementById('btn_setting').className = 'progress_current_but';
	document.getElementById('btn_schedule').className = 'progress_active_but';
	document.getElementById('set_schedule_setting').style.display = "none";
	document.getElementById('set_account_setting').style.display = "block";
	return false;
}

function onClickSchedule(){
	document.getElementById('btn_schedule').className = 'progress_current_but';
	document.getElementById('btn_setting').className = 'progress_active_but';
	document.getElementById('set_account_setting').style.display = "none";
	document.getElementById('set_schedule_setting').style.display = "block";
	return false;
}

function uncheckAll(){
	if(document.form_left_area.no_choices.checked == true){
		g_contactMethod = "";
		for(var i=0; i < document.form_left_area.choices.length; i++){
			document.form_left_area.choices[i].checked=false;
			document.form_left_area.choices[i].disabled=true;
		}
	}else{
		document.form_left_area.choices[0].disabled=false;
	}
}

function searchPoint(xml, startingPoint){
	//var startingPoint = "1255000000680";
	var sp_array = new Array();
	var is_got = false;
	var courses = xml.getElementsByTagName("course");
	for(var i = 0; i < courses.length; i++){
		var course = courses[i];
		sp_array[0] = i + 1; // course id
		if( course.attributes[0].value == startingPoint){
			break;
		}else{
			var units = course.getElementsByTagName("unit")
			for(var j = 0; j < units.length; j++){
				var unit = units[j];
				sp_array[1] = j + 1; // unit id
				if(unit.attributes[0].value == startingPoint){
					is_got = true;
					break;
				}else{
					var items = unit.getElementsByTagName("item");
					for(var k = 0; k < items.length; k++){
						var item = items[k];
						if(item.attributes[0].value == startingPoint){
							sp_array[2] = k + 1; // item id
							is_got = true;
							break;
						}
					}
					if(is_got){
						break;
					}
				}
			}
			if(is_got){
				break;
			}
		}
		if(is_got){
			break;
		}
	}
	return sp_array;
}