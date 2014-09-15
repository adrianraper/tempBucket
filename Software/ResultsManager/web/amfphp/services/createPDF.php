<?php
// gh#950
//$pdf = $GLOBALS["HTTP_RAW_POST_DATA"];
if (isset($_GET["filename"])) {
	$filename = $_GET["filename"];
} else {
	$filename = 'UsageStats.pdf';
}
$pdf = file_get_contents('php://input');
header('Content-Type: application/pdf');
header('Content-Length: '.strlen($pdf));
header('Content-disposition:"'.$_GET["method"].'"; filename="'.$filename.'"');

echo $pdf;

exit(0);
?>