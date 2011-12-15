package com.clarityenglish.ielts.view.account {
	import com.clarityenglish.bento.view.base.BentoView;
	import spark.components.Button;
	import spark.components.TextInput;
	
	public class AccountView extends BentoView {
				
		[SkinPart(required="true")]
		public var newPassword:TextInput;
		
		[SkinPart(required="true")]
		public var confirmPassword:TextInput;
		
		[SkinPart(required="true")]
		public var saveChangesButton:Button;
	}
	
}