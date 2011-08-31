package com.clarityenglish.ielts.view.login {
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class LoginView extends SkinnableComponent implements LoginComponent {
		
		public function LoginView() {
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName,instance);
			
			switch (instance) {
				
			}
		}

		public function setCopyProvider(copyProvider:CopyProvider):void {
			
		}

		public function showInvalidLogin():void {
			
		}

		public function clearData():void {
			
		}

	}
}