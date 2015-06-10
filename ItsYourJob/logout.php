<?php
session_start();

// gh#1421 Clear everything in session except the prefix
$prefix = $_SESSION['PREFIX'];
$_SESSION = array();
$_SESSION['PREFIX'] = $prefix;