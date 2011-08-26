<?
//"serverVars.php" get server side variables for javascript
Header("content-type: application/x-javascript");
$server=$_SERVER['HTTP_HOST'];
echo "var serverString=\"" .$server ."\";";
$ip=$_SERVER['REMOTE_ADDR'];
echo "var ipString=\"" .$ip ."\";";
$referrerIP=$_SERVER['HTTP_REFERER'];
echo "var referrerString=\"" .$referrerIP ."\";";
?>