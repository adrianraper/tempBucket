package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.bento.view.progress.ui.CoverageExerciseComponent;
	import com.clarityenglish.bento.view.progress.ui.CoverageUnitComponent;
	import com.clarityenglish.bento.view.progress.ui.ProgressBarRenderer;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.ButtonBar;
	import spark.events.IndexChangeEvent;
	
	/**
	 * TODO: This class is way too specific; we don't want to be specifying course classes in here since we want it to be shared between all titles.
	 */
	public class ProgressCoverageView extends BentoView {
		
		[SkinPart(required="true")]
		public var progressCourseButtonBar:ButtonBar;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBarRenderer;
		
		[SkinPart]
		public var questionZoneComponent:CoverageExerciseComponent;
		
		[SkinPart]
		public var practiceZoneComponent:CoverageUnitComponent;
		
		[SkinPart]
		public var adviceZoneComponent:CoverageExerciseComponent;
		
		[SkinPart]
		public var examPracticeComponent:CoverageExerciseComponent;
		
		[SkinPart]
		public var CoverageReadingObj:Object;
		
		[SkinPart]
		public var CoverageListeningObj:Object;
		
		[SkinPart]
		public var CoverageSpeakingObj:Object;
		
		[SkinPart]
		public var CoverageWritingObj:Object;
		
		[Bindable]
		public var practiceZoneDataProvider:XML;
		
		[Bindable]
		public var questionZoneDataProvider:XMLListCollection;
		
		[Bindable]
		public var adviceZoneDataProvider:XMLListCollection;
		
		[Bindable]
		public var examPracticeDataProvider:XMLListCollection;
				
		// This is just horrible, but there is no easy way to get the current course into ZoneAccordianButtonBarSkin without this.
		// NOTHING ELSE SHOULD USE THIS VARIABLE!!!
		// The horribleness comes from referring to this view from a renderer in the skin, so although we already have
		// a decent courseClass in this view, we keep this name. I think.
		[Bindable]
		public static var horribleHackCourseClass:String;
		
		private var _courseClass:String;
		private var _courseChanged:Boolean;
		
		public var courseSelect:Signal = new Signal(String);
		
		[Bindable]
		public var hostCopyProvider:CopyProvider;
		
		// gh#11 language Code
		public override function setCopyProvider(copyProvider:CopyProvider):void {
			super.setCopyProvider(copyProvider);
			this.hostCopyProvider = copyProvider;
		}
		
		/**
		 * This can be called from outside the view to make the view display a different course
		 *
		 * @param XML A course node from the menu
		 *
		 */
		public function set courseClass(value:String):void {
			_courseClass = value;
			_courseChanged = true;
			
			// This is a horrible hack
			horribleHackCourseClass = courseClass;
			
			invalidateProperties();
		}
		
		[Bindable]
		public function get courseClass():String {
			return _courseClass;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {				
				// Update the components of the view that change their data
				if (progressBar && courseClass) {
					progressBar.courseClass = courseClass;
					progressBar.type = "coverage";
					progressBar.data = menu;
				}
				
				if (courseClass) {
					// #160 - initialise any 'zone' that might not have data in the XML
					practiceZoneDataProvider = new XML();
					questionZoneDataProvider = new XMLListCollection();
					adviceZoneDataProvider = new XMLListCollection();
					examPracticeDataProvider = new XMLListCollection();
					
					for each (var unitNode:XML in menu.course.(@["class"] == courseClass).unit) {
						switch (unitNode.@["class"].toString()) {
							case 'practice-zone':
								// Because we need to get captions from the group node, send the whole course node as the practice zone data provider
								practiceZoneDataProvider = unitNode.parent();
								break;
							case 'question-zone':
								questionZoneDataProvider = new XMLListCollection(unitNode.exercise);
								break;
							case 'advice-zone':
								adviceZoneDataProvider = new XMLListCollection(unitNode.exercise);
								break;
							case 'exam-practice':
								examPracticeDataProvider = new XMLListCollection(unitNode.exercise);
								break;
						}
					}
				}
				
				// #176. Make sure the buttons in the progressCourseBar component reflect current state
				switch (courseClass) {
					case "listening":
						progressCourseButtonBar.selectedIndex = 1;
						break;
					case "speaking":
						progressCourseButtonBar.selectedIndex = 2;
						break;
					case "writing":
						progressCourseButtonBar.selectedIndex = 3;
						break;
					case "reading":
					default:
						progressCourseButtonBar.selectedIndex = 0;
						break;
				}
				
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressCourseButtonBar:
					progressCourseButtonBar.requireSelection = true;
					progressCourseButtonBar.addEventListener(IndexChangeEvent.CHANGE, onCourseSelect);
					break;
				case CoverageReadingObj:
					instance.label = copyProvider.getCopyForId("Reading");
					// gh#42 courseclass cannot be read from label so we add a fixed value, courseclass, assigned to courseClass
					instance.courseClass = "Reading";
					break;
				case CoverageListeningObj:
					instance.label = copyProvider.getCopyForId("Listening");
					instance.courseClass = "Listening";
					break;
				case CoverageSpeakingObj:
					instance.label = copyProvider.getCopyForId("Speaking");
					instance.courseClass = "Speaking";
					break;
				case CoverageWritingObj:
					instance.label = copyProvider.getCopyForId("Writing");
					instance.courseClass = "Writing";
					break;
				case questionZoneComponent:
					instance.caption = copyProvider.getCopyForId("questionZoneComponent");
					break;
				case adviceZoneComponent:
					instance.caption = copyProvider.getCopyForId("adviceZoneComponent");
					break;
				case examPracticeComponent:
					instance.caption = copyProvider.getCopyForId("examPracticeComponent");
					break;
				case practiceZoneComponent:
					instance.caption = copyProvider.getCopyForId("practiceZoneComponent");
					break;
				case progressBar:
					instance.copyProvider = copyProvider;
					break;
			}
		}
		
		/**
		 * The user has changed the course to be displayed
		 *
		 * @param String course class name
		 */
		public function onCourseSelect(event:IndexChangeEvent):void {
			courseSelect.dispatch(event.target.selectedItem.courseClass.toLowerCase());
		}
	
	}

}
