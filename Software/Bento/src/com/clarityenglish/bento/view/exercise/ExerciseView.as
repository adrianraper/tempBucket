package com.clarityenglish.bento.view.exercise {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.base.events.BentoEvent;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.events.AudioPlayerEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Text;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	
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
		public var exerciseLogOutButton:Button;
				
		[SkinPart(required="true")]
		public var dynamicView:DynamicView;
		
		[Bindable]
		public var exerciseTitle:String;
		
		[Bindable]
		public var isMarked:Boolean;
		
		[Bindable]
		public var hasQuestions:Boolean;
			
		[Bindable]
		public var hasPrintStylesheet:Boolean;
		
		[Bindable]
		public var footerLabel:Text;
		
		private var _courseCaption:String;
		
		// gh#388
		private var _isFeedbackReminder:Boolean;
		
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
		public function get isFeedbackReminder():Boolean {
			return _isFeedbackReminder;
		}
		
		public function set isFeedbackReminder(value:Boolean):void {
			_isFeedbackReminder = value;
		}
		
		public var startAgain:Signal = new Signal();
		public var showFeedback:Signal = new Signal();
		public var showMarking:Signal = new Signal();
		public var nextExercise:Signal = new Signal();
		public var previousExercise:Signal = new Signal();
		public var printExercise:Signal = new Signal(DynamicView);
		public var backToMenu:Signal = new Signal();
		public var showFeedbackReminder:Signal = new Signal(String); // gh#388
		public var audioPlayed:Signal = new Signal(String); // gh#267
		// gh#267
		public var record:Signal = new Signal(); 
		
		public function ExerciseView() {
			super();
			
			tabBarVisible = false;
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
					break;
				case startAgainButton:
					startAgainButton.addEventListener(MouseEvent.CLICK, function():void { startAgain.dispatch(); } );
					startAgainButton.label = copyProvider.getCopyForId("exerciseStartAgainButton");
					break;
				case feedbackButton:
					feedbackButton.addEventListener(MouseEvent.CLICK, function():void {
						if (isFeedbackReminder) {
							// #gh413
							showFeedbackReminder.dispatch(copyProvider.getCopyForId("feedbackClickAnswersMsg"));
						} else {
							showFeedback.dispatch();
						}} );
					feedbackButton.label = copyProvider.getCopyForId("exerciseFeedbackButton");
					break;
				case markingButton:
					markingButton.addEventListener(MouseEvent.CLICK, function():void { showMarking.dispatch(); } );
					markingButton.label = copyProvider.getCopyForId("exerciseMarkingButton");
					break;
				case forwardButton:
					forwardButton.addEventListener(MouseEvent.CLICK, function():void { nextExercise.dispatch(); } );
					forwardButton.label = copyProvider.getCopyForId("exerciseForwardButton");
					break;
				case backButton:
					backButton.addEventListener(MouseEvent.CLICK, function():void { previousExercise.dispatch(); } );
					backButton.label = copyProvider.getCopyForId("exerciseBackButton");
					break;
				case printButton:
					printButton.addEventListener(MouseEvent.CLICK, function():void { printExercise.dispatch(dynamicView); } );
					printButton.label = copyProvider.getCopyForId("printButton");
					break;
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, function():void { backToMenu.dispatch(); } );
					backToMenuButton.label = copyProvider.getCopyForId("exerciseBackToMenuButton");
					break;
				case exerciseLogOutButton:
					exerciseLogOutButton.label = copyProvider.getCopyForId("exerciseLogOutButton");
					break;
				case footerLabel:
					footerLabel.text = copyProvider.getCopyForId("footerLabel");
					break;
				case recorderButton:
					recorderButton.label = copyProvider.getCopyForId("recorderButton");
					recorderButton.addEventListener(MouseEvent.CLICK, function():void { record.dispatch(); });
					break;
			}
		}
		
		protected override function getCurrentSkinState():String {
			if (!dynamicView) return null;
			
			return (dynamicView.viewName == DynamicView.DEFAULT_VIEW) ? "exercise" : "other";
		}
		
	}
	
}