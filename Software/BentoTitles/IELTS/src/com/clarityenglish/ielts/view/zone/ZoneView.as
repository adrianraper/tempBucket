package com.clarityenglish.ielts.view.zone {
	import caurina.transitions.Tweener;
	
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.zone.ui.PopoutExerciseSelector;
	import com.clarityenglish.textLayout.components.AudioPlayer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.XMLListCollection;
	import mx.controls.SWFLoader;
	import mx.formatters.DateFormatter;
	
	import org.osflash.signals.Signal;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.Group;
	import spark.components.List;
	import spark.components.NavigatorContent;
	import spark.components.VideoPlayer;
	import spark.core.IDisplayText;
	import spark.events.IndexChangeEvent;
	
	import ws.tink.spark.containers.Accordion;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseTitleLabel:IDisplayText;
		
		[SkinPart]
		public var accordian:Accordion;
		
		[SkinPart(required="true")]
		public var practiceZoneNavigatorContent:NavigatorContent;
		
		[SkinPart(required="true")]
		public var adviceZoneNavigatorContent:NavigatorContent;
		
		[SkinPart(required="true")]
		public var examPracticeNavigatorContent:NavigatorContent;
		
		[SkinPart(required="true")]
		public var questionZoneNavigatorContent:NavigatorContent;
		
		[SkinPart(required="true")]
		public var examPracticeDataGroup:DataGroup;
		
		[SkinPart(required="true")]
		public var examPracticeAnswerDataGroup:DataGroup;
		
		[SkinPart(required="true")]
		public var questionZoneViewButton:Button;
		
		[SkinPart(required="true")]
		public var questionZoneDownloadButton:Button;
		
		[SkinPart(required="true")]
		public var questionZoneVideoButton:Button;
		
		[SkinPart(required="true")]
		public var questionZoneVideoPlayer:VideoPlayer;
		
		[SkinPart(required="true")]
		public var questionZoneEBookGraphic:SWFLoader;
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var popoutExerciseSelector:PopoutExerciseSelector;
		
		[SkinPart(required="true")]
		public var adviceZoneVideoPlayer:VideoPlayer;
		
		[SkinPart(required="true")]
		public var adviceZoneVideoList:List;

		[SkinPart]
		public var courseSelectorWidget:CourseSelectorWidget;
		
		private var _courseCaption:String;
		
		public function isDemo():Boolean {
			return (productVersion == IELTSApplication.DEMO);
		}
		
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
		public var user:User;

		[Bindable]
		public var dateFormatter:DateFormatter;
		
		// #234
		private var _productVersion:String;
		
		private var _licenceType:uint;
		
		public function get assetFolder():String {
			return config.remoteDomain + '/Software/ResultsManager/web/resources/assets/';
		}

		/**
		 * ZoneView specifically needs to know if it is mediated or not in order to implement #222.  This is not necessary for most views.
		 */
		public var isMediated:Boolean;
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
		private var _exerciseSelectorPoppedOut:Boolean;
		
		public var exerciseSelect:Signal = new Signal(Href);
		public var courseSelect:Signal = new Signal(XML);
		public var videoSelected:Signal = new Signal(Href, String);
		public var videoPlayerStateChange:Signal = new Signal(MediaPlayerStateChangeEvent);
		
		// This is just horrible, but there is no easy way to get the current course into ZoneAccordianButtonBarSkin without this.
		// NOTHING ELSE SHOULD USE THIS VARIABLE!!!
		[Bindable]
		public static var horribleHackCourseClass:String;
		
		/**
		 * This can be called from outside the view to make the view display a different course
		 * 
		 * @param XML A course node from the menu
		 * 
		 */
		public function set course(value:XML):void {
			_course = value;
			_courseChanged = true;
			
			invalidateProperties();
			invalidateSkinState();
			
			dispatchEvent(new Event("courseChanged"));
			
			// This is a horrible hack
			horribleHackCourseClass = courseClass;
		}
		
		[Bindable(event="courseChanged")]
		public function get courseClass():String {
			return (_course) ? _course.@["class"].toString() : null;
		}
		
		[Bindable(event="courseChanged")]
		public function hasUnit(unitClass:String):Boolean {
			return (_course) ? _course.unit.(@["class"] == unitClass).length() > 0 : false;
		}

		[Bindable]
		public function get licenceType():uint {
			return _licenceType;
		}
		
		public function set licenceType(value:uint):void {
			if (_licenceType != value) {
				_licenceType = value;
			}
		}
		
		[Bindable]
		public function get productVersion():String {
			return _productVersion;
		}
		
		public function set productVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
			}
		}
		
		// #299
		public function isFullVersion():Boolean {
			return (_productVersion == IELTSApplication.FULL_VERSION);
		}
		
		public function set exerciseSelectorPoppedOut(value:Object):void {
			_exerciseSelectorPoppedOut = value;
			
			invalidateSkinState();
		}
		
		protected override function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			stage.addEventListener(MouseEvent.CLICK, onMouseClick);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			
			stage.removeEventListener(MouseEvent.CLICK, onMouseClick);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {
				courseTitleLabel.text = _course.@caption;
				
				// Give groups as the dataprovider to the unit list
				unitList.dataProvider = new XMLListCollection(_course.groups.group);
				
				// Give the advice zone videos as a dataprovider to the advice zone video list
				adviceZoneVideoList.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "advice-zone").exercise);
				
				// Give the exam practice exercises as a dataprovider to the exam practice data group
				examPracticeDataGroup.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "exam-practice").exercise);
				
				// Give the exam practice exercises as a dataprovider to the exam practice answer group
				//examPracticeAnswerDataGroup.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "exam-answers").exercise);
				examPracticeAnswerDataGroup.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "exam-practice").exercise.(hasOwnProperty("@answerHref")));
				
				// Change the course selector
				if (courseSelectorWidget) courseSelectorWidget.setCourse(_course.@caption.toLowerCase());
				
				// #215
				showEBook();
				
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					unitList.addEventListener(IndexChangeEvent.CHANGE, function(e:IndexChangeEvent):void {
						popoutExerciseSelector.exercises = refreshedExercises();
					} );
					break;
				case popoutExerciseSelector:
				case examPracticeDataGroup:
				case adviceZoneVideoList:
					instance.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
				case examPracticeAnswerDataGroup:
					instance.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
				case questionZoneViewButton:
					questionZoneViewButton.addEventListener(MouseEvent.CLICK, onQuestionZoneViewButtonClick);
					break;
				case questionZoneDownloadButton:
					questionZoneDownloadButton.addEventListener(MouseEvent.CLICK, onQuestionZoneDownloadButtonClick);
					break;
				case questionZoneVideoButton:
					questionZoneVideoButton.addEventListener(MouseEvent.CLICK, onQuestionZoneVideoButtonClick);
					break;
				case courseSelectorWidget:
					courseSelectorWidget.addEventListener("writingSelected", onCourseSelectorClick, false, 0, true);
					courseSelectorWidget.addEventListener("readingSelected", onCourseSelectorClick, false, 0, true);
					courseSelectorWidget.addEventListener("listeningSelected", onCourseSelectorClick, false, 0, true);
					courseSelectorWidget.addEventListener("speakingSelected", onCourseSelectorClick, false, 0, true);
					break;
				case questionZoneVideoPlayer:
				case adviceZoneVideoPlayer:
					(instance as VideoPlayer).addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
					(instance as VideoPlayer).addEventListener(TimeEvent.COMPLETE, onVideoPlayerComplete);
					break;
			}
		}
		
		protected function onVideoPlayerComplete(event:TimeEvent):void {
			// When a video in advice zone reaches the end deselect the video in the list so we don't end up with a floating 'loading...'
			if (event.target == adviceZoneVideoPlayer) adviceZoneVideoList.selectedItem = null;
		}
		
		protected function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
			log.debug("VIDEO PLAYER STATE CHANGE: " + event.state);
			
			// React to some states
			switch (event.state) {
				case "playbackError":
					// Load an error message onto the video player
					// That can be done with a state in the skin
					break;
				case "buffering":
				case "loading":
				case "uninitialized":
					// Run the loading animation
					break;
				case "playing":
					// Ensure smoothing is on
					(event.target as VideoPlayer).videoObject.smoothing = true;
				default:
					// Just play
			}
			
			// Trigger the signal in case the mediator wants to take action too
			videoPlayerStateChange.dispatch(event);
		}
		
		/**
		 * To allow the data in the exercise list to be refreshed based on score written 
		 * @return 
		 * 
		 */
		public function refreshedExercises():XMLList {
			if (!unitList.selectedItem)
				return null;
			
			var groupXML:XML = unitList.selectedItem;
			
			popoutExerciseSelector.group = groupXML;
			
			var exercises:XMLList = new XMLList();
			for each (var exerciseNode:XML in _course..exercise.(hasOwnProperty("@group") && @group == groupXML.@id))
				if (Exercise.showExerciseInMenu(exerciseNode))
					exercises += exerciseNode;
			
			return exercises;
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			// I want to know when the video player is removed. But this is never triggered.
		}		
		
		/**
		 * The user has selected a course using the course selector widget
		 * 
		 * @param event
		 */
		protected function onCourseSelectorClick(event:Event):void {
			log.debug("Course selector event received - {0}", event.type);
			var matchingCourses:XMLList = menu.course.(@caption.toLowerCase() == event.type.toLowerCase());
			
			switch (event.type) {
				case "readingSelected":
					matchingCourses = menu.course.(@["class"] == "reading");
					break;
				case "writingSelected":
					matchingCourses = menu.course.(@["class"] == "writing");
					break;
				case "listeningSelected":
					matchingCourses = menu.course.(@["class"] == "listening");
					break;
				case "speakingSelected":
					matchingCourses = menu.course.(@["class"] == "speaking");
					break;
			}
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a matching course");
			} else {
				courseSelect.dispatch(matchingCourses[0] as XML);
			}
		}
		
		/**
		 * The user has selected an exercise
		 * 
		 * @param event
		 */
		protected function onExerciseSelected(event:ExerciseEvent):void {
			// Fire the exerciseSelect signal
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, event.hrefFilename));
		}
		
		protected function onQuestionZoneViewButtonClick(event:MouseEvent):void {
			// Question Zone can have more than one exercise (eBook and pdf), so dangerous to assume order
			// Also a bit dubious, but can we base it on the file type?
			//var questionZoneExerciseNode:XML =  _course.unit.(@["class"] == "question-zone").exercise[0];
			for each (var questionZoneEBookNode:XML in _course.unit.(@["class"] == "question-zone").exercise) {
				if (questionZoneEBookNode.@href.indexOf(".xml") > 0) 
					break;
			}
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, questionZoneEBookNode.@href));
		}
		
		protected function onQuestionZoneVideoButtonClick(event:MouseEvent):void {
			// as above for file type
			for each (var questionZoneEBookNode:XML in _course.unit.(@["class"] == "question-zone").exercise) {
				if (questionZoneEBookNode.@href.indexOf(".rss") > 0) 
					break;
			}
			videoSelected.dispatch(href.createRelativeHref(null, questionZoneEBookNode.@href), "question-zone");
		}
		
		protected function onQuestionZoneDownloadButtonClick(event:MouseEvent):void {
			// as above for file type
			for each (var questionZonePDFNode:XML in _course.unit.(@["class"] == "question-zone").exercise) {
				if (questionZonePDFNode.@href.indexOf(".pdf") > 0) 
					break;
			}
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, questionZonePDFNode.@href));
			//trace("DOWNLOAD eBook pdf");
		}
		
		protected override function getCurrentSkinState():String {
			if (productVersion == IELTSApplication.DEMO) {
				var thisState:String = "demo";
			} else {
				thisState = "normal";
			}
			return (_course) ? courseClass + "_" + (_exerciseSelectorPoppedOut ? "popped" : thisState) : super.getCurrentSkinState();
		}
		
		/**
		 * Called to start playing a video, and record this in the progress 
		 * 
		 */
		public function adviceZoneVideoSelected(filename:String):void {
			videoSelected.dispatch(href.createRelativeHref(null, filename), "advice-zone");
		}
		
		/**
		 * Detect mouse clicks over the whole stage with the intention of stopping video playing if a click is outside of that video player.  #216
		 * 
		 * @param event
		 */
		protected function onMouseClick(event:MouseEvent):void {
			if (!(adviceZoneVideoPlayer.getBounds(stage).contains(event.stageX, event.stageY)) &&
				!(adviceZoneVideoList.getBounds(stage).contains(event.stageX, event.stageY))) {
				
				if (adviceZoneVideoPlayer.playing) {
					log.debug("Stopped advice zone video player because click detected outside player or list");
					adviceZoneVideoPlayer.stop();
					adviceZoneVideoList.selectedItem = null;
				}
			}
			
			if (!(questionZoneVideoPlayer.getBounds(stage).contains(event.stageX, event.stageY)) &&
				!(questionZoneVideoButton.getBounds(stage).contains(event.stageX, event.stageY))) {
				
				if (questionZoneVideoPlayer.playing) {
					log.debug("Stopped question zone video player because click detected outside player or button");
					questionZoneVideoPlayer.stop();
					resetQuestionZoneGraphics();
				}
			}
		}
		
		/**
		 * Detect mouse ups over the whole stage in order to stop any audio playing.  We check that the view is being mediator in order to make sure that
		 * we don't stop audio unless the view is actually visible (but visible can be true and it can be on the stage, even when an exercise is in progress
		 * which is why we explicitly inject the mediation status!) #222
		 * 
		 * @param event
		 */
		protected function onMouseUp(event:MouseEvent):void {
			// #332 
			if (isMediated) {
				if (!(examPracticeDataGroup.getBounds(stage).contains(event.stageX, event.stageY)) &&
					!(examPracticeDataGroup.getBounds(stage).contains(event.stageX, event.stageY))) {
					AudioPlayer.stopAllAudio();
					log.debug("Stopped practice test audio because click detected outside player");
				}
			}
		}
		
		/**
		 * Reset the question zone graphics such that the ebook is shown and the video player is hidden.
		 */
		public function resetQuestionZoneGraphics():void {
			Tweener.removeTweens(questionZoneVideoPlayer);
			Tweener.removeTweens(questionZoneEBookGraphic);
			
			questionZoneVideoPlayer.x = 500;
			questionZoneVideoPlayer.alpha = 0;
			questionZoneVideoPlayer.visible = false;
			
			questionZoneEBookGraphic.x = 0;
			questionZoneEBookGraphic.alpha = 1;
			questionZoneEBookGraphic.visible = true;
		}
		
		/**
		 * Animate the ebook into view
		 */
		public function showEBook():void {
			Tweener.removeTweens(questionZoneVideoPlayer);
			Tweener.removeTweens(questionZoneEBookGraphic);
			
			Tweener.addTween(questionZoneVideoPlayer, { x: 500, _autoAlpha: 0, time: 1.2 });
			Tweener.addTween(questionZoneEBookGraphic, { x: 0, _autoAlpha: 1, time: 1.2 });
		}
		
		/**
		 * Animate the video into view
		 */
		public function showVideo():void {
			Tweener.removeTweens(questionZoneVideoPlayer);
			Tweener.removeTweens(questionZoneEBookGraphic);
			
			Tweener.addTween(questionZoneVideoPlayer, { x: 0, _autoAlpha: 1, time: 1.2, transition:"easeOutSine" });
			Tweener.addTween(questionZoneEBookGraphic, { x: -500, _autoAlpha: 0, time: 1.2, transition:"easeOutSine" });
		}
		
	}
	
}