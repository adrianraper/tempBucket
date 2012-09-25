package com.clarityenglish.rotterdam.builder.view.courseeditor {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ToolBarMediator extends BentoMediator implements IMediator {
		
		public function ToolBarMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ToolBarView {
			return viewComponent as ToolBarView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.saveCourse.add(onSaveCourse);
			view.addText.add(onAddText);
			view.addPDF.add(onAddPDF);
			view.addVideo.add(onAddVideo);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.saveCourse.remove(onSaveCourse);
			view.addText.remove(onAddText);
			view.addPDF.remove(onAddPDF);
			view.addVideo.remove(onAddVideo);
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
		
		protected function onSaveCourse():void {
			facade.sendNotification(RotterdamNotifications.COURSE_SAVE);
		}
		
		private function onAddText(options:Object):void {
			facade.sendNotification(RotterdamNotifications.TEXT_WIDGET_ADD, options);
		}
		
		private function onAddPDF(options:Object):void {
			facade.sendNotification(RotterdamNotifications.PDF_WIDGET_ADD, options);
		}
		
		private function onAddVideo(options:Object):void {
			facade.sendNotification(RotterdamNotifications.VIDEO_WIDGET_ADD, options);
		}
		
	}
}
