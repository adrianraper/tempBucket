<?php

    session_start();

    function printSessionVars() {

        try {
            foreach ($_SESSION as $key => $value) {
                echo "$key=$value<br/>";
            }
        } catch (Exception $e) {
            echo 'Caught exception: ',  $e->getMessage(), "<br/>";
        }

    }
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Checking on session variables</title>
</head>
<body>
    <?php printSessionVars();?>
</body>
</html>
