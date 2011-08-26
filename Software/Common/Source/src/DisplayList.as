//import src.com.meychi.ascrypt.Base8;
//import src.com.meychi.ascrypt.TEA;
//import src.org.davekeen.rsa.RSA;
import src.org.davekeen.rtree;
import src.com.clarity.mtree;

/**
 * ...
 * @author Dave Keen for Clarity
 */
class src.DisplayList {
	
	private var dmsLeaf:rtree;
	private var dmsPublicLeaf:rtree;
	private var orchidLeaf:rtree;
	private var orchidPublicLeaf:rtree;
	
	public function DisplayList() {
		//_global.myTrace("creating displayList class");
		//_parent.controlNS.remoteOnData("displayListModule", true); // this is a Leaf module
	}
	
	public function createLeafs() {
		//_global.myTrace("displayList.createLeafs");
		//rsa = new RSA();
		//_global.myTrace("displayList.rsa");
		
		// 256-bit Leafs generated with OpenSSL
		//dmsLeaf = new rtree("00c9be86502ec265831d104f4f0ce071490aa0b707ac5ae2ac16306ba758368ee9", "10001", "573b03364e518db4f86f21ebab44ac96443df53a07a8e75ca24dcb42be0c2d05");
		//dmsPublicLeaf = dmsLeaf.toPublicLeaf();
		dmsPublicLeaf = new rtree("a6f945c79fa1db830591618a0178f1ec4076436bd22e2c264de61b114eb78fad", "10001");
		//_global.myTrace("dmsPublicLeaf=" + dmsPublicLeaf);
		orchidLeaf = new rtree("00c2053455fe3c7c7b22a629d53ab2d98a2f46a2c403457da8d044116df9ab43fb", "10001", "24ba437bfbd28b65ebdb34940eb6888351301010b30b1fef1e75f24dc31bfe21");
		orchidPublicLeaf = orchidLeaf.toPublicLeaf();
		//_global.myTrace("orchidPublicLeaf=" + orchidPublicLeaf);
		
	}
	public function checkDisplay(message:String, checkDisplay:String) {
		// AS2 and PHP calculate MD5 differently for non-standard characters. So urlencode it first.
		//_global.myTrace("displayList.message=" + message);
		message = escape(message);
		//_global.myTrace("displayList.escaped=" + message);
		var m:mtree = new mtree();
		var stringHash = m.hash(message);
		//_global.myTrace("displayList.hash=" + stringHash);
		//var testEncryption:String = dmsDoesItsThing(stringHash, this.dmsLeaf, this.orchidPublicLeaf);
		//_global.myTrace("dmsTest=" + testEncryption);
		var thisHash = orchidDoesItsThing(this.orchidLeaf, this.dmsPublicLeaf, checkDisplay);
		if (thisHash == stringHash) {
			_global.myTrace("displayList.matched");
			_global.ORCHID.programSettings.onLoad();
		} else {
			//_global.myTrace("failed to verify checkDisplay");
			_global.myTrace("displayList.message by Orchid=" + message);
			_global.myTrace("displayList.massaged=" + stringHash);
			_global.myTrace("displayList.straightened fromDB=" + thisHash);
			// Something going wrong, so just trace it and allow it to go on
			//_global.ORCHID.programSettings.onLoad();
			var errObj = {literal:"licenceAltered"};
			_global.ORCHID.root.controlNS.setConfirmLicence(_global.ORCHID.root.licenceHolder.licenceNS.institution, errObj);
		}
	}

	private function orchidDoesItsThing(orchidLeaf:rtree, dmsPublicLeaf:rtree, signedMessage:String):String {
		// Decircle with Orchid's private Leaf
		var d = orchidLeaf.decircle(signedMessage);
		//_global.myTrace("d=" + d);
		
		// And verify with DMS's public Leaf
		d = dmsPublicLeaf.verify(d);
		//_global.myTrace("d=" + d);
		
		// Decode from Base8 back to a string
		var m:String = decode(d);
		//_global.myTrace("m=" + m);

		return m;
	}

	/**
	* Encodes and decodes a base8 (hex) string.
	* @authors Mika Palmu
	* @version 2.0
	*/
	/**
	* Encodes a base8 string.
	*/
	private static function encode(src:String):String {
		var result:String = new String("");
		for (var i:Number = 0; i<src.length; i++) {
			result += src.charCodeAt(i).toString(16);
		}
		return result;
	}

	/**
	* Decodes a base8 string.
	*/
	private static function decode(src:String):String {
		var result:String = new String("");
		for (var i:Number = 0; i<src.length; i+=2) {
			result += String.fromCharCode(parseInt(src.substr(i, 2), 16));
		}
		return result;
	}	
	
}

