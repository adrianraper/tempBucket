<?php
$regDate = strtotime('-2 month');
echo date('Y-m-d', $regDate);
flush();
exit();
