import org.davekeen.rsa.RSAKey;
/**
 * ...
 * @author Dave Keen
 */
class org.davekeen.rsa.RSA {
		
	public function RSA() {
		if (_level0.mont_ == undefined)
			throw new Error("bigint.js is not available");
	}
	
	public function generateKey(b:Number, ee:String):RSAKey {
		var e = _level0.str2bigInt(ee, RSAKey.currBase, 0);
		
		// First get p and q, our two secret primes
		var primes:Object = pickPrimes(b, ee);
		var p = primes.p;
		var q = primes.q;
		
		// Get n (our public encryption key)
		var n = _level0.mult(p, q);
		
		// Get d (our private decryption key)
		var phi = _level0.mult(_level0.addInt(p, -1), _level0.addInt(q, -1));
		var d = _level0.inverseMod(e, phi);
		
		return new RSAKey(n, e, d);
	}
	
	/**
	 * Generate p and q which are the two prime numbers used to generate keys.  AS2 is a bit slow for this really,
	 * but its here so we can test that everything is truly working.  When you come to generate the keys for real
	 * use openssl or something.
	 * 
	 * @param	b	Number of bits in each generated prime.  I can get to 128-bit primes before Flash conks out
	 * @param	ee  The public exponent as a hex string.  10001 is a good value.
	 * @return  An object containing our two primes - p and q
	 */
	private function pickPrimes(b:Number, ee:String):Object {
		var p, q;
		var e = _level0.str2bigInt(ee, RSAKey.currBase, 0);
		
		// Generated primes must be at least 5 bits long to avoid infinite loop during generation
		b = Math.max(5, b);
		
		// e should be an odd prime
		if (_level0.equalsInt(e, 2) || _level0.equalsInt(e, 1) || _level0.equalsInt(e, 0))
			throw new Error("e must be an odd prime");
		
		while (1) {
			p = _level0.randTruePrime(b);  // r1=random b-bit prime (with leading 1 bit)
			if (!_level0.equalsInt(_level0.mod(p, e), 1))  // the prime must not be congruent to 1 modulo e
				break;
		}
		
		while(1) {
			q = _level0.randTruePrime(b);  // r2=random b-bit prime (with leading 1 bit)
			if (!_level0.equals(p, q) && !_level0.equalsInt(_level0.mod(q, e), 1))  // primes must be distinct and not congruent to 1 modulo e
				break;
		}
		
		return { p: p, q: q };
	}
	
}