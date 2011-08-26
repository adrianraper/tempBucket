 <?php
	include('../../adodb5/adodb.inc.php');
	$path = urlencode('../../../../database/clarity.db');
	$dsn = "pdo_sqlite://".$path."/?persist";
	$db = NewADOConnection($dsn);
	if (!$db) die("Connection failed");
	$db->debug = true;
	$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
	$ADODB_COUNTRECS = false;
	$rs = $db->Execute('select * from T_AccountRoot;');
	print "<pre>";
	print_r($rs->GetRows());
	print "</pre>";
?>
