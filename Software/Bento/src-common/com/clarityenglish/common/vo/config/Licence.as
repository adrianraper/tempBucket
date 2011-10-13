package com.clarityenglish.common.vo.config
{
	public class Licence
	{
		public static const LEARNER_TRACKING:uint = 1;
		public static const ANONYMOUS_ACCESS:uint = 2;
		public static const CONCURRENT_TRACKING:uint = 3;
		public static const TRANSFERABLE_TRACKING:uint = 4;
		public static const INDIVIDUAL:uint = 5;
		
		public var type:uint;
		public var size:uint;
		public var expiryDate:String;

		public function Licence() {
			
		}
		
	}
}