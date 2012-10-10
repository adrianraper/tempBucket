package com.clarityenglish.rotterdam.view.unit {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.utils.setTimeout;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class UnitMediator extends BentoMediator implements IMediator {
		
		public function UnitMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():UnitView {
			return viewComponent as UnitView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// TODO: Hacky!  Do this properly for the non-prototype version.
			setTimeout(function():void {
				var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
				view.widgetCollection = courseProxy.widgetCollection;
			}, 1000);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			AudioPlayer.stopAllAudio();
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.UNIT_STARTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case RotterdamNotifications.UNIT_STARTED:
					var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
					view.widgetCollection = courseProxy.widgetCollection;
					break;
			}
		}
		
	}
}
