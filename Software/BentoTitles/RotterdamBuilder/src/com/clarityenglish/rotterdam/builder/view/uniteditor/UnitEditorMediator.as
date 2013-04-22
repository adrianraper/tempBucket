package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLinkEvent;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	import com.googlecode.bindagetools.Bind;
	
	import flash.utils.setTimeout;
	
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
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
			view.widgetEdit.add(onWidgetEdit);
			
			// gh#221
			view.addEventListener(WidgetLinkEvent.ADD_LINK, onAddLink);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			Bind.fromProperty(courseProxy, "widgetCollection").toProperty(view, "widgetCollection");
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.widgetSelect.remove(onWidgetSelect);
			view.widgetDelete.remove(onWidgetDelete);
			view.widgetEdit.remove(onWidgetEdit);
			
			AudioPlayer.stopAllAudio();
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				
			}
		}		
		
		protected function onWidgetSelect(widget:XML):void {
			facade.sendNotification(RotterdamNotifications.WIDGET_SELECT, widget);
		}
		
		protected function onWidgetDelete(widget:XML):void {
			facade.sendNotification(RotterdamNotifications.WIDGET_DELETE, widget);
		}
		
		protected function onWidgetEdit(widget:XML):void {
			facade.sendNotification(RotterdamNotifications.WIDGET_EDIT, widget);
		}
		
		// gh#221
		protected function onAddLink(event:WidgetLinkEvent):void {
			facade.sendNotification(RotterdamNotifications.WEB_URL_SELECT);
		}
	}
}
