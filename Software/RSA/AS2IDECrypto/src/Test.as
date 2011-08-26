import com.meychi.ascrypt.Base8;
import com.meychi.ascrypt.TEA;
import org.davekeen.rsa.RSA;
import org.davekeen.rsa.RSAKey;

/**
 * ...
 * @author Dave Keen
 */
class Test {
	
	private var rsa:RSA;
	
	public function Test() {
		
	}
	
	public function onLoad() {
		rsa = new RSA();
		
		// Generate keys for DMS and Orchid for testing purposes.
		//var dmsKey:RSAKey = rsa.generateKey(64, "10001");
		//var orchidKey:RSAKey = rsa.generateKey(64, "10001");
		
		// 256-bit keys generated with cert/generateKeys.bat
		var dmsKey:RSAKey = new RSAKey("00c9be86502ec265831d104f4f0ce071490aa0b707ac5ae2ac16306ba758368ee9", "10001", "573b03364e518db4f86f21ebab44ac96443df53a07a8e75ca24dcb42be0c2d05");
		var orchidKey:RSAKey = new RSAKey("00c2053455fe3c7c7b22a629d53ab2d98a2f46a2c403457da8d044116df9ab43fb", "10001", "24ba437bfbd28b65ebdb34940eb6888351301010b30b1fef1e75f24dc31bfe21");
		
		// Get just the public bit of the keys for DMS and Orchid,nas each will have the other's public key.  To do this in the
		// real application just use the above contstructor without the last parameter (as this is the private bit)
		var dmsPublicKey:RSAKey = dmsKey.toPublicKey();
		var orchidPublicKey:RSAKey = orchidKey.toPublicKey();
		
		var tests:Number = 1;
		var fails:Number = 0;
		for (var n:Number = 0; n < tests; n++)
			if (!simulateDMSOrchidExchange("My super secret string and stuff", dmsKey, orchidKey, dmsPublicKey, orchidPublicKey)) fails++;
			
		trace("PASS: " + (tests - fails));
		trace("FAIL: " + fails);
	}
	
	private function simulateDMSOrchidExchange(message:String, dmsKey:RSAKey, orchidKey:RSAKey, dmsPublicKey:RSAKey, orchidPublicKey:RSAKey):Boolean {
		var signedMessage:String = dmsDoesItsThing(message, dmsKey, orchidPublicKey);
		trace("Signed message: " + signedMessage);
		var decodedMessage:String = orchidDoesItsThing(orchidKey, dmsPublicKey, signedMessage);
		trace("Verified message: " + decodedMessage);
		return (decodedMessage == message);
	}
	
	private function dmsDoesItsThing(message:String, dmsKey:RSAKey, orchidPublicKey:RSAKey):String {
		// Use Base8 to turn the message into hex
		var m:String = Base8.encode(message);
		
		// Sign the message with DMS's private key
		var c = dmsKey.sign(m);
		
		// And then encrypt with Orchid's public key
		c = orchidPublicKey.encrypt(c);
		
		return c;
	}
	
	private function orchidDoesItsThing(orchidKey:RSAKey, dmsPublicKey:RSAKey, signedMessage:String):String {
		// Decrypt with Orchid's private key
		var d = orchidKey.decrypt(signedMessage);
		
		// And verify with DMS's public key
		d = dmsPublicKey.verify(d);
		
		// Decode from Base8 back to a string
		var m:String = Base8.decode(d);

		return m;
	}
	
}