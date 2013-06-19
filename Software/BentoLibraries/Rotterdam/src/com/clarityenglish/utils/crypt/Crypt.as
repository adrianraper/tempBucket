package com.clarityenglish.utils.crypt {
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.AESKey;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.crypto.symmetric.IVMode;
	import com.hurlant.crypto.symmetric.PKCS5;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;
	
	// gh#371
	public class Crypt {
		
		private var type:String;
		private var key:String;
		
		// I am not sure if this works with different cyphers, simple-des-ecb is the only tested one
		public function Crypt(type:String = "simple-des-ecb", key:String = "ClarityLanguageConsultantsLtd") {
			this.type = type;
			this.key = key;
		}
			
		public function encrypt(text:String = ''):String {
			var data:ByteArray = Hex.toArray(Hex.fromString(text));
			var byteKey:ByteArray = Hex.toArray(Hex.fromString(this.key));
			var pad:IPad = new PKCS5;
			var mode:ICipher = Crypto.getCipher(this.type, byteKey, pad);
			pad.setBlockSize(mode.getBlockSize());
			mode.encrypt(data);
			return Base64.encodeByteArray(data);
		}
		
		public function encryptURL(text:String = ''):String {
			return this.safeChars(encrypt(text));
		}
		
		public function safeChars(text:String):String {
			var r1:RegExp = /\+/g;
			var r2:RegExp = /\//g;
			var r3:RegExp = /=/g;
			return text.replace(r1,'-').replace(r2,'_').replace(r3,'~');
		}
	}
}
