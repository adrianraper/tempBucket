<?php
	$commonDomain = "http://192.168.8.58/";
	
	# setup post string
	if (isset($_POST['postXML']) && ($_POST['postXML']!='')) {
		$postXML=$_POST['postXML'];
		//header("Content-Type: text/xml");
		/*
		$postXML = "requestID=2&customerName=$fullName&customerEmail=$email&enquiry=$enquiry
				.&deliveryMethod=$deliveryMethod&institution=$institution
				.&phone=$phone&address=$address&hearFrom=$hearFrom
				.&mailingList=$mailingList&message=$message&country=$country
				.&price=$price&afterdemo=$afterdemo&contactMethod=$contactMethod
				.&sector=$sector";
		*/
		//$postXML = '<query method="'.$values['name'].'" email="'.$values['email'].'/>'

		#Initialize the cURL session
		$ch = curl_init();
		
		//curl_setopt($ch, CURLOPT_HEADER, 1);
		curl_setopt($ch, CURLOPT_FAILONERROR, 1); 
		
		#Set the URL of the page or file to download.
		// This will now change to the new script
		//$targetURL = "http://67.192.124.37/email/mailpage.php";
		$targetURL = $commonDomain."Software/ResultsManager/web/amfphp/services/WebsiteMailPage.php";
		curl_setopt($ch, CURLOPT_URL, $targetURL);
			
		# Ask cURL to return the contents in a variable
		# instead of simply echoing them to the browser.
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		
		# Setup the post variables
		curl_setopt($ch, CURLOPT_POST, 1);
		//curl_setopt($ch, CURLOPT_POSTFIELDS, $values);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $postXML);
		
		# Execute the cURL session
		$contents = curl_exec ($ch);
		
		# Close cURL session
		if (curl_errno($ch)) {
			echo curl_error($ch);
		} else {
			// $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
			if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
				$contents = substr($contents,3);
			}
			echo $contents;
			curl_close($ch);
		}
	} else {
		echo false;
	}
exit(0);
?>