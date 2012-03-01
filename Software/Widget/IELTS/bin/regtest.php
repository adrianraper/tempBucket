<?php
$string ='* Distance degree: 5.5';
$regex = "/[0-9]+\.[0-9]+/";
preg_match($regex, $string, $matches);
print_r($matches);
?>
