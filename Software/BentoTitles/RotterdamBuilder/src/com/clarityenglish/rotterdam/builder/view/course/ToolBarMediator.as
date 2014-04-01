package com.clarityenglish.rotterdam.builder.view.course {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
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
			
			// gh#91 This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.menuXHTML) view.href = bentoProxy.menuXHTML.href;
			
			// gh#91 What is the state to start in?
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			if (courseProxy) {
				view.previewMode = courseProxy.isPreviewMode;
				view.isEditable = courseProxy.isEditable;
				view.isOwner = courseProxy.isOwner;
				view.isCollaborator = courseProxy.isCollaborator;
				view.isPublisher = courseProxy.isPublisher;
			}	
			
			view.saveCourse.add(onSaveCourse);
			view.addText.add(onAddText);
			view.addPDF.add(onAddPDF);
			view.addImage.add(onAddImage);
			view.addAudio.add(onAddAudio);
			view.addVideo.add(onAddVideo);
			view.addExercise.add(onAddExercise);
			view.addAuthoring.add(onAddAuthoring);
			view.formatText.add(onFormatText);
			view.preview.add(onPreview);
			view.backToEditor.add(onBackToEditor);
			//gh #221
			view.addLink.add(onAddLink);
			view.cancelLink.add(onCancelLink);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.saveCourse.remove(onSaveCourse);
			view.addText.remove(onAddText);
			view.addPDF.remove(onAddPDF);
			view.addImage.remove(onAddImage);
			view.addAudio.remove(onAddAudio);
			view.addVideo.remove(onAddVideo);
			view.addExercise.remove(onAddExercise);
			view.addAuthoring.remove(onAddAuthoring);
			view.formatText.remove(onFormatText);
			view.preview.remove(onPreview);
			view.backToEditor.remove(onBackToEditor);
			view.addLink.remove(onAddLink);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.PREVIEW_SHOWN,
				RotterdamNotifications.PREVIEW_HIDDEN,
				RotterdamNotifications.TEXT_SELECTED,
				RotterdamNotifications.WIDGET_EDIT,
				RotterdamNotifications.WIDGET_SELECT,
				RotterdamNotifications.CAPTION_SELECTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			switch (note.getName()) {
				case RotterdamNotifications.TEXT_SELECTED:
					// gh#873
					if (!view.previewMode)
						view.setCurrentTextFormat(note.getBody() as TextLayoutFormat);
					break;
				case RotterdamNotifications.WIDGET_SELECT:
					view.currentEditingWidget = null;
					break;
				case RotterdamNotifications.WIDGET_EDIT:
					view.currentEditingWidget = note.getBody() as XML;
					break;
				case RotterdamNotifications.CAPTION_SELECTED:
					view.urlCaption = note.getBody().caption as String;
					view.urlString = note.getBody().urlString as String;
					break;
				case RotterdamNotifications.PREVIEW_SHOWN:
				case RotterdamNotifications.PREVIEW_HIDDEN:
					view.previewMode = courseProxy.isPreviewMode;
					break;
			}
		}
		
		protected function onSaveCourse():void {
			facade.sendNotification(RotterdamNotifications.COURSE_SAVE);
		}
		
		protected function onAddText(options:Object, widget:XML):void {
			if (widget) options.node = widget; // gh#115 - edit an existing widget
			facade.sendNotification(RotterdamNotifications.TEXT_WIDGET_ADD, options);
		}
		
		protected function onAddPDF(options:Object, widget:XML, title:String = null):void {
			if (title) options.title = title;
			if (widget) options.node = widget; // gh#115 - edit an existing widget
			facade.sendNotification(RotterdamNotifications.PDF_WIDGET_ADD, options);
		}
		
		protected function onAddImage(options:Object, widget:XML, title:String = null):void {
			if (title) options.title = title;
			if (widget) {
				options.node = widget; // gh#115 - edit an existing widget
				options.span = widget.@span; // gh#312
			} else {
				options.span = 1;
			}
			facade.sendNotification(RotterdamNotifications.IMAGE_WIDGET_ADD, options);
		}
		
		protected function onAddAudio(options:Object, widget:XML, title:String = null):void {
			if (title) options.title = title;
			if (widget) options.node = widget; // gh#115 - edit an existing widget
			facade.sendNotification(RotterdamNotifications.AUDIO_WIDGET_ADD, options);
		}
		
		protected function onAddVideo(options:Object, widget:XML):void {
			if (widget) options.node = widget; // gh#115 - edit an existing widget
			facade.sendNotification(RotterdamNotifications.VIDEO_WIDGET_ADD, options);
		}
		
		// gh#305
		protected function onAddExercise(options:Object, widget:XML, title:String):void {
			options.title = title
			if (widget) options.node = widget; // gh#115 - edit an existing widget				
			facade.sendNotification(RotterdamNotifications.EXERCISE_WIDGET_ADD, options);
		}
		
		protected function onAddAuthoring(options:Object, widget:XML):void {
			if (widget) options.node = widget; // gh#115 - edit an existing widget				
			facade.sendNotification(RotterdamNotifications.AUTHORING_WIDGET_ADD, options);
		}
		
		protected function onFormatText(options:Object):void {
			facade.sendNotification(RotterdamNotifications.TEXT_FORMAT, options);
		}
		
		protected function onPreview():void {
			facade.sendNotification(RotterdamNotifications.PREVIEW_SHOW, true);
		}
		
		protected function onBackToEditor():void {
			facade.sendNotification(RotterdamNotifications.PREVIEW_HIDE, false);
		}
		
		// gh#221
		protected function onAddLink(webUrlString:String, captionString:String ):void {
			var linkStrings:Object = new Object();
			linkStrings.webUrlString = webUrlString;
			linkStrings.captionString = captionString;
			facade.sendNotification(RotterdamNotifications.WEB_URL_ADD, linkStrings);
		}
		
		// gh#221
		protected function onCancelLink():void {
			facade.sendNotification(RotterdamNotifications.WEB_URL_CANCEL);
		}
	}
}
