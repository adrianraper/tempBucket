<?php

class RSAKey {
	
	const BASE = 16;

	private $n;
	private $e;
	private $d;
	
	function RSAKey($n, $e, $d = null) {
		$this->n = gmp_init($n, RSAKey::BASE);
		$this->e = gmp_init($e, RSAKey::BASE);
		if ($d) $this->d = gmp_init($d, RSAKey::BASE);
	}
	
	/**
	 * Sign the message with the private key
	 * 
	 * @param	signedMessage
	 */
	public function sign($message) {
		if ($this->d == null)
			throw new Exception("This is a public key only");
		
		$gmpMessage = gmp_init($message, RSAKey::BASE);
		
		if (gmp_cmp($gmpMessage, $this->n) > 0)
			throw new Exception("This message is larger than the modulus and cannot be signed");
			
		return gmp_strval($this->process($gmpMessage, $this->d), RSAKey::BASE);
	}
	
	/**
	 * Verify (i.e. unsign) the message with the public key.  Unless this is the matching public key to the private key that
	 * the message was originally signed with this will result in garbage.
	 * 
	 * @param	message
	 */
	public function verify($signedMessage) {
		return gmp_strval($this->process(gmp_init($signedMessage, RSAKey::BASE), $this->e), RSAKey::BASE);
	}
	
	/**
	 * Encrypt the message - equivalent to signing with the public key
	 * 
	 * @param	message
	 */
	public function encrypt($message) {
		return $this->verify($message);
	}
	
	/**
	 * Decrypt the message - equivalent to signing with the private key
	 * 
	 * @param	encryptedMessage
	 */
	public function decrypt($encryptedMessage) {
		return $this->sign($encryptedMessage);
	}
	
	// m^x%n
	private function process($m, $x) {
		return gmp_powm($m, $x, $this->n);
	}
	
	public function getModulus() {
		return $this->n;
	}
	
	public function toPublicKey() {
		return new RSAKey($this->n, $this->e);
	}
	
	public function toString() {
		return("n: ".gmp_strval($this->n, RSAKey::BASE)."<br/>e: ".gmp_strval($this->e, RSAKey::BASE)."<br/>d: ".gmp_strval($this->d, RSAKey::BASE));
	}

}

?>
