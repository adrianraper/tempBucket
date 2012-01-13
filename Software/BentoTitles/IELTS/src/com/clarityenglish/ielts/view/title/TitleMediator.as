package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.ielts.IELTSNotifications;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class TitleMediator extends BentoMediator implements IMediator {
		
		public function TitleMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():TitleView {
			return viewComponent as TitleView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// Inject required data into the view
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.dateFormatter = configProxy.getDateFormatter();
			view.configID = configProxy.getConfig().configID;
			//view.productVersion = configProxy.getConfig().productVersion || "fullVersion";
			view.productVersion = configProxy.getProductVersion() || "fullVersion";
			view.productCode = configProxy.getProductCode() || 52;
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
			
		}
		
		override public function onRemove():void {
			super.onRemove();
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.EXERCISE_SHOW,
				BBNotifications.EXERCISE_RESTART,
				BBNotifications.EXERCISE_SECTION_FINISHED,
				IELTSNotifications.COURSE_SHOW,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.EXERCISE_SHOW:
					var href:Href = note.getBody() as Href;
					view.showExercise(href);
					break;
				case BBNotifications.EXERCISE_RESTART:
					// Restart an exercise by showing a clone of the current Href.  This will have the same effect as starting a new exercise
					// as the view will see that the Href is a new instance, hence resetting everything (but ultimately loading the same xml).
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					view.showExercise(bentoProxy.currentExercise.href.clone());
					break;
				case BBNotifications.EXERCISE_SECTION_FINISHED:
					view.showExercise(null);
					break;
				case IELTSNotifications.COURSE_SHOW:
					var course:XML = note.getBody() as XML;
					view.currentState = "zone";
					view.callLater(function():void {
						view.zoneView.course = course;
					});
					break;
			}
		}
		
	}
}
