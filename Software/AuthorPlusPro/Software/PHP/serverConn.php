<?php
// if this file is called from somewhere outside APO, give no response
// otherwise, response to the program
if ($_REQUEST['prog']=="NNW") {
	header('Content-type: text/xml');
	print('<sR><sR conn="ok" /></sR>');
	
	// also start session if it's not started yet
	if (session_id()=="") {
		session_start();
	}
}
?>