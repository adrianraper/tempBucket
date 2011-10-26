package com.clarityenglish.common.vo.config {
	/**
	 * 
	 * @author Adrian
	 * This class is for errors raised by licence control, account validation, user validation etc
	 * It can be used as an object to be passed with notifications, or thrown as necessary
	 * The error number must be one of the constants.
	 * The error description is a fixed string coming from copyRecevier based on the language.
	 * The error context is a message that the creator of the error wants to use. It is not translated and is most likely for internal debugging.
	 * 
	 */
	public class BentoError extends Error {
		/**
		 * We use numbers as the key, with descriptions and actions
		 */
		public var errorNumber:uint;
		public var errorDescription:String;
		public var errorContext:String;

		// A lot of these come back from the database so numbers are needed.
		public static const ERROR_NO_SUCH_ACCOUNT:uint = 200;
		public static const ERROR_ACCOUNT_SUSPENDED:uint = 201;
		public static const ERROR_LICENCE_INVALID:uint = 202;
		public static const ERROR_LICENCE_EXPIRED:uint = 203;
		public static const ERROR_LICENCE_NOT_STARTED:uint = 204;
		public static const ERROR_TERMS_NOT_ACCEPTED:uint = 205;
		public static const ERROR_OUTSIDE_IP_RANGE:uint = 206;
		public static const ERROR_OUTSIDE_RU_RANGE:uint = 207;
		
		public static const ERROR_DATABASE_READING:uint = 100;
		
		public function BentoError(errNum:uint=0) {
			this.errorNumber = errNum;
			
			// Get the description for this number
			// TODO. Need the copyReceiver
			
		}
		
	}
}
