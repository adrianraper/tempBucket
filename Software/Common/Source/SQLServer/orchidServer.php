<?php
echo 'status=ok';
if (function_exists('zend_loader_file_encoded'))
	echo "&zendEncoded=".zend_loader_file_encoded();
if (function_exists('zend_loader_enabled'))
	echo "&zendEnabled=".zend_loader_enabled();
