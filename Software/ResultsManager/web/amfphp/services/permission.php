<?php
require_once(dirname(__FILE__)."/../../config.php");

// gh#259
if (isset($_GET['provider']) && ($_GET['provider'] == 'Google')) {
	if (isset($_GET['src']) && (stristr($_GET['src'], 'claritysipport.com'))) {
		echo "123456789";
	} else {
		// Or use an exception
		echo "400";
	}
} else {
	// Or use an exception
	echo "";
}
return;
