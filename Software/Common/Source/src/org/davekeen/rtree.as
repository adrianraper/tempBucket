//import src.org.davekeen.rsa.RSA;

/**
 * ...
 * @author Dave Keen
 */
class src.org.davekeen.rtree {
	
	/**
	 * The base for all operations - 16 (hex) seems to be the only base that works reliably
	 */
	public static var currBase:Number = 16;
	
	private var n;
	private var e;
	private var d;
	
	public function rtree(n, e, d) {
		//_global.myTrace("rtree");
		//_global.myTrace("_global.ORCHID.root.displayListHolder.mont_=" + _global.ORCHID.root.displayListHolder.mont_);
		if (_global.ORCHID.root.displayListHolder.mont_ == undefined) {
		//if (_global.ORCHID.root.displayListHolder.mont_ == undefined)
		// v6.5.5.5 But I don't have any catch mechanism
			//throw new Error("bigint.js is not available");
			//_global.myTrace("bigint.js is not available");
		}
		
		// The parameters can either be hex strings or bigInts (which are really arrays)
		this.n = (n instanceof Array) ? n : _global.ORCHID.root.displayListHolder.str2bigInt(n, 16, 0);
		this.e = (n instanceof Array) ? e : _global.ORCHID.root.displayListHolder.str2bigInt(e, 16, 0);
		this.d = (n instanceof Array) ? d : _global.ORCHID.root.displayListHolder.str2bigInt(d, 16, 0);
	}
	
	/**
	 * Sign the message with the private key
	 * 
	 * @param	signedMessage
	 */
	public function sign(message:String) {
		if (d == undefined) {
			//throw new Error("This is a public key only");
			//_global.myTrace("This is a public key only");
		}
		
		var bigIntMessage = _global.ORCHID.root.displayListHolder.str2bigInt(message, rtree.currBase, 0);
		
		if (_global.ORCHID.root.displayListHolder.greater(bigIntMessage, n)) {
			//throw new Error("This message is larger than the modulus and cannot be signed");
			//_global.myTrace("This message is larger than the modulus and cannot be signed");
		}
		
		return _global.ORCHID.root.displayListHolder.bigInt2str(process(bigIntMessage, d), rtree.currBase);
	}
	
	/**
	 * Verify (i.e. unsign) the message with the public key.  Unless this is the matching public key to the private key that
	 * the message was originally signed with this will result in garbage.
	 * 
	 * @param	message
	 */
	public function verify(signedMessage:String) {
		return _global.ORCHID.root.displayListHolder.bigInt2str(process(_global.ORCHID.root.displayListHolder.str2bigInt(signedMessage, rtree.currBase, 0), e), rtree.currBase);
	}
	
	/**
	 * Encrypt the message - equivalent to signing with the public key
	 * 
	 * @param	message
	 */
	public function encircle(message:String) {
		return verify(message);
	}
	
	/**
	 * Decrypt the message - equivalent to signing with the private key
	 * 
	 * @param	encryptedMessage
	 */
	public function decircle(eMessage:String) {
		return sign(eMessage);
	}
	
	// m^x%n
	private function process(m, x) {
		return _global.ORCHID.root.displayListHolder.powMod(m, x, n);
	}
	
	public function getModulus() {
		return n;
	}
	
	public function toPublicLeaf():rtree {
		return new rtree(n, e);
	}
	
	public function toString():String {
		return("n: " + _global.ORCHID.root.displayListHolder.bigInt2str(n, rtree.currBase) + "\ne: " + _global.ORCHID.root.displayListHolder.bigInt2str(e, rtree.currBase) + "\nd: " + _global.ORCHID.root.displayListHolder.bigInt2str(d, rtree.currBase));
	}
	
}