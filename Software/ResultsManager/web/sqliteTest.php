<?php
include('../../Common/adodb5/adodb.inc.php');
$tmppath = urlencode("../../../Database/clarity.db");
$dsn = "pdo_sqlite://$tmppath";  # persist is optional
$db = ADONewConnection($dsn);  # no need for Connect/PConnect
if (!$db) die("Connection failed");
	$db->debug = true;
	$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
	$ADODB_COUNTRECS = false;
	$rs = $db->Execute('select * from T_Product;');
	print "<pre>";
	print_r($rs->GetRows());
	print "</pre>";
?>