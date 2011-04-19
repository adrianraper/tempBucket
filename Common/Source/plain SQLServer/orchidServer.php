<?php
//ini_set('error_reporting', E_ALL);
echo 'status=ok';
echo "&zendEncoded=".zend_loader_file_encoded();
echo "&zendEnabled=".zend_loader_enabled();
?>