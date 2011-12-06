package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.ielts.view.zone.ui.PopoutExerciseSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flashx.textLayout.elements.BreakElement;
	
	import mx.collections.XMLListCollection;
	import mx.core.IDataRenderer;
	
	import org.osflash.signals.Signal;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.List;
	import spark.components.NavigatorContent;
	import spark.components.VideoPlayer;
	import spark.core.IDisplayText;
	import spark.events.IndexChangeEvent;
	
	import ws.tink.spark.containers.Accordion;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseTitleLabel:IDisplayText;
		
		[SkinPart(required="true")]
		public var courseDescriptionLabel:IDisplayText;
		
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
		public var questionZoneViewButton:Button;
		
		[SkinPart(required="true")]
		public var questionZoneDownloadButton:Button;
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var popoutExerciseSelector:PopoutExerciseSelector;
		
		[SkinPart(required="true")]
		public var adviceZoneVideoPlayer:VideoPlayer;
		
		[SkinPart(required="true")]
		public var adviceZoneVideoList:List;
		
		[SkinPart(required="true")]
		public var courseSelectorWidget:CourseSelectorWidget;
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
		private var _exerciseSelectorPoppedOut:Boolean;
		
		public var exerciseSelect:Signal = new Signal(Href);
		public var courseSelect:Signal = new Signal(XML);
		
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
		
		public function set exerciseSelectorPoppedOut(value:Object):void {
			_exerciseSelectorPoppedOut = value;
			
			invalidateSkinState();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {
				courseTitleLabel.text = _course.@caption;
				courseDescriptionLabel.text = _course.@description;
				
				// Only display units with content in the XML - #51 - but this isn't working with Tink's Accordian right now
				/*practiceZoneNavigatorContent.visible = practiceZoneNavigatorContent.includeInLayout = hasUnit("practice-zone");
				adviceZoneNavigatorContent.visible = adviceZoneNavigatorContent.includeInLayout = hasUnit("advice-zone");
				examPracticeNavigatorContent.visible = examPracticeNavigatorContent.includeInLayout = hasUnit("exam-practice");
				questionZoneNavigatorContent.visible = questionZoneNavigatorContent.includeInLayout = hasUnit("question-zone");*/
				
				// Give groups as the dataprovider to the unit list
				unitList.dataProvider = new XMLListCollection(_course.groups.group);
				
				// Give the advice zone videos as a dataprovider to the advice zone video list
				adviceZoneVideoList.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "advice-zone").exercise);
				
				// Give the exam practice exercises as a dataprovider to the exam practice data group
				examPracticeDataGroup.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "exam-practice").exercise);
				
				// Change the course selector
				courseSelectorWidget.setCourse(_course.@caption.toLowerCase());
				
				_courseChanged = false;
			}
			
			//if (Config.DEVELOPER.name == "AR") {
			//	exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, 'reading/exercises/1156153794430.xml'));
			//}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					unitList.addEventListener(IndexChangeEvent.CHANGE, function(e:IndexChangeEvent):void {
						var groupXML:XML = unitList.selectedItem;
						
						popoutExerciseSelector.group = groupXML;
						
						// Build up a list of exercises we can show (includes disabled ones)
						var exercises:XMLList = new XMLList();
						for each (var exerciseNode:XML in _course..exercise.(hasOwnProperty("@group") && @group == groupXML.@id))
							if (Exercise.showExerciseInMenu(exerciseNode))
								exercises += exerciseNode;
						
						popoutExerciseSelector.exercises = exercises;
					} );
					break;
				case popoutExerciseSelector:
				case examPracticeDataGroup:
					instance.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
				case questionZoneViewButton:
					questionZoneViewButton.addEventListener(MouseEvent.CLICK, onQuestionZoneViewButtonClick);
					break;
				case questionZoneDownloadButton:
					questionZoneDownloadButton.addEventListener(MouseEvent.CLICK, onQuestionZoneDownloadButtonClick);
					break;
				case courseSelectorWidget:
					courseSelectorWidget.addEventListener("writingSelected", onCourseSelectorClick, false, 0, true);
					courseSelectorWidget.addEventListener("readingSelected", onCourseSelectorClick, false, 0, true);
					courseSelectorWidget.addEventListener("listeningSelected", onCourseSelectorClick, false, 0, true);
					courseSelectorWidget.addEventListener("speakingSelected", onCourseSelectorClick, false, 0, true);
					break;
			}
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
				if (questionZoneEBookNode.@href.indexOf(".xml")>0) 
					break;
			}
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, questionZoneEBookNode.@href));
		}
		
		protected function onQuestionZoneDownloadButtonClick(event:MouseEvent):void {
			// as above for file type
			for each (var questionZonePDFNode:XML in _course.unit.(@["class"] == "question-zone").exercise) {
				if (questionZonePDFNode.@href.indexOf(".pdf")>0) 
					break;
			}
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, questionZonePDFNode.@href));
			trace("DOWNLOAD eBook pdf");
		}
		
		protected override function getCurrentSkinState():String {
			return (_course) ? courseClass + "_" + (_exerciseSelectorPoppedOut ? "popped" : "normal") : super.getCurrentSkinState();
		}
		
		// Called from the skin when a dynamic streaming video set is selected
		public function onAdviceZoneVideoRSSSelect(url:String):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onAdviceZoneVideoRSSLoadComplete);
			urlLoader.load(new URLRequest(url));
		}
		protected function onAdviceZoneVideoRSSLoadComplete(e:Event):void {
			
			var dynamicList:XML = new XML(e.target.data);
			
			// Build the mxml component
			//var host:String = "rtmp://streaming.clarityenglish.com:1935/cfx/st/";
			var host:String = dynamicList.channel.host.toString();
			var dynamicSource:DynamicStreamingResource = new DynamicStreamingResource(host);
			dynamicSource.urlIncludesFMSApplicationInstance = true;
			dynamicSource.streamType = dynamicList.channel.type.toString();
			var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
			for each (var stream:XML in dynamicList.channel.item) {
				var streamName:String = stream.streamName;
				var bitrate:Number = stream.bitrate;
				var streamingItem:DynamicStreamingItem = new DynamicStreamingItem(streamName, bitrate);
				streamItems.push(streamingItem);
			}
			dynamicSource.streamItems = streamItems; 
			adviceZoneVideoPlayer.source = dynamicSource;
			
			// #63
			callLater(function():void {
				adviceZoneVideoPlayer.play();
			});
			
		}
		protected function onDynamicVideoEvent(e:DynamicStreamEvent):void {
			trace(e.toString());
		}
	}
	
}