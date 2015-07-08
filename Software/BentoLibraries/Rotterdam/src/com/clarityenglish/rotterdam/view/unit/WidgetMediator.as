package com.clarityenglish.rotterdam.view.unit {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.view.DynamicView;
import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
    import com.clarityenglish.bento.model.ExerciseProxy;
    import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.view.unit.widgets.AbstractWidget;
    import com.clarityenglish.rotterdam.view.unit.widgets.AuthoringWidget;

import flash.display.Stage;

import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import org.davekeen.util.StringUtils;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * Mediator for individual widget.  Note that unlike most mediators this does *not* extend BentoMediator since there is no need for XHTML loading or any of the
	 * other extra functionality BentoMediator provides.
	 */
	public class WidgetMediator extends Mediator implements IMediator {
		
		// gh#106
		private var exerciseMark:ExerciseMark = new ExerciseMark();
		
		public function WidgetMediator(mediatorName:String, viewComponent:Object) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():AbstractWidget {
			return viewComponent as AbstractWidget;
		}
		
		// gh#899 inject CopyProvider into the widget
		protected function injectCopy():void {
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			view.setCopyProvider(copyProvider);
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			
			// TODO: media/ should not be hardcoded
			view.mediaFolder = new Href(Href.XHTML, "media/", configProxy.getConfig().paths.content).url;
			view.thumbnailScript = configProxy.getConfig().remoteGateway + "/services/thumbnail.php";
			
			view.placeholder = copyProvider.getCopyForId("widgetPlaceholderText");
			
			view.setCopyProvider(copyProvider);
			
			// Widgets DON'T run off menu.xml, but they still need the href to construct relative hrefs (e.g. to load authoring exercises from the same folder)
			if (bentoProxy.menuXHTML) view.menuXHTMLHref = bentoProxy.menuXHTML.href;
			
			view.openMedia.add(onOpenMedia);
			view.openContent.add(onOpenContent);
			view.textSelected.add(onTextSelected);
			// gh#306
			view.captionSelected.add(onCaptionSelected);

			// gh#106
			view.playVideo.add(onPlay);
			view.playAudio.add(onPlay);

			view.exerciseSwitch.add(onExerciseSwitch);
			view.showMarking.add(onShowMarking);
            view.showFeedback.add(onShowFeedback);
			
			injectCopy();
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.openMedia.remove(onOpenMedia);
			view.openContent.remove(onOpenContent);
			view.textSelected.remove(onTextSelected);
			view.captionSelected.remove(onCaptionSelected);
			
			// gh#106
			view.playVideo.remove(onPlay);
			view.playAudio.remove(onPlay);
			
			view.exerciseSwitch.remove(onExerciseSwitch);
			view.showMarking.remove(onShowMarking);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.MEDIA_UPLOAD_START,
				RotterdamNotifications.MEDIA_UPLOAD_PROGRESS,
				RotterdamNotifications.MEDIA_UPLOADED,
				RotterdamNotifications.TEXT_FORMAT,
				RotterdamNotifications.WEB_URL_ADD,
				RotterdamNotifications.WEB_URL_CANCEL,
				RotterdamNotifications.WIDGET_RENAME,
				RotterdamNotifications.EXERCISE_GENERATOR_SAVED,
                BBNotifications.MARKING_SHOWN,
                BBNotifications.GOT_QUESTION_FEEDBACK,
                BBNotifications.EXERCISE_STARTED
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			// Upload actions - only take these actions if the notification is meant for us (i.e. the notification type is the node's id attribute)
			if (note.getType() == view.xml.@tempid) {
				switch (note.getName()) {
					case RotterdamNotifications.MEDIA_UPLOAD_START:
						view.setUploading(true);
						break;
					case RotterdamNotifications.MEDIA_UPLOAD_PROGRESS:
						view.setProgress(note.getBody() as ProgressEvent);
						break;
					case RotterdamNotifications.MEDIA_UPLOADED:
						view.setUploading(false);
						break;
				}
			}
			
			switch (note.getName()) {
				case RotterdamNotifications.EXERCISE_GENERATOR_SAVED:
					if (view.xml.hasOwnProperty("@href") && view.xml.@href.toString() == note.getBody().href)
						view.reloadContents();
					break;
                case BBNotifications.EXERCISE_STARTED:
                    var exercise:Exercise = note.getBody() as Exercise;
                    configureButtonVisibility(exercise);
                    break;
			}
			
			// Other actions only count if the widget is selected
			if (view.selected) {
				switch (note.getName()) {
					case RotterdamNotifications.TEXT_FORMAT:
						handleTextFormat(note.getBody());
						break;
					case RotterdamNotifications.WEB_URL_ADD: // gh#221
						onAddLink(note.getBody().webUrlString, note.getBody().captionString);
						view.widgetChrome.menuButton.enabled = true;
						break;
					case RotterdamNotifications.WEB_URL_CANCEL:
						view.widgetChrome.menuButton.enabled = true;
						break;
					case RotterdamNotifications.WIDGET_RENAME:
						view.widgetChrome.widgetCaptionTextInput.visible = true;
						view.widgetChrome.widgetCaptionTextInput.setFocus();
						view.widgetChrome.widgetCaptionLabel.visible = false;
						break;
                    case BBNotifications.MARKING_SHOWN:
                        configureButtonVisibility(note.getBody().exercise as Exercise);
                        break;
                    /*
                     case BBNotifications.GOT_QUESTION_FEEDBACK:
                     feedbackButtonVisibility(note.getBody() as Boolean);
                     break;
                     */
				}
			}
		}
        /*
         private function feedbackButtonVisibility(value:Boolean):void {
         if (view.feedbackButton) {
         view.feedbackButton.visible = view.feedbackButton.includeInLayout = value;
         }
         }
         */
        private function configureButtonVisibility(exercise:Exercise):void {
            // If there is exercise feedback then show the exercise feedback button
            // gh#413
            if (view is AuthoringWidget) {
                var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
                if ((view as AuthoringWidget).markingButton)
                    (view as AuthoringWidget).markingButton.visible = (view as AuthoringWidget).markingButton.includeInLayout = !(exerciseProxy.exerciseMarked) && exercise.hasQuestions() && !exercise.hasNoMarking();

                if ((view as AuthoringWidget).feedbackButton) {
                    if (exerciseProxy.exerciseMarked) {
                        if (exerciseProxy.hasExerciseFeedback())
                            (view as AuthoringWidget).hasExerciseFeedback = feedbackVisible = true;

                        if (exerciseProxy.hasQuestionFeedback())
                            (view as AuthoringWidget).hasQuestionFeedback = feedbackVisible = true;

                    } else {
                        var feedbackVisible:Boolean = false;
                    }
                    (view as AuthoringWidget).feedbackButton.visible = (view as AuthoringWidget).feedbackButton.includeInLayout = feedbackVisible;
                }
            }
        }

		protected function handleTextFormat(options:Object):void {
			view.widgetText.applyTextLayoutFormat(options.format);
		}
		
		protected function onAddLink(webUrlString:String, captionString:String):void {
			view.widgetText.addLink(webUrlString, captionString);
		}
		
		protected function onOpenMedia(widget:XML, src:String):void {
			if (StringUtils.beginsWith(src.toLowerCase(), "http")) {
				// gh#111 - if this is an absolute URL (i.e. starts with 'http') then navigate to it directly
				navigateToURL(new URLRequest(src), "_blank");
			} else {
				// gh#111 - otherwise construct the url inside the account folder
				var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
				
				// TODO: media/ should not be hardcoded
				var srcHref:Href = new Href(Href.XHTML, "media/" + src, configProxy.getConfig().paths.content);
				navigateToURL(new URLRequest(srcHref.url), "_blank");
			}
			
			// gh#925
			// gh#106
			// TODO: 120 seconds should not be hardcoded - come from config or literals or?
			exerciseMark.duration = 120;
			exerciseMark.UID = view.clarityUID;
			facade.sendNotification(BBNotifications.SCORE_WRITE, exerciseMark);
		}
		
		/**
		 * Open the Clarity content specified by the uid.
		 * 
		 * @param widget
		 * @param uid
		 */
		protected function onOpenContent(widget:XML, uid:String):void {
			// gh#234 Disable Clarity links on tablets
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			if (!configProxy.isPlatformTablet()) {
				facade.sendNotification(RotterdamNotifications.CONTENT_OPEN, uid);
			} else {
				var blockedWarning:BentoError = new BentoError();
				blockedWarning.errorContext = copyProvider.getCopyForId('contentBlockedWarning');
				blockedWarning.isFatal = false;
				facade.sendNotification(RotterdamNotifications.CONTENT_BLOCKED_ON_TABLET, blockedWarning);
			}
		}
		
		protected function onTextSelected(format:TextLayoutFormat):void {
			facade.sendNotification(RotterdamNotifications.TEXT_SELECTED, format);
		}
		
		protected function onCaptionSelected(caption:String, urlString:String):void {
			var linkObj:Object = new Object();
			linkObj.caption = caption;
			linkObj.urlString = urlString
			facade.sendNotification(RotterdamNotifications.CAPTION_SELECTED, linkObj);
		}
		
		// gh#106 (combined for video and audio)
		protected function onPlay(widget:XML):void {
			// TODO: 120 seconds should not be hardcoded - come from config or literals or?
			exerciseMark.duration = 120;
			exerciseMark.UID = view.clarityUID;
			facade.sendNotification(BBNotifications.SCORE_WRITE, exerciseMark);
		}
		
		protected function onExerciseSwitch(exercise:Exercise):void {
			facade.sendNotification(BBNotifications.EXERCISE_SWITCH, exercise);
		}

        // gh#1256 Send the view so marking can be aligned
		protected function onShowMarking(exercise:Exercise, widgetView:DynamicView=null):void {
			sendNotification(BBNotifications.MARKING_SHOW, { exercise: exercise, view: widgetView  } );
		}
        private function onShowFeedback(widgetView:DynamicView=null):void {
            sendNotification(BBNotifications.EXERCISE_SHOW_FEEDBACK, { view: widgetView });
        }
        private function onShowFeedbackReminder(value:String):void {
            sendNotification(BBNotifications.FEEDBACK_REMINDER_SHOW, value);
        }
	}
}
