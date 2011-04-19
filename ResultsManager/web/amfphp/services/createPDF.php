<?php

$pdf = $GLOBALS["HTTP_RAW_POST_DATA"];
header('Content-Type: application/pdf');
header('Content-Length: '.strlen($pdf));
header('Content-disposition:"inline"; filename="Clarity usage stats.pdf"');
echo $pdf;

exit(0);
?>