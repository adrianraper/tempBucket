package com.clarityenglish.ielts.view.login {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	
	public class LoginView extends BentoView implements LoginComponent {
		
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