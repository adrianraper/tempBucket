<?php
header('Content-type: application/json');
$authCode = isset($_GET['code']) ? json_encode(array("authCode" => $_GET['code'])) : null;
$error = isset($_GET['error']) ? json_encode(array("error" => $_GET['error'])) : null;
if ($authCode) echo $authCode;
if ($error) echo $error;
flush();
exit();
