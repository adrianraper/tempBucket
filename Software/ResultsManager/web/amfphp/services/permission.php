<?php
require_once(dirname(__FILE__)."/../../config.php");

// gh#259
if (isset($_GET['provider']) && ($_GET['provider'] == 'Google')) {
	if (isset($_GET['src'])) {
		// Send the authorisation request to the resource owner
		$rc = array('token' => '123456789');
	} else {
		// Nothing to get authorisation for
		$rc = array('token' => null, 'error' => 'no resource to be authorised');
	}
} else {
	// Or use an exception
	$rc = array('token' => null, 'error' => 'no resource owner');
}
echo json_encode($rc);
return;
