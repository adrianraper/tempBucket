import org.davekeen.rsa.RSA;

/**
 * ...
 * @author Dave Keen
 */
class org.davekeen.rsa.RSAKey {
	
	/**
	 * The base for all operations - 16 (hex) seems to be the only base that works reliably
	 */
	public static var currBase:Number = 16;
	
	private var n;
	private var e;
	private var d;
	
	public function RSAKey(n, e, d) {
		if (_level0.mont_ == undefined)
			throw new Error("bigint.js is not available");
		
		// The parameters can either be hex strings or bigInts (which are really arrays)
		this.n = (n instanceof Array) ? n : _level0.str2bigInt(n, 16, 0);
		this.e = (n instanceof Array) ? e : _level0.str2bigInt(e, 16, 0);
		this.d = (n instanceof Array) ? d : _level0.str2bigInt(d, 16, 0);
	}
	
	/**
	 * Sign the message with the private key
	 * 
	 * @param	signedMessage
	 */
	public function sign(message:String) {
		if (d == undefined)
			throw new Error("This is a public key only");
		
		var bigIntMessage = _level0.str2bigInt(message, RSAKey.currBase, 0);
		
		if (_level0.greater(bigIntMessage, n))
			throw new Error("This message is larger than the modulus and cannot be signed");
		
		return _level0.bigInt2str(process(bigIntMessage, d), RSAKey.currBase);
	}
	
	/**
	 * Verify (i.e. unsign) the message with the public key.  Unless this is the matching public key to the private key that
	 * the message was originally signed with this will result in garbage.
	 * 
	 * @param	message
	 */
	public function verify(signedMessage:String) {
		return _level0.bigInt2str(process(_level0.str2bigInt(signedMessage, RSAKey.currBase, 0), e), RSAKey.currBase);
	}
	
	/**
	 * Encrypt the message - equivalent to signing with the public key
	 * 
	 * @param	message
	 */
	public function encrypt(message:String) {
		return verify(message);
	}
	
	/**
	 * Decrypt the message - equivalent to signing with the private key
	 * 
	 * @param	encryptedMessage
	 */
	public function decrypt(encryptedMessage:String) {
		return sign(encryptedMessage);
	}
	
	// m^x%n
	private function process(m, x) {
		return _level0.powMod(m, x, n);
	}
	
	public function getModulus() {
		return n;
	}
	
	public function toPublicKey():RSAKey {
		return new RSAKey(n, e);
	}
	
	public function toString():String {
		return("n: " + _level0.bigInt2str(n, RSAKey.currBase) + "\ne: " + _level0.bigInt2str(e, RSAKey.currBase) + "\nd: " + _level0.bigInt2str(d, RSAKey.currBase));
	}
	
}