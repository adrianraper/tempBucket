<?php session_start() ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
<title>Clarity English language teaching online | Support | Licence and delivery</title>

<link rel="stylesheet" type="text/css" href="../css/global.css"/>
<link rel="stylesheet" type="text/css" href="../css/support.css"/>               

<!--Jquery library-->
<script type="text/javascript" src="/script/jquery.js"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js"></script>
<script type="text/javascript" src="/script/jquery.easing.min.js"></script>


<script type="text/javascript">
// Read a page's GET URL variables and return them as an associative array. From http://snipplr.com/users/Roshambo/
function getUrlVars(){
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for (var i = 0; i < hashes.length; i++) {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}
function getParameterByName(name) {
	var allVars = getUrlVars();
	if (allVars[name]) {
		return allVars[name];
	} else {
		return '';
	}
}
</script>
<script type="text/javascript">
	// It might be a lot simpler to do all the XML/XPath stuff in php then I don't need double code for IE vs other browsers??
	// Also once I have the result of xpath back, I can't just do more xpath on it
	// Or I should be using xsl?
	// I know that in this case it is very simple XML that I am parsing and I could easily get the stuff I want through DOM parsing...
	// So keep it simple for now...
	var passedSerialNumber=getParameterByName("serial");
	var passedProduct=unescape(getParameterByName("product"));
	var passedProductShortName=passedProduct;
	switch (passedProduct) {
		case 'Study Skills Success V9':
		case 'StudySkillsSuccessV9':
		case 'Study Skills Success':
		case 'StudySkillsSuccess':
			passedProductCode=49;
			//passedProductCode=3;
			break;
		case 'Tense Buster':
		case 'TenseBuster':
			passedProductCode=9;
			break;
		case 'Clear Pronunciation':
		case 'ClearPronunciation':
			passedProductCode=39;
			break;
		case 'Clear Pronunciation 2':
		case 'ClearPronunciation2':
			passedProductCode=50;
			break;
		case 'Clarity English Success':
		case 'ClarityEnglishSuccess':
			passedProductCode=37;
			break;
		case 'English for Hotel Staff':
		case 'EnglishForHotelStaff':
		case 'EFHS':
			passedProductCode=40;
			break;
		case 'It&apos;s Your Job':
		case 'ItsYourJob':
			passedProductCode=38;
			break;
		case 'Customer Service Communication Skills':
		case 'CustomerServiceCommunicationSkills':
		case 'CSCS':
			passedProductCode=35;
			passedProductShortName = 'Customer Service CS';
			break;
		case 'Active Reading':
		case 'ActiveReading':
			passedProductCode=33;
			break;
		case 'AuthorPlus':
		case 'Author Plus':
			passedProductCode=1;
			break;
		case 'Road to IELTS General Training':
		case 'RoadToIELTS-GeneralTraining':
		case 'Road to IELTS Academic':
		case 'RoadToIELTS-Academic':
		case 'Road to IELTS':
		case 'RoadToIELTS':
			passedProductCode=12;
			break;
		case 'Business Writing':
		case 'BusinessWriting':
			passedProductCode=10;
			break;
		case 'Results Manager':
		case 'ResultsManager':
			passedProductCode=2;
			break;
		default:
			passedProductCode=0;
	}
	var passedVersion=getParameterByName("licence");
	if (passedVersion=='')
		passedVersion='*';
		
	// First read the XML
	if (window.XMLHttpRequest){
		var req = new XMLHttpRequest();
	} else {
		var req=new ActiveXObject("Microsoft.XMLHTTP");
	}
	req.open("GET", "/Updates/productUpgrades.xml", false);
	req.send(null);
	var xmlDoc = req.responseXML;
	//document.write(xmlDoc.toString());
	
	// This function gets the upgrade information for this product from XML and then formats it for display
	function displayXMLForProduct(productCode, version) {
		//document.write('display XML for ' + productCode + ': ' + version); 
		var nodes=getUpgradesForProduct(productCode, version);
		if (window.ActiveXObject) {
			//document.write('nodes=' + nodes.length + '<br/>'); 
			if (nodes.length>0) {
				XMLForProduct(nodes);
			} else {
				displayForNoUpgrades(productCode, version);
			}
		} else {
			//document.write('nodes=' + nodes.snapshotLength + '<br/>'); 
			if (nodes.snapshotLength>0) {
				XMLForProduct(nodes);
			} else {
				displayForNoUpgrades(productCode, version);
			}
		}
	}
	
	// This function uses xpath to get information for one product from the XML, with one or more patches based on licence/version
	// Call it like this: getUpgradeForProduct('9','109C');
	function getUpgradesForProduct(code, version){
		// Wildcards are not just substituted for text, you need different syntax
		if (version=='*') {
			var path = "/upgrades/product[@code='"+code+"']/patch[@licence]";
		} else {
			var path = "/upgrades/product[@code='"+code+"']/patch[@licence='"+version+"']";
		}
		//document.write('path=' + path + '<br/>'); 
		if (window.ActiveXObject) {
			xmlDoc.setProperty("SelectionLanguage","XPath");
			return nodes=xmlDoc.selectNodes(path);
		} else {
		//} else if (document.evaluate) {
			// changed from a node set to a snapshot so I can check the length
			//return copyIterator = xmlDoc.evaluate(path, xmlDoc, null, XPathResult.ANY_TYPE, null );
			return copyIterator = xmlDoc.evaluate(path, xmlDoc, null, 7, null );
		}
	}

	// This picks up the output from the xpath and directs it to the formatting function (has to be based on browser capability)
	function XMLForProduct (nodes) {
		
		if (window.ActiveXObject) {
			for (i=0;i<nodes.length;i++){
				//document.write(nodes[i].xml);
				resetDetails();
				setDisplayDetailsForUpgrade(nodes[i]);
			}
		} else {
			/*
			var thisNode=nodes.iterateNext();
			while (thisNode) {
				//document.write((new XMLSerializer()).serializeToString(thisNode));
				setDisplayDetailsForUpgrade(thisNode);
				thisNode=nodes.iterateNext();
			}
			*/
			for (i=0;i<nodes.snapshotLength;i++){
				//document.write(nodes[i].xml);
				resetDetails();
				setDisplayDetailsForUpgrade(nodes.snapshotItem(i));
			}
			
		}
		
	}
	// Function needed in case XML not complete so that you don't keep previous data
	function resetDetails() {
		downloadPath='';
		description='';
		validity='';
	}
	// This is the bad function here in that it deals with data and formatting
	function setDisplayDetailsForUpgrade(thisNode) {
		productName = thisNode.getAttribute('licence');
		displayHeader(productName);
		//document.write(productName);
		for (j=0;j<thisNode.childNodes.length;j++){
			//document.write(thisNode.childNodes[j].nodeName + "..");
			switch (thisNode.childNodes[j].nodeName) {
				case 'downloadPath':
					downloadPath = thisNode.childNodes[j].firstChild.nodeValue;
					break;
				case 'description':
					description = thisNode.childNodes[j].firstChild.nodeValue;
					break;
				case 'validity':
					validity = thisNode.childNodes[j].firstChild.nodeValue;
					break;
			}
		}
		document.write('<p>'+description+'</p>');
		document.write('<p>'+validity+'</p>');
		var downloadLinkShortForm = downloadPath.substr(downloadPath.lastIndexOf('/')+1);
		if (downloadPath!='') {
			document.write('<p>Download and run from <a href="'+downloadPath+'" target="_blank">'+downloadLinkShortForm+'</a></p>');
		}
		displayFooter(productName);
	}

	
	function displayHeader(version) {
		document.write('<h2>'+passedProduct+': <a name="TC_Upgrade_'+passedProduct+'">Upgrade for version '+version+'</a></h2>');		
	}
	function displayFooter(x) {
		document.write('<p class="clear" height="200"></p>');
	}
	
	function displayForNoUpgrades(productCode, version) {
		// Maybe you passed an unexpected product name
		if (productCode==0) {
			var description = 'This page is not expecting this product. Please visit our general support pages.';
			document.write('<p>'+description+'</p>');
			displayFooter('nothing');
		// or there are no upgrades for a product
		} else {
			if (version!='*') {
				var description = 'There are no upgrades for ' + passedProduct + ' from the CD with version ' + version;
			} else {
				var description = 'There are no upgrades for ' + passedProduct;
			}
	
			displayHeader(version);
			document.write('<p>'+description+'</p>');
			displayFooter(passedProduct);
		}
	}

</script>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-873320-12']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
</head>



<body id="support">
<?php $currentSelection="support"; ?>
<?php $supportSelection="tutorials"; ?>

<div id="container_outter">
<?php include  ($_SERVER['DOCUMENT_ROOT'].'/include/header.php') ; ?>

	<div id="menu_program"><?php include ( 'menu.php' ); ?></div>
     <div id="container_support">
     
       <div class="enquirybox">
       	 <div class="top">
               <span class="title">Tutorials</span>
               
                
       	 </div>
            <div class="subcontent tutorials">
                 <div class="content">
                 	<div id="upgrade_page">
                
 	   				 <script type="text/javascript">displayXMLForProduct(passedProductCode, passedVersion);</script>
                    <div  class="back">
 
                     
                     <a href="javascript: history.go(-1)">Back</a>
                     </div>
        	</div>
        
                
           </div>
 <div class="btm"></div>

</div>
    </div>
     <?php include 'common/searchbottom.php' ?>
</div>
<?php include ($_SERVER['DOCUMENT_ROOT'].'/include/footer_plain.php' ); ?>

</body>



</html>
