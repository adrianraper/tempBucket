<?php
// gh#950
//$pdf = $GLOBALS["HTTP_RAW_POST_DATA"];
$pdf = file_get_contents('php://input');
header('Content-Type: application/pdf');
header('Content-Length: '.strlen($pdf));
header('Content-disposition:"'.$_GET["method"].'"; filename="UsageStats.pdf"');

echo $pdf;

exit(0);
