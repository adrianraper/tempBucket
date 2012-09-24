package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class UnitEditorMediator extends BentoMediator implements IMediator {
		
		public function UnitEditorMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():UnitEditorView {
			return viewComponent as UnitEditorView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.widgetSelect.add(onWidgetSelect);
			view.widgetDelete.add(onWidgetDelete);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.widgetSelect.remove(onWidgetSelect);
			view.widgetDelete.remove(onWidgetDelete);
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
		
		private function onWidgetSelect(widget:XML):void {
			facade.sendNotification(RotterdamNotifications.WIDGET_SELECT, widget);
		}
		
		private function onWidgetDelete(widget:XML):void {
			facade.sendNotification(RotterdamNotifications.WIDGET_DELETE, widget);
		}
		
	}
}
