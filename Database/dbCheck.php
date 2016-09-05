<?php
header('Content-Type: text/plain; charset=utf-8');

date_default_timezone_set("UTC");
$adodbPath= "../Software/Common";
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");

// If you are using MySQL
/*
$driver = "mysqlt";
$host = "localhost";
$user = "clarity";
$password = "password";
$dbname = "clarity";
*/
// If you are using SQLite
$driver = "pdo_sqlite";
$dbname = "clarity.db";
$host = $user = $password = null;

function getDSN($driver, $dbname, $host=null, $user=null, $password=null) {
    $dsn = $driver . "://";
    if (isset($user) && $user != "")
        $dsn .= $user . ":" . $password . "@";

    if (isset($host) && $host != "")
        $dsn .= $host . '/';

    if ($dbname != "")
        $dsn .= $dbname;
    return $dsn;
}

function getDetails($driver, $dbname, $host=null, $user=null, $password=null) {
	$text = $driver."://";
	if (isset($user) && $user != "")
		$text .= $user.":********@";

	if (isset($host) && $host != "")
		$text .= $host.'/';

	if (isset($dbname) && $dbname != "")
		$text .= $dbname;

	return $text;
}

    echo "Try to connect to " . getDetails($driver, $dbname, $host, $user, $password) . "\n";

	$db = ADONewConnection(getDSN($driver, $dbname, $host, $user, $password));
	if (!$db) die("Connection failed");
	$db->debug = true;
	// v3.6 UTF8 character mismatch between PHP and MySQL
	if ($driver == 'mysql')
		$charSetRC = mysql_set_charset('utf8');
	$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
	
	if (!$db) {
		echo "Cannot connect to database\n";
	} else {
		echo "Successfully connected to database\n";
	}
$sql = 	<<<EOD
	SELECT *
	FROM T_DatabaseVersion
	ORDER BY F_VersionNumber DESC;
EOD;
try {
    $rs = $db->Execute($sql);
    if ($rs) {
        while ($dbObj = $rs->FetchNextObj()) {
            echo "version=".$dbObj->F_VersionNumber.' date='.$dbObj->F_ReleaseDate."\n";
        }
    } else {
        echo "Select failed\n";
    }
} catch (Exception $e) {
    echo $e->getMessage();
}
$db->Close();

if (function_exists('zend_loader_file_encoded'))
    echo "&zendEncoded=".zend_loader_file_encoded()."\n";
if (function_exists('zend_loader_enabled'))
    echo "&zendEnabled=".zend_loader_enabled()."\n";

?>
