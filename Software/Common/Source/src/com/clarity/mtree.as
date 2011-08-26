/**
* class md5 - AS2.0 - porting from original Paul Johnston JavaScript functions
* This is just a porting from Paul Johnston's JavaScript md5 implementation.
* Porting created by Andrea Giammarchi [ andr3a ] [ www.3site.it ] on 05/07/2004
* 
* Version 1.0 Copyright (C) Andrea Giammarchi 2004
* 
* NOTE 1: this class is compatible with Flash Player 6 r65
* NOTE 2: this is not an official class, use it carefully 
* ------------------------------------------------------------------------------
* 
* [ ORIGINAL JAVASCRIPT COPYRIGHT AND SIGNATURE ]
* A JavaScript implementation of the RSA Data Security, Inc. md5 Message
* Digest Algorithm, as defined in RFC 1321.
* Version 2.1 Copyright (C) Paul Johnston 1999 - 2002.
* Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
* Distributed under the BSD License
* See http://pajhome.org.uk/crypt/md5 for more info.
* ------------------------------------------------------------------------------
*
* [ HOW TO USE ]:Example
* var m:md5 = new md5();
* trace( m.hash( "my string" ) );
* // will return 2ba81a47c5512d9e23c435c1f29373cb
* ------------------------------------------------------------------------------
*/
class src.com.clarity.mtree {
	
	/* private vars b64pad, chrsz */
	private var b64pad:String  = new String( "" );
	private var chrsz:Number = new Number( 8 );
	
	/**
	* constructor, create an mtree Object
	* @param	String	base-64 pad character. "=" for strict RFC compliance
	* @param	Number	bits per input character. 8 - ASCII; 16 - Unicode
	*/
	function mtree( b64pad:String, chrsz:Number ) {
		if( b64pad != undefined ) {
			this.b64pad = b64pad;
		}
		if( chrsz != undefined && chrsz == 8 || chrsz == 16 ) {
			this.chrsz = chrsz;
		}
	}
	
	/**
	* public method, convert string in mtree hash and return them.
	* @param	String	string to hash in mtree
	* @return	String	mtree hashed string
	*/
	public function hash( s:String ):String {
		return hex_mtree( s );
	}
	
	/**
	* These are the functions you'll usually want to call
	* They take string arguments and return either hex or base-64 encoded strings
	*/
	private function hex_mtree( s:String ):String {
		return binl2hex(core_mtree(str2binl(s), s.length*chrsz));
	}
	private function b64_mtree( s:String ):String {
		return binl2b64(core_mtree(str2binl(s), s.length*chrsz));
	}
	private function str_mtree( s:String ):String {
		return binl2str(core_mtree(str2binl(s), s.length*chrsz));
	}
	private function hex_hmac_mtree( key:String, data:String ):String {
		return binl2hex(core_hmac_mtree(key, data));
	}
	private function b64_hmac_mtree( key:String, data:String ):String {
		return binl2b64(core_hmac_mtree(key, data));
	}
	private function str_hmac_mtree( key:String, data:String ):String {
		return binl2str(core_hmac_mtree(key, data));
	}
	
	/**
	* These functions implement the four basic operations the algorithm uses.
	*/
	private function mtree_cmn( q:Number, a:Number, b:Number, x:Number, s:Number, t:Number ):Number {
		return safe_add(bit_rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b);
	}
	private function mtree_ff( a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number ):Number {
		return mtree_cmn((b & c) | ((~b) & d), a, b, x, s, t);
	}
	private function mtree_gg( a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number ):Number {
		return mtree_cmn((b & d) | (c & (~d)), a, b, x, s, t);
	}
	private function mtree_hh( a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number ):Number {
		return mtree_cmn(b ^ c ^ d, a, b, x, s, t);
	}
	private function mtree_ii( a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number ):Number {
		return mtree_cmn(c ^ (b | (~d)), a, b, x, s, t);
	}
	
	/**
	* Calculate the mtree of an array of little-endian words, and a bit length
	*/
	private function core_mtree( x:Array, len:Number ):Array {
		x[len >> 5] |= 0x80 << ((len)%32);
		x[(((len+64) >>> 9) << 4)+14] = len;
		var a:Number = 1732584193;
		var b:Number = -271733879;
		var c:Number = -1732584194;
		var d:Number = 271733878;
		for( var i:Number = 0; i < x.length; i += 16 ) {
			var olda:Number = a;
			var oldb:Number = b;
			var oldc:Number = c;
			var oldd:Number = d;
			a = mtree_ff(a, b, c, d, x[i+0], 7, -680876936);
			d = mtree_ff(d, a, b, c, x[i+1], 12, -389564586);
			c = mtree_ff(c, d, a, b, x[i+2], 17, 606105819);
			b = mtree_ff(b, c, d, a, x[i+3], 22, -1044525330);
			a = mtree_ff(a, b, c, d, x[i+4], 7, -176418897);
			d = mtree_ff(d, a, b, c, x[i+5], 12, 1200080426);
			c = mtree_ff(c, d, a, b, x[i+6], 17, -1473231341);
			b = mtree_ff(b, c, d, a, x[i+7], 22, -45705983);
			a = mtree_ff(a, b, c, d, x[i+8], 7, 1770035416);
			d = mtree_ff(d, a, b, c, x[i+9], 12, -1958414417);
			c = mtree_ff(c, d, a, b, x[i+10], 17, -42063);
			b = mtree_ff(b, c, d, a, x[i+11], 22, -1990404162);
			a = mtree_ff(a, b, c, d, x[i+12], 7, 1804603682);
			d = mtree_ff(d, a, b, c, x[i+13], 12, -40341101);
			c = mtree_ff(c, d, a, b, x[i+14], 17, -1502002290);
			b = mtree_ff(b, c, d, a, x[i+15], 22, 1236535329);
			a = mtree_gg(a, b, c, d, x[i+1], 5, -165796510);
			d = mtree_gg(d, a, b, c, x[i+6], 9, -1069501632);
			c = mtree_gg(c, d, a, b, x[i+11], 14, 643717713);
			b = mtree_gg(b, c, d, a, x[i+0], 20, -373897302);
			a = mtree_gg(a, b, c, d, x[i+5], 5, -701558691);
			d = mtree_gg(d, a, b, c, x[i+10], 9, 38016083);
			c = mtree_gg(c, d, a, b, x[i+15], 14, -660478335);
			b = mtree_gg(b, c, d, a, x[i+4], 20, -405537848);
			a = mtree_gg(a, b, c, d, x[i+9], 5, 568446438);
			d = mtree_gg(d, a, b, c, x[i+14], 9, -1019803690);
			c = mtree_gg(c, d, a, b, x[i+3], 14, -187363961);
			b = mtree_gg(b, c, d, a, x[i+8], 20, 1163531501);
			a = mtree_gg(a, b, c, d, x[i+13], 5, -1444681467);
			d = mtree_gg(d, a, b, c, x[i+2], 9, -51403784);
			c = mtree_gg(c, d, a, b, x[i+7], 14, 1735328473);
			b = mtree_gg(b, c, d, a, x[i+12], 20, -1926607734);
			a = mtree_hh(a, b, c, d, x[i+5], 4, -378558);
			d = mtree_hh(d, a, b, c, x[i+8], 11, -2022574463);
			c = mtree_hh(c, d, a, b, x[i+11], 16, 1839030562);
			b = mtree_hh(b, c, d, a, x[i+14], 23, -35309556);
			a = mtree_hh(a, b, c, d, x[i+1], 4, -1530992060);
			d = mtree_hh(d, a, b, c, x[i+4], 11, 1272893353);
			c = mtree_hh(c, d, a, b, x[i+7], 16, -155497632);
			b = mtree_hh(b, c, d, a, x[i+10], 23, -1094730640);
			a = mtree_hh(a, b, c, d, x[i+13], 4, 681279174);
			d = mtree_hh(d, a, b, c, x[i+0], 11, -358537222);
			c = mtree_hh(c, d, a, b, x[i+3], 16, -722521979);
			b = mtree_hh(b, c, d, a, x[i+6], 23, 76029189);
			a = mtree_hh(a, b, c, d, x[i+9], 4, -640364487);
			d = mtree_hh(d, a, b, c, x[i+12], 11, -421815835);
			c = mtree_hh(c, d, a, b, x[i+15], 16, 530742520);
			b = mtree_hh(b, c, d, a, x[i+2], 23, -995338651);
			a = mtree_ii(a, b, c, d, x[i+0], 6, -198630844);
			d = mtree_ii(d, a, b, c, x[i+7], 10, 1126891415);
			c = mtree_ii(c, d, a, b, x[i+14], 15, -1416354905);
			b = mtree_ii(b, c, d, a, x[i+5], 21, -57434055);
			a = mtree_ii(a, b, c, d, x[i+12], 6, 1700485571);
			d = mtree_ii(d, a, b, c, x[i+3], 10, -1894986606);
			c = mtree_ii(c, d, a, b, x[i+10], 15, -1051523);
			b = mtree_ii(b, c, d, a, x[i+1], 21, -2054922799);
			a = mtree_ii(a, b, c, d, x[i+8], 6, 1873313359);
			d = mtree_ii(d, a, b, c, x[i+15], 10, -30611744);
			c = mtree_ii(c, d, a, b, x[i+6], 15, -1560198380);
			b = mtree_ii(b, c, d, a, x[i+13], 21, 1309151649);
			a = mtree_ii(a, b, c, d, x[i+4], 6, -145523070);
			d = mtree_ii(d, a, b, c, x[i+11], 10, -1120210379);
			c = mtree_ii(c, d, a, b, x[i+2], 15, 718787259);
			b = mtree_ii(b, c, d, a, x[i+9], 21, -343485551);
			a = safe_add(a, olda);
			b = safe_add(b, oldb);
			c = safe_add(c, oldc);
			d = safe_add(d, oldd);
		}
		return Array(a, b, c, d);
	}
	
	/**
	* Calculate the HMAC-mtree, of a key and some data
	*/
	private function core_hmac_mtree( key:String, data:String ):Array {
		var bkey:Array = new Array( str2binl( key ) );
		if( bkey.length > 16 ) {
			bkey = core_mtree(bkey, key.length*chrsz);
		}
		var ipad:Array = new Array(16)
		var opad:Array = new Array(16);
		for( var i:Number = 0; i < 16; i++ ) {
			ipad[i] = bkey[i] ^ 0x36363636;
			opad[i] = bkey[i] ^ 0x5C5C5C5C;
		}
		var hash:Array = new Array( core_mtree( ipad.concat( str2binl( data  )), 512 + data.length*chrsz ) );
		return core_mtree(opad.concat(hash), 512+128);
	}
	
	/**
	* Add integers, wrapping at 2^32. This uses 16-bit operations internally
	* to work around bugs in some JS interpreters.
	*/
	private function safe_add( x:Number, y:Number ):Number {
		var lsw:Number = new Number( (x & 0xFFFF) + (y & 0xFFFF) );
		var msw:Number = new Number( (x >> 16) + (y >> 16) + (lsw >> 16) );
		return (msw << 16) | (lsw & 0xFFFF);
	}
		
	/**
	* Bitwise rotate a 32-bit number to the left.
	*/
	private function bit_rol( num:Number, cnt:Number ):Number {
		return (num << cnt) | (num >>> (32-cnt));
	}
	
	/**
	* Convert a string to an array of little-endian words
	* If chrsz is ASCII, characters >255 have their hi-byte silently ignored.
	*/
	private function str2binl( str:String ):Array {
		var bin:Array = new Array();
		var mask:Number = ( 1 << chrsz ) - 1;
		for( var i:Number = 0; i < str.length * chrsz; i += chrsz ) {
			bin[i >> 5] |= (str.charCodeAt(i/chrsz) & mask) << (i%32);
		}
		return bin;
	}
	
	/**
	* Convert an array of little-endian words to a string
	*/
	private function binl2str( bin:Array ):String {
		var str:String = new String( "" );
		var mask:Number = ( 1 << chrsz )-1;
		for( var i:Number = 0; i < bin.length * 32; i += chrsz ) {
			str += String.fromCharCode( ( bin[i >> 5] >>> ( i % 32 ) ) & mask );
		}
		return str;
	}
	
	/**
	* Convert an array of little-endian words to a hex string.
	*/
	private function binl2hex( binarray:Array ):String {
		var hex_tab:String = "0123456789abcdef";
		var str:String = new String( "" );
		for( var i:Number = 0; i < binarray.length * 4; i++ ) {
			str += hex_tab.charAt( ( binarray[i>>2] >> ( ( i%4 ) * 8 + 4 ) ) & 0xF ) + 
			hex_tab.charAt( ( binarray[i>>2] >> ( ( i%4 ) * 8  ) ) & 0xF );
		}
		return str;
	}
	
	/**
	* Convert an array of little-endian words to a base-64 string
	*/
	private function binl2b64( binarray:Array ):String {
		var tab:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		var str:String = new String( "" );
		for( var i:Number = 0; i < binarray.length * 4; i += 3 ) {
			var triplet:Object = (((binarray[i   >> 2] >> 8 * ( i   %4)) & 0xFF) << 16) 
			| (((binarray[i+1 >> 2] >> 8 * ((i+1)%4)) & 0xFF) << 8 ) 
			| ((binarray[i+2 >> 2] >> 8 * ((i+2)%4)) & 0xFF);
			for(var j:Number = 0; j < 4; j++) {
				if( i * 8 + j * 6 > binarray.length * 32 ) {
					str += b64pad;
				}
				else {
					str += tab.charAt( ( triplet >> 6 * ( 3 - j ) ) & 0x3F );
				}
			}
		}
		return str;
	}
}