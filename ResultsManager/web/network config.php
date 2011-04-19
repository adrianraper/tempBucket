<?php

// If the total manageables in the logged in account is more than this students will not be displayed and some function disabled (RM only)
$GLOBALS['max_manageables_for_student_display'] = 2000;

// This contains literals.xml (moved from content). Expect it to be the same folder as this config.php
//$GLOBALS['interface_dir'] = "./";
$GLOBALS['interface_dir'] = "/../";

// This contains any help files. Expect it to be /Software/ResultsManager/Help
$GLOBALS['help_dir'] = "./Help";

/* The temporary directory is used as a holding area for uploads before they are processed */
$GLOBALS['tmp_dir'] = "./tmp";

/* Configuration for RMail */


/* The 'from' field of auto-sent emails */
$GLOBALS['rmail_from'] = "Clarity English <support@clarityenglish.com>";

/* For different backend databases */
$GLOBALS['dbms'] = 'pdo_sqlite';
$GLOBALS['data_dir'] = "../../../Content";
$tmppath = urlencode("../../../../../Database/clarity.db");
$GLOBALS['db'] = $GLOBALS['dbms']."://$tmppath";
$commonFolders = "/../../Common";

/* Directories for Smarty, rmail & adodb libraries.  If you want these in a different location for a particular setup override them in the host
   based settings below */
$GLOBALS['adodb_libs'] = dirname(__FILE__).$commonFolders."/adodb5/";

?>
