package com.clarityenglish.components {
	import spark.components.DropDownList;
	
	public class SpinnerDropDownList extends DropDownList {
		
		public function SpinnerDropDownList() {
			super();
			
			dropDownController = new SpinnerDropDownController();
		}
		
	}
}
