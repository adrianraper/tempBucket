package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	import com.googlecode.bindagetools.Bind;
	
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
			view.widgetRename.add(onWidgetRename); // gh#187
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			Bind.fromProperty(courseProxy, "widgetCollection").toProperty(view, "widgetCollection");
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.widgetSelect.remove(onWidgetSelect);
			view.widgetDelete.remove(onWidgetDelete);
			view.widgetEdit.remove(onWidgetEdit);
			view.widgetRename.remove(onWidgetRename);
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
		
		// gh#187
		protected function onWidgetRename():void {
			facade.sendNotification(RotterdamNotifications.WIDGET_RENAME);
		}
	}
}
