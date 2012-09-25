﻿package com.clarityenglish.rotterdam.builder.view.courseeditor {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import flashx.textLayout.formats.TextLayoutFormat;
	
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
			view.formatText.add(onFormatText);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.saveCourse.remove(onSaveCourse);
			view.addText.remove(onAddText);
			view.addPDF.remove(onAddPDF);
			view.addVideo.remove(onAddVideo);
			view.formatText.remove(onFormatText);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.TEXT_SELECTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case RotterdamNotifications.TEXT_SELECTED:
					view.setCurrentTextFormat(note.getBody() as TextLayoutFormat);
					break;
			}
		}
		
		protected function onSaveCourse():void {
			facade.sendNotification(RotterdamNotifications.COURSE_SAVE);
		}
		
		protected function onAddText(options:Object):void {
			facade.sendNotification(RotterdamNotifications.TEXT_WIDGET_ADD, options);
		}
		
		protected function onAddPDF(options:Object):void {
			facade.sendNotification(RotterdamNotifications.PDF_WIDGET_ADD, options);
		}
		
		protected function onAddVideo(options:Object):void {
			facade.sendNotification(RotterdamNotifications.VIDEO_WIDGET_ADD, options);
		}
		
		protected function onFormatText(options:Object):void {
			facade.sendNotification(RotterdamNotifications.TEXT_FORMAT, options);
		}
		
		
	}
}
