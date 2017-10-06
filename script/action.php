<?php

/*
* You can test like this:
*   http://localhost/support/script/action.php?method=forgotPassword&email=adrian@noodles.hk
*/

require_once "variables.php";

if (isset($_POST['method'])) {
	$queryMethod = $_POST['method'];
} else if (isset($_GET['method'])) {
	$queryMethod = $_GET['method'];
} else {
	$queryMethod = "";
}

// Initialize variables
$errorCode = 0;
$failReason = '';


// This script is called either by jQuery.ajax calls from a form or by the html submit method of the form.
// The only mandatory field is method, usually sent by POST but it could come from GET

switch ($queryMethod) {
    case "forgotPassword":

        if (isset($_POST['email'])) {
            $email = $_POST['email'];
        } else if (isset($_GET['email'])) {
            $email = $_GET['email'];
        } else {
            $email = "";
        }

        $postXML = "CLS_Email=$email";
        $targetURL = $commonDomain."Software/ResultsManager/web/amfphp/services/ResendEmailPassword.php";

        // Initialize the cURL session
        $ch = curl_init();

        // Setup the post variables
        $curlOptions = array(CURLOPT_HEADER => false,
            CURLOPT_FAILONERROR=>true,
            CURLOPT_FOLLOWLOCATION=>true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $postXML,
            CURLOPT_URL => $targetURL
        );
        curl_setopt_array($ch, $curlOptions);

        // Execute the cURL session
        $contents = curl_exec($ch);
        if ($contents === false){
            // echo 'Curl error: ' . curl_error($ch);
            $rc = array();
            $rc['error'] = 1;
            $rc['message'] = curl_error($ch);
            curl_close($ch);
        } else {
            curl_close($ch);
            // $contents is coming back with a utf-8 BOM in front of it, which invalidates it as JSON. Get rid of it.
            if (substr($contents,0,3)=="\xEF\xBB\xBF")
                $contents = substr($contents,3);
            parse_str($contents, $rc);

            if ($debugLog)
                error_log("back from ResendEmailPassword with $contents for $email \n", 3, $debugFile);

        }
        break;
}

print json_encode($rc);
exit();
	
