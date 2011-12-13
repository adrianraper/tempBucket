<?php
$pdf = $GLOBALS["HTTP_RAW_POST_DATA"];
header('Content-Type: application/pdf');
header('Content-Length: '.strlen($pdf));
header('Content-disposition:"'.$_GET["method"].'"; filename="Road to IELTS 2.pdf"');

echo $pdf;

exit(0);
?>