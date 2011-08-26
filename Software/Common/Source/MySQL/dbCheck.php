<?php
include_once("XMLQuery.php");
$Query = new XMLQuery();
$vars = $Query->vars;

include_once("dbPath.php");
$Db = new DB();

include_once("dbProgress.php");
$Progress	= new PROGRESS();

include_once("queryProgress.php");

$node = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><dbCheck>";

$Db->open("score");
if (!$Db) {
	$node .= "<note>Cannot connect to database</note>";
} else {
	$node .= "<note>Successfully connected to database</note>";
	$vars['ROOTID'] = 1;

	// check users
	$Progress->selectUsers( $vars );
	if ($Db->num_rows < 1) {
	    $node .= "<note>No users can be read</note>";
	} else {
	    $node .= "<note>Users=" .$Db->num_rows ."</note>";
	}
	// then try writing to a table
	$vars['USERID'] = 1;
	$vars['SENTDATA'] = "scratch-pad " .$Db->now();
	$Progress->updateScratchPad($vars);
	if ($Db->affected_rows > 0) {
		$node .= "<note>Text written to table successfully</note>";
	} else {
		$node .= "<note>Text cannot be written to table for default user</note>";
	}
}

$node .= "</dbCheck>";
print($node);

$Db->disconnect();
?>
