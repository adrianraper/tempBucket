package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.bento.view.progress.ui.ProgressBarRenderer;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.ButtonBar;
	import spark.components.DataGrid;
	import spark.components.gridClasses.GridColumn;
	import spark.events.IndexChangeEvent;
	
	/**
	 * TODO: This class is way too specific; we don't want to be specifying course classes in here since we want it to be shared between all titles.
	 */
	public class ProgressScoreView extends BentoView {
		
		[SkinPart(required="true")]
		public var progressCourseButtonBar:ButtonBar;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBarRenderer;
		
		[SkinPart(required="true")]
		public var scoreDetailsDataGrid:DataGrid;
		
		[Bindable]
		public var tableDataProvider:XMLListCollection;
		
		[SkinPart]
		public var scoreReadingObj:Object;
		
		[SkinPart]
		public var scoreListeningObj:Object;
		
		[SkinPart]
		public var scoreSpeakingObj:Object;
		
		[SkinPart]
		public var scoreWritingObj:Object;
		
		[SkinPart]
		public var scoreGridC1:GridColumn;
		
		[SkinPart]
		public var scoreGridC2:GridColumn;
		
		[SkinPart]
		public var scoreGridC3:GridColumn;
		
		[SkinPart]
		public var scoreGridC4:GridColumn;
		
		[SkinPart]
		public var scoreGridC5:GridColumn;
		
		private var _courseClass:String;
		private var _courseChanged:Boolean;
		
		public var courseSelect:Signal = new Signal(String);
		
	    private var _viewCopyProvider:CopyProvider;
		
		// gh#11 Language Code
		public function set viewCopyProvider(viewCopyProvider:CopyProvider):void {
			_viewCopyProvider = viewCopyProvider;
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
					progressBar.type = "score";
					progressBar.data = menu;
				}
				
				if (courseClass) {
					var buildXML:XMLList = menu.course.(@["class"] == courseClass).unit.exercise.score;
					
					// Then add the caption from the exercise to the score to make it easy to display in the grid
					// If the grid can do some sort of subheading, then I could do something similar with the unit name too
					for each (var score:XML in buildXML) {
						score.@caption = score.parent().@caption;
						
						// Caption is different from PracticeZone and others
						if (score.parent().hasOwnProperty("@group")) {
							score.@unitCaption = menu.course.(@["class"] == courseClass).groups.group.(@id == score.parent().@group).@caption;
						} else {
							score.@unitCaption = score.parent().parent().@caption;
						}
						
						// #232. Scores of -1 (nothing to mark) should show in the table as ---
						score.@displayScore = (Number(score.@score) >= 0) ? score.@score : '---';
					}
					
					tableDataProvider = new XMLListCollection(buildXML);
				}
				
				// Trac 176. Make sure the buttons in the progressCourseBar component reflect current state
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
				case scoreReadingObj:
					instance.label = _viewCopyProvider.getCopyForId("Reading");
					// gh#42 coursecalss cannot be read from label so we add a fixed value, courseclass, assigned to courseClass
					instance.courseClass = "Reading";
					break;
				case scoreListeningObj:
					instance.label = _viewCopyProvider.getCopyForId("Listening");
					instance.courseClass = "Listening";
					break;
				case scoreSpeakingObj:
					instance.label = _viewCopyProvider.getCopyForId("Speaking");
					instance.courseClass = "Speaking";
					break;
				case scoreWritingObj:
					instance.label = _viewCopyProvider.getCopyForId("Writing");
					instance.courseClass = "Writing";
					break;
				case progressBar:
					instance.copyProvider = _viewCopyProvider;
					break;
				case scoreGridC1:
					scoreGridC1.headerText = _viewCopyProvider.getCopyForId("scoreGridC1");
					break;
				case scoreGridC2:
					scoreGridC2.headerText = _viewCopyProvider.getCopyForId("scoreGridC2");
					break;
				case scoreGridC3:
					scoreGridC3.headerText = _viewCopyProvider.getCopyForId("scoreGridC3");
					break;
				case scoreGridC4:
					scoreGridC4.headerText = _viewCopyProvider.getCopyForId("scoreGridC4");
					break;
				case scoreGridC5:
					scoreGridC5.headerText = _viewCopyProvider.getCopyForId("scoreGridC5");
					break;
			}
		}
		
		/**
		 * The user has changed the course to be displayed
		 *
		 * @param String course class name
		 */
		public function onCourseSelect(event:Event):void {
			courseSelect.dispatch(event.target.selectedItem.courseClass.toLowerCase());
		}
		
	}

}