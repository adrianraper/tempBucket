<?php
/*
 * http://www.zedia.net/2009/as3crypto-and-php-what-a-fun-ride/
 * 
 * $crypt = new Crypt();
 * $parameters = 'rootID='.$rootID.'&prefix='.$prefix.'&studentID='.$studentID.'&teacherID='.$teacherID.'&unitName='.$unitName;
 * $startProgram = "?data=".$crypt->encodeSafeChars($crypt->encrypt($parameters));
 */
class Crypt {
	var $key = NULL;		
	var $iv = NULL;
	var $iv_size = NULL;
	var $algorithm = NULL;
	var $mode = NULL;
 
	function Crypt($key = ""){
        // 64 bit key = 8 bytes
		if (!$key) $key = 'ClarityL';
		$this->init($key);
	}
 
	function init($key = "") {
		$this->key = $key;
 
		$this->algorithm = MCRYPT_DES;
		$this->mode = MCRYPT_MODE_ECB;
 
		$this->iv_size = mcrypt_get_iv_size($this->algorithm, $this->mode);
		$this->iv = mcrypt_create_iv($this->iv_size, MCRYPT_RAND);
	}
 
	function encrypt($data) {
		$size = mcrypt_get_block_size($this->algorithm, $this->mode);
		$data = $this->pkcs5_pad($data, $size);
		return base64_encode(mcrypt_encrypt($this->algorithm, $this->key, $data, $this->mode, $this->iv));
	}
 
	function decrypt($data) {
        return $this->pkcs5_unpad(rtrim(mcrypt_decrypt($this->algorithm, $this->key, base64_decode($data), $this->mode, $this->iv)));
	}
 
	function pkcs5_pad($text, $blocksize) {
		$pad = $blocksize - (strlen($text) % $blocksize);
		return $text . str_repeat(chr($pad), $pad);
	}
 
	function pkcs5_unpad($text) {
		$pad = ord($text{strlen($text)-1});
		if ($pad > strlen($text)) return false;
		if (strspn($text, chr($pad), strlen($text) - $pad) != $pad) return false;
		return substr($text, 0, -1 * $pad);
	}
	
	function decodeSafeChars($text) {
		return strtr($text, '-_~', '+/=');
	}
	function encodeSafeChars($text) {
		return strtr($text, '+/=', '-_~');
	}
}
// These are older functions used for BC LELT tests and R2I LM registration
// They should be deprecated and phased out
function decryptURL($passedArgs) {

	$key = '123457980123457890';
	$passedData = str_replace(' ', '+', $passedArgs);
	$data = base64_decode($passedData);
	
	$key = sha1($key, true); // get 20 digit hash
	$key = base64_encode($key); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters
	
	$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	
	return mcrypt_decrypt(MCRYPT_RIJNDAEL_256, $key, $data, MCRYPT_MODE_ECB, $iv);
}

function encryptURL($plainArgs) {
	$args = $plainArgs.'&padding=00000000000000000000000000';
	
	$key = '123457980123457890';
	$key = sha1($key, true); // get 20 digit hash
	$key = base64_encode($key); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters
	
	$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	$encryptedArgs = mcrypt_encrypt(MCRYPT_RIJNDAEL_256, $key, $args, MCRYPT_MODE_ECB, $iv);
	
	return base64_encode($encryptedArgs);
}
