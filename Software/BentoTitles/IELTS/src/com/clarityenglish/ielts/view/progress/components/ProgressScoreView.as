package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.progress.ui.ProgressBarRenderer;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.ButtonBar;
	import spark.components.DataGrid;
	import spark.events.IndexChangeEvent;
	
	public class ProgressScoreView extends BentoView {
		
		[SkinPart(required="true")]
		public var progressCourseButtonBar:ButtonBar;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBarRenderer;
		
		[SkinPart(required="true")]
		public var scoreDetailsDataGrid:DataGrid;
		
		[Bindable]
		public var tableDataProvider:XMLListCollection;
		
		public var chartDataProvider:XML;
		
		public var _summaryData:XML;
		public var _detailData:XML;
		
		private var _courseClass:String;
		private var _courseChanged:Boolean;
		private var _dataChanged:Boolean;
		
		public var courseSelect:Signal = new Signal(String);
		
		/**
		 * This setter is given a full XML that includes scores and coverage for the student.
		 * It then breaks this down into dataProviders for the components that will display this
		 *
		 * @param XML value
		 *
		 */
		public function set detailDataProvider(value:XML):void {
			_detailData = value;
			_dataChanged = true;
			invalidateProperties();
		}
		
		public function get detailDataProvider():XML {
			return _detailData;
		}
		
		public function set summaryDataProvider(value:XML):void {
			_summaryData = value;
		}
		
		public function get summaryDataProvider():XML {
			return _summaryData;
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
			
			if (_courseChanged || _dataChanged) {
				// Update the components of the view that change their data
				if (progressBar && courseClass && summaryDataProvider) {
					//progressBar.courseClass = course.@["class"];
					progressBar.courseClass = courseClass;
					// BUG. For this view I want to show coverage summary. For score view I want average score.
					progressBar.type = "score";
					progressBar.data = {dataProvider: summaryDataProvider};
				}
				if (courseClass && detailDataProvider) {
					focusCourse(courseClass);
						//selectCourseData(course.@["class"]);
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
				
				_courseChanged = _dataChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressCourseButtonBar:
					progressCourseButtonBar.requireSelection = true;
					progressCourseButtonBar.addEventListener(IndexChangeEvent.CHANGE, onCourseSelect);
					break;
			}
		}
		
		/**
		 * This method uses the current course class to take the full dataProvider and
		 * split it for each component in the view
		 * @param String courseClass
		 *
		 */
		private function focusCourse(courseClass:String = null):void {
			if (!courseClass)
				courseClass = _courseClass;
			
			if (detailDataProvider) {
				var buildXML:XMLList = detailDataProvider.course.(@["class"] == courseClass).unit.exercise.score;
				// Then add the caption from the exercise to the score to make it easy to display in the grid
				// If the grid can do some sort of subheading, then I could do something similar with the unit name too
				for each (var score:XML in buildXML) {
					score.@caption = score.parent().@caption;
					
					// Caption is different from PracticeZone and others
					if (score.parent().hasOwnProperty("@group")) {
						score.@unitCaption = detailDataProvider.course.(@["class"] == courseClass).groups.group.(@id == score.parent().@group).@caption;
					} else {
						score.@unitCaption = score.parent().parent().@caption;
					}
					
					// #232. Scores of -1 (nothing to mark) should show in the table as ---
					score.@displayScore = (Number(score.@score) >= 0) ? score.@score : '---';
					
				}
				tableDataProvider = new XMLListCollection(buildXML);
			}
		}
		
		/**
		 * The user has changed the course to be displayed
		 *
		 * @param String course class name
		 */
		public function onCourseSelect(event:Event):void {
			courseSelect.dispatch(event.target.selectedItem.label.toLowerCase());
		}
	}

}
