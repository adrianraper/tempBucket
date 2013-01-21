package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.CoverageExerciseComponent;
	import com.clarityenglish.bento.view.progress.ui.CoverageUnitComponent;
	import com.clarityenglish.bento.view.progress.ui.ProgressBarRenderer;
	import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.collections.ArrayList;
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.events.IndexChangeEvent;
	
	/**
	 * TODO: This class is way too specific; we don't want to be specifying course classes in here since we want it to be shared between all titles.
	 */
	public class ProgressCoverageView extends BentoView {
		
		[SkinPart]
		public var progressCourseButtonBar:ProgressCourseButtonBar;
		
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
		
		[Bindable]
		public var practiceZoneDataProvider:XMLListCollection;
		
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
		public var hostCopyProvider:CopyProvider; // TODO: get rid of this
		
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
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			progressCourseButtonBar.courses = menu.course;
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (progressCourseButtonBar) progressCourseButtonBar.copyProvider = copyProvider;
			if (progressBar) progressBar.copyProvider = copyProvider;
			if (questionZoneComponent) questionZoneComponent.caption = copyProvider.getCopyForId("questionZoneComponent");
			if (adviceZoneComponent) adviceZoneComponent.caption = copyProvider.getCopyForId("adviceZoneComponent");
			if (examPracticeComponent) examPracticeComponent.caption = copyProvider.getCopyForId("examPracticeComponent");
			if (practiceZoneComponent) practiceZoneComponent.caption = copyProvider.getCopyForId("practiceZoneComponent");
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
					practiceZoneDataProvider = new XMLListCollection();
					questionZoneDataProvider = new XMLListCollection();
					adviceZoneDataProvider = new XMLListCollection();
					examPracticeDataProvider = new XMLListCollection();
					
					for each (var unitNode:XML in menu.course.(@["class"] == courseClass).unit) {
						switch (unitNode.@["class"].toString()) {
							case 'practice-zone':
								// Because we need to get captions from the group node, send the whole course node as the practice zone data provider
								//practiceZoneDataProvider = new XMLListCollection(unitNode.parent());
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
				if (progressCourseButtonBar) progressCourseButtonBar.courseClass = courseClass;
				
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressCourseButtonBar:
					progressCourseButtonBar.addEventListener(IndexChangeEvent.CHANGE, onCourseSelect);
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
