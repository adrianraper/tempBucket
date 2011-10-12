package com.clarityenglish.ielts.view.module {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ModuleMediator extends BentoMediator implements IMediator {
		
		public function ModuleMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ModuleView {
			return viewComponent as ModuleView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.exerciseSelect.add(onExerciseSelect);
			// AR inject data to the view.
			injectUserDetails();
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.exerciseSelect.removeAll();
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				//CommonNotifications.LOGGED_IN,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				//case CommonNotifications.LOGGED_IN:
				//	onUserDetailsLoaded();
				//	break;
			}
		}
		
		/**
		 * An exercise was selected. Based on the extension of the Href we either want to open an exercise or open a pdf.
		 * 
		 * @param href
		 */
		private function onExerciseSelect(href:Href):void {
			sendNotification(IELTSNotifications.HREF_SELECTED, href);
		}
		
		/**
		 * Inject the user details into the view from the model
		 * 
		 * @param 
		 */
		private function injectUserDetails():void {
			
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;
		}
	}
}
