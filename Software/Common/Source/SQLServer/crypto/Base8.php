<?php

class Base8 {

	static function encode($src) {
		$result = "";
		for ($i = 0; $i < strlen($src); $i++)
			$result .= dechex(ord($src[$i]));
		
		return $result;
	}
	
	static function decode($src) {
		$result = "";
		for ($i = 0; $i < strlen($src); $i += 2)
			$result .= chr(hexdec(substr($src, $i, 2)));
		
		return $result;
	}
	
}

?>
