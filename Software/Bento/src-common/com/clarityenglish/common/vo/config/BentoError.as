package com.clarityenglish.common.vo.config {
	import mx.rpc.Fault;

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
	[Bindable]
	public class BentoError extends Error {
		/**
		 * We use numbers as the key, with descriptions and actions
		 */
		private var _errorNumber:uint;
		private var _errorDescription:String;
		private var _errorContext:String;
		private var _errorName:String;

		// A lot of these come back from the database so numbers are needed.
		public static const NO_SUCH_USER:String = 'no_such_user';
		public static const ERROR_NO_SUCH_ACCOUNT:uint = 200;
		public static const ERROR_ACCOUNT_SUSPENDED:uint = 201;
		public static const ERROR_LICENCE_INVALID:uint = 202;
		public static const ERROR_LICENCE_EXPIRED:uint = 203;
		public static const ERROR_LICENCE_NOT_STARTED:uint = 204;
		public static const ERROR_TERMS_NOT_ACCEPTED:uint = 205;
		public static const ERROR_OUTSIDE_IP_RANGE:uint = 206;
		public static const ERROR_OUTSIDE_RU_RANGE:uint = 207;

		public static const ERROR_FAILED_INSTANCE_CHECK:uint = 210;
		
		public static const ERROR_DATABASE_READING:uint = 100;
		public static const ERROR_DATABASE_WRITING:uint = 101;
		
		public static const ERROR_LOGIN_WRONG_DETAILS:uint = 102;
		public static const ERROR_LOGIN_USER_EXPIRED:uint = 103;

		public static const ERROR_CONTENT_MENU:uint = 301;
		public static const ERROR_CONTENT_EXERCISE:uint = 302;

		public static const ERROR_UNKNOWN:uint = 1;
		
		public function BentoError(errNum:uint = 0) {
			this.errorNumber = errNum;
			
			// Get the description for this number
			// TODO. Need the copyReceiver
		}
		
		public static function create(fault:Fault):BentoError {
			var bentoError:BentoError = new BentoError();
			bentoError.errorContext = fault.faultString;
			bentoError.errorNumber = fault.faultCode as uint;
			return bentoError;
		}
		
		public function fromObject(errObj:Object):void {
			if (errObj.errorNumber)
				errorNumber = errObj.errorNumber; 
			//if (errObj.errorDescription)
			//	errorDescription = errObj.errorDescription; 
			if (errObj.errorContext)
				errorContext = errObj.errorContext; 
		}
		
		public function get errorDescription():String {
			return getDescription(_errorNumber);
		}
		
		public function set errorNumber(value:uint):void {
			_errorNumber = value;
		}
		
		public function get errorNumber():uint {
			return _errorNumber;
		}
		
		public function set errorContext(value:String):void {
			_errorContext = value;
		}
		
		public function get errorContext():String {
			return _errorContext;
		}
		
		public function set errorName(value:String):void {
			_errorName = value;
		}
		
		public function get errorName():String {
			return _errorName;
		}
		
		private function getDescription(value:uint):String {
			// First turn the number into a name - based on the xml
			// This seems very odd!!
			switch (value) {
				case 200:
					errorName = 'no_such_user';
					return 'These user details are not recognised.';
					break;
				case BentoError.ERROR_FAILED_INSTANCE_CHECK:
					errorName = 'failed_instance_check';
					return 'Somebody else has logged in with the same details. Please try again.';
					break;
				case BentoError.ERROR_OUTSIDE_IP_RANGE:
					errorName = 'failed_instance_check';
					return 'This program can only be run from limited computers or through one website.';
					break;
				default:
					errorName = 'unknown';
					return 'An unrecognised error happened.';
			}
		}
		
	}
}
