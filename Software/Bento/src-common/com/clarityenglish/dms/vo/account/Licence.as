package com.clarityenglish.dms.vo.account {
	
	/**
	* This duplicates information from other classes, but it is useful to keep it together
	* @author ...
	*/
	[RemoteClass(alias = "com.clarityenglish.dms.vo.account.Licence")]
	[Bindable]
	public class Licence {
		
		public var id:Number;
		public var maxStudents:uint;
		public var licenceClearanceDate:String;
		public var expiryDate:String;
		public var licenceStartDate:String;
		public var licenceClearanceFrequency:String;
		public var licenceType:Number;
		// gh#1090
		public var signInAs:uint;
		
		public var licenceControlStartDate:String;
		
		public function Licence() {
			
		}
		
	}
	
}