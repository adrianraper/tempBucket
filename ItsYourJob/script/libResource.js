var g_Content;
var tabber1, tabber2, tabber3;
function load(unitid){
	xmlhttp=null;
	if (window.XMLHttpRequest){// code for Firefox, Opera, IE7, etc.
		xmlhttp=new XMLHttpRequest();
	}else if (window.ActiveXObject){// code for IE6, IE5
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	if(xmlhttp!=null){
		xmlhttp.onreadystatechange=state_Change;
		url = "../loadResource.php" + "?unitID=" + unitid;
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
			displayResource(xmlhttp.responseText);
			tabber1 = new Yetii({
				id: 'tab-topics-container'
				});

			tabber2 = new Yetii({
				id: 'tab-container-tips',
				tabclass: 'tab-tips'
				});

			tabber3 = new Yetii({
				id: 'tab-container-links',
				tabclass: 'tab-links'
				});
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

function displayResource(xmlStr){
	var xmlDoc = loadXMLString(xmlStr);
	var quoteDoc = xmlDoc.getElementsByTagName("item")[0];
	displayQuote(quoteDoc);
	var linkDoc = xmlDoc.getElementsByTagName("item")[1];
	displayLink(linkDoc);
	var topDoc = xmlDoc.getElementsByTagName("item")[2];
	displayTip(topDoc);
}

function displayQuote(parentNode){
	var quoteNodes = parentNode.getElementsByTagName("quote");
	var quoteNode = quoteNodes[0];
	document.getElementById('quote_detail').innerHTML = quoteNode.getAttribute('description');
	document.getElementById('quote_title').innerHTML = quoteNode.getAttribute('title');
}

function displayLink(parentNode){
	var hrefContent="";
	var linkContent='<p class="tab-links-des" id="links_des">Try the resources below:</p>';
	var linkNodes = parentNode.getElementsByTagName("link");
	for(var i=1; i<= linkNodes.length; i++){
		hrefContent += '<li><a href="#links' + i + '"></a></li>';
        linkContent += '<div class="tab-links" id="links' + i + '">';
        linkContent += '<p class="detail_box_no_list_img"><img src="' + linkNodes[i-1].getAttribute('imgsrc') + '"/></p>';
   		linkContent += '<p class="detail_box_no_list_text">' + linkNodes[i-1].getAttribute('description') + '</p>';
        linkContent += '</div>';
	}
	document.getElementById('tab-container-links-nav').innerHTML = hrefContent;
	document.getElementById('links_container').innerHTML = linkContent;
}

function displayTip(parentNode){
	var hrefContent="";
	var tipContent="";
	var tipNodes = parentNode.getElementsByTagName("tip");
	for(var i=1; i<= tipNodes.length; i++){
		hrefContent += '<li><a href="#tips' + i + '"></a></li>';
		tipContent += '<div class="tab-tips" id="tips' + i + '">';
		tipContent += '<p class="heading">Tip ' + i + '</p>';
		tipContent += tipNodes[i-1].getAttribute('description');
        tipContent += '</div>';
	}
	document.getElementById('tab-container-tips-nav').innerHTML = hrefContent;
	document.getElementById('tips_container').innerHTML = tipContent;
}