package com.clarityenglish.bento.view.exercise {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.base.events.BentoEvent;
	import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
	import com.clarityenglish.bento.view.timer.TimerComponent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.events.AudioPlayerEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.controls.Text;
import mx.core.FlexGlobals;
import mx.managers.FocusManager;

import spark.components.Button;
	
	import org.osflash.signals.Signal;

	[SkinState("exercise")]
	[SkinState("other")]
	public class ExerciseView extends BentoView {

		[SkinPart]
		public var backToMenuButton:Button;

		[SkinPart]
		public var startAgainButton:Button;

		[SkinPart]
		public var forwardButton:Button;

		[SkinPart]
		public var backButton:Button;

		[SkinPart]
		public var markingButton:Button;

		[SkinPart]
		public var feedbackButton:Button;

		[SkinPart]
		public var printButton:Button;

		[SkinPart]
		public var recorderButton:Button;

		[SkinPart]
		public var ruleButton:Button;

		[SkinPart]
		public var logoutButton:Button;

		[SkinPart(required="true")]
		public var dynamicView:DynamicView;

		[SkinPart]
		public var timerComponent:TimerComponent;

		[Bindable]
		public var exerciseTitle:String;

		[Bindable]
		public var isMarked:Boolean;

		[Bindable]
		public var noMarking:Boolean;

		[Bindable]
		public var hasQuestions:Boolean;

		[Bindable]
		public var hasPrintStylesheet:Boolean;

		[Bindable]
		public var hasVideoScript:Boolean;

		[Bindable]
		public var footerLabel:Text;;

		[Bindable]
		public var isPlatformiPad:Boolean;

		[Bindable]
		public var isPlatformTablet:Boolean;

		// Timer total time
		private var _timerTotalTime:Array = [];
		private var _isTimereTotalTimeChange;
		private var _timerSectionLabels:Array = [];
		private var _courseCaption:String;

		// gh#388
		// gh#413
		private var _hasExerciseFeedback:Boolean;
		private var _hasQuestionFeedback:Boolean;
		private var _ruleLink:String;
		private var _isFirstExercise:Boolean;
		private var _isDirectStartEx:Boolean;
		private var _languageCode:String;

		public function set courseCaption(value:String):void {
			_courseCaption = value;
			dispatchEvent(new Event("courseCaptionChanged"));
		}

		[Bindable(event="courseCaptionChanged")]
		public function get backgroundColorTop():Number {
			return getStyle(_courseCaption.toLowerCase() + "Color")
		}

		[Bindable(event="courseCaptionChanged")]
		public function get backgroundColorBottom():Number {
			return getStyle(_courseCaption.toLowerCase() + "ColorDark")
		}

		[Bindable]
		public function get hasExerciseFeedback():Boolean {
			return _hasExerciseFeedback;
		}

		public function set hasExerciseFeedback(value:Boolean):void {
			_hasExerciseFeedback = value;
		}
		[Bindable]
		public function get hasQuestionFeedback():Boolean {
			return _hasQuestionFeedback;
		}

		public function set hasQuestionFeedback(value:Boolean):void {
			_hasQuestionFeedback = value;
		}

		public function set ruleLink(value:String):void {
			_ruleLink = value;
		}

		[Bindable]
		public function get ruleLink():String {
			return _ruleLink;
		}

		public function set isFirstExercise(value:Boolean):void {
			_isFirstExercise = value;
		}

		[Bindable]
		public function get isFirstExercise():Boolean {
			return _isFirstExercise;
		}

		public function set isDirectStartEx(value:Boolean):void {
			_isDirectStartEx = value;
		}

		[Bindable]
		public function get isDirectStartEx():Boolean {
			return _isDirectStartEx;
		}

		public function set languageCode(value:String):void {
			_languageCode = value;
		}

		[Bindable]
		public function get languageCode():String {
			return _languageCode;
		}

		public function set timerTotalTime(value:Array):void {
			_timerTotalTime = value;
			_isTimereTotalTimeChange = true;
		}

		[Bindable]
		public function get timerTotalTime():Array {
			return _timerTotalTime;
		}

		public function set timerSectionLabels(value:Array):void {
			_timerSectionLabels = value;
		}

		[Bindable]
		public function get timerSectionLabels():Array {
			return _timerSectionLabels;
		}

		public var startAgain:Signal = new Signal();
		public var showFeedback:Signal = new Signal();
		public var showMarking:Signal = new Signal();
		public var nextExercise:Signal = new Signal();
		public var previousExercise:Signal = new Signal();
		public var nodeSelect:Signal = new Signal(XML);
		public var printExercise:Signal = new Signal(DynamicView);
		public var backToMenu:Signal = new Signal();
		public var showFeedbackReminder:Signal = new Signal(String); // gh#388
		public var audioPlayed:Signal = new Signal(String); // gh#267
		public var record:Signal = new Signal(); // gh#267
		public var logout:Signal = new Signal();
		public var setTimer:Signal = new Signal(Array, Number); // gh#1221

		public function ExerciseView() {
			super();

			tabBarVisible = false;
		}

		// gh#1309
		public function stopTimer():void {
			if (timerComponent){
				timerComponent.stopTimer();
			}
		}

		// gh#1309
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);

			stopTimer();
		}

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);

			dynamicView.href = href;

			// Only show the back and forward buttons if this is an action exercise (i.e. not for the pdf ebook accessed directly from the zone view)
			// TODO: When we have real custom views this might not work anymore as it assumes anything not DynamicView.DEFAULT_VIEW isn't a real exercise
			var exercise:Exercise = _xhtml as Exercise;

			if (exercise) {
				var visibleValue:Boolean = (!exercise.model.view || exercise.model.view == DynamicView.DEFAULT_VIEW);
				if (forwardButton) {
					forwardButton.visible = visibleValue;
					forwardButton.includeInLayout = visibleValue;
				}

				if (backButton) {
					backButton.visible = visibleValue;
					backButton.includeInLayout = visibleValue;
				}
			}
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);

			switch (instance) {
				case dynamicView:
					dynamicView.addEventListener(BentoEvent.XHTML_READY, function():void { invalidateSkinState(); } );
					dynamicView.addEventListener(AudioPlayerEvent.PLAY, function(e:AudioPlayerEvent):void { audioPlayed.dispatch(e.src); } );
					dynamicView.addEventListener(RecorderEvent.SHOW, function(e:RecorderEvent):void { record.dispatch(); } );
					break;
				case startAgainButton:
					startAgainButton.addEventListener(MouseEvent.CLICK, function():void { startAgain.dispatch(); } );
					startAgainButton.label = copyProvider.getCopyForId("exerciseStartAgainButton");
					// When you first open exercise, buttons have not been initialized in configureButtonVisibility
					startAgainButton.visible = startAgainButton.includeInLayout = hasQuestions && !noMarking;
					// gh#1269
					startAgainButton.focusEnabled = false;
					break;
				case feedbackButton:
					feedbackButton.addEventListener(MouseEvent.CLICK, function():void {
						// gh#413
						if (hasExerciseFeedback) {
							showFeedback.dispatch();
						} else {
							showFeedbackReminder.dispatch(copyProvider.getCopyForId("feedbackClickAnswersMsg"));
						}} );
					feedbackButton.label = copyProvider.getCopyForId("exerciseFeedbackButton");
					// gh#1269
					feedbackButton.focusEnabled = false;
					break;
				case markingButton:
					markingButton.addEventListener(MouseEvent.CLICK, function():void { showMarking.dispatch(); } );
					markingButton.label = copyProvider.getCopyForId("exerciseMarkingButton");
					// When you first open exercise, buttons have not been initialized in configureButtonVisibility
					markingButton.visible = markingButton.includeInLayout = !isMarked && hasQuestions && !noMarking;
					// gh#1269
					markingButton.focusEnabled = false;
					break;
				case forwardButton:
					forwardButton.addEventListener(MouseEvent.CLICK, function():void { nextExercise.dispatch(); } );
					forwardButton.label = copyProvider.getCopyForId("exerciseForwardButton");
					// gh#1269
					forwardButton.focusEnabled = false;
					break;
				case backButton:
					backButton.addEventListener(MouseEvent.CLICK, function():void { previousExercise.dispatch(); } );
					backButton.label = copyProvider.getCopyForId("exerciseBackButton");
					// gh#1269
					backButton.focusEnabled = false;
					break;
				case printButton:
					printButton.addEventListener(MouseEvent.CLICK, function():void { printExercise.dispatch(dynamicView); } );
					printButton.label = copyProvider.getCopyForId("printButton");
					break;
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, function():void { backToMenu.dispatch(); } );
					backToMenuButton.label = copyProvider.getCopyForId("exerciseBackToMenuButton");
					break;
				case logoutButton:
					logoutButton.addEventListener(MouseEvent.CLICK, function():void { logout.dispatch(); });
					logoutButton.label = copyProvider.getCopyForId("exerciseLogOutButton");
					break;
				case footerLabel:
					footerLabel.text = copyProvider.getCopyForId("footerLabel");
					break;
				case recorderButton:
					recorderButton.label = copyProvider.getCopyForId("recorderButton");
					recorderButton.addEventListener(MouseEvent.CLICK, function():void { record.dispatch(); });
					break;
				case ruleButton:
					ruleButton.label = copyProvider.getCopyForId("ruleButton");
					ruleButton.addEventListener(MouseEvent.CLICK, onMouseClick);
					break;
			}
		}

		override protected function commitProperties():void {
			super.commitProperties();

			// gh#1267
			if (isPlatformiPad) {
				if (_isTimereTotalTimeChange && _timerTotalTime.length > 0) {
					_isTimereTotalTimeChange = false;
					FlexGlobals.topLevelApplication.resizeForSoftKeyboard = true;
				} else {
					FlexGlobals.topLevelApplication.resizeForSoftKeyboard = false;
				}
			}
		}

		protected override function getCurrentSkinState():String {
			if (!dynamicView) return null;

			return (dynamicView.viewName == DynamicView.DEFAULT_VIEW) ? "exercise" : "other";
		}

		protected function onMouseClick(event:MouseEvent):void {
			var url:String = config.contentRoot + config.account.getTitle().contentLocation + "/" + _ruleLink;
			var urlRequest:URLRequest = new URLRequest(url);
			navigateToURL(urlRequest, "_blank");
		}
	}
	
}