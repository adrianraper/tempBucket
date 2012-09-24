﻿package com.clarityenglish.rotterdam.builder.view.courseeditor {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class CourseEditorMediator extends BentoMediator implements IMediator {
		
		public function CourseEditorMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():CourseEditorView {
			return viewComponent as CourseEditorView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.unitSelect.add(onUnitSelect);
			
			// For the moment hardcode the course path
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.href = new Href(Href.XHTML, "5058678f9a2b1/menu.xml", configProxy.getConfig().paths.content);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.unitSelect.remove(onUnitSelect);
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
			
			// When the XHTML has loaded into the course editor then the course has started
			facade.sendNotification(RotterdamNotifications.COURSE_START, xhtml);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.COURSE_STARTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case RotterdamNotifications.COURSE_STARTED:
					var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
					view.unitListCollection = courseProxy.unitCollection;
					break;
			}
		}
		
		protected function onUnitSelect(unit:XML):void {
			facade.sendNotification(RotterdamNotifications.UNIT_START, unit);
		}
		
	}
}
