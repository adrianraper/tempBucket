package com.clarityenglish.rotterdam.builder.view.courseeditor {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
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
			
			view.saveCourse.add(onSave);
			
			// For the moment hardcode the course path
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.href = new Href(Href.XHTML, "5058678f9a2b1/menu.xml", configProxy.getConfig().paths.content);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.saveCourse.remove(onSave);
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
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
		
		private function onSave(xhtml:XHTML):void {
			facade.sendNotification(RotterdamNotifications.COURSE_SAVE, xhtml);
		}
		
	}
}
