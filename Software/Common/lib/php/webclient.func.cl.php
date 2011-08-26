<?php
function sendAndLoad($serlet, $sendDat, &$reciDat) {
	/**
	 * Initialize the cURL session
	 */
	$ch = curl_init();
	//curl_setopt($ch, CURLOPT_HEADER, 1);
	curl_setopt($ch, CURLOPT_FAILONERROR, 1);
	/**
	 * Set the URL of the page or file to download.
	 */
	curl_setopt($ch, CURLOPT_URL, $serlet);
	/**
	 * Ask cURL to return the contents in a variable
	 * instead of simply echoing them to the browser.
	 */
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	/**
	 * Setup the post variables
	 */
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $sendDat);
	/**
	 * Execute the cURL session
	 */
	$reciDat = curl_exec ($ch);
	/**
	 * Close cURL session
	 */
	curl_close ($ch);
}
?>