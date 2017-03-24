<?php
/**
 * This is the base URL for any survey or action that you link to at the end of dpt.
 * Its purpose is to pass through the email address and test id that dpt sends
 * if the url does not accept them in pure form.
 *
 * Example: A google form
 * The url from dpt will be like this https://dpt.clarityenglish.com/followUpRedirector.php?href=https://goo.gl/forms/n5JFCIsQV6SaEakG2&email=adrian@noodles&testID=148
 * The survey needs to be run from this
 * https://docs.google.com/forms/d/e/1FAIpQLSdu7rFQMBi7Ava3LRzKmBuU8vhrSIoWxby0i8VYx8C38lKlsw/viewform?entry.555769051=adrian@noodles
 * The entry.xxxx refers to a specific field in the survey
 *
 * http://dock.projectbench/followUpRedirector.php?href=https://goo.gl/forms/n5JFCIsQV6SaEakG2&email=adrian@noodles&testID=148
 * http://dock.projectbench/followUpRedirector.php?href=https://dpt.clarityenglish.com/admin&email=adrian@noodles&testID=148
 *
 * Current known actions
 * https://goo.gl/forms/n5JFCIsQV6SaEakG2 = DPT survey for use from instant test tryout
 */

    $href = (isset($_GET['href'])) ? $_GET['href'] : null;
    $email = (isset($_GET['email'])) ? $_GET['email'] : null;
    $testId = (isset($_GET['testID'])) ? $_GET['testID'] : null;

    /*
    $shortenedURL = 'https://goo.gl/forms/n5JFCIsQV6SaEakG2';
    $targetURL = 'https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyCW_qwEhdGOYtmyPct8kH6VVN9lCeyCMYY&shortUrl='.$shortenedURL;
    // https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyCW_qwEhdGOYtmyPct8kH6VVN9lCeyCMYY&shortUrl=https://goo.gl/forms/n5JFCIsQV6SaEakG2
	$ch = curl_init();
	// Setup the post variables
	$curlOptions = array(CURLOPT_HEADER => false,
        CURLOPT_FAILONERROR=>true,
        CURLOPT_FOLLOWLOCATION=>true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_URL => $targetURL
    );
	curl_setopt_array($ch, $curlOptions);

	// Execute the cURL session
	$contents = curl_exec($ch);
	if($contents === false){
        $contents = "failed to expand short URL";
    } else {
        curl_close($ch);
        // $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
        if (substr($contents,0,3)==b"\xEF\xBB\xBF") {
            $contents = substr($contents,3);
        }
        // Errors handled at the end of the script
    }
    */
    switch ($href) {
        case 'https://goo.gl/forms/n5JFCIsQV6SaEakG2';
            $params = $email . ', test ' . $testId;
            $targetURL = 'https://docs.google.com/forms/d/e/1FAIpQLSdu7rFQMBi7Ava3LRzKmBuU8vhrSIoWxby0i8VYx8C38lKlsw/viewform?entry.555769051=' . $params;
            break;
        default:
            // If you weren't expecting this href, just simply go to it with the parameters
            $params = array();
            if (isset($email))
                $params[] = 'email='.$email;
            if (isset($testId))
                $params[] = 'testID='.$testId;
            $paramStr = implode('&', $params);
            if (count_chars($paramStr) > 0)
                $paramStr = '?'.$paramStr;
            $targetURL = $href.$paramStr;
    }
    header("Location: $targetURL");
    die();
