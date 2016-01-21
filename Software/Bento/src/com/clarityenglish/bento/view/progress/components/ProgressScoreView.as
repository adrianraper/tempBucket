package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.ProgressBarRenderer;
	import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.gridClasses.GridColumn;
	import spark.events.IndexChangeEvent;
	
	/**
	 * TODO: This class is way too specific; we don't want to be specifying course classes in here since we want it to be shared between all titles.
	 */
	public class ProgressScoreView extends BentoView {
		
		[SkinPart]
		public var progressCourseButtonBar:ProgressCourseButtonBar;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBarRenderer;
		
		[SkinPart(required="true")]
		public var scoreDetailsDataGrid:DataGrid;
		
		[Bindable]
		public var tableDataProvider:XMLListCollection;
		
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
		
		[SkinPart]
		public var ScoreEmptyScoreLabelButton:Button;
		
		private var _courseClass:String;
		private var _courseChanged:Boolean;
		
		public var courseSelect:Signal = new Signal(String);
				
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
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (progressCourseButtonBar) progressCourseButtonBar.copyProvider = copyProvider;
			if (scoreGridC1) scoreGridC1.headerText = copyProvider.getCopyForId("scoreGridC1");
			if (scoreGridC2) scoreGridC2.headerText = copyProvider.getCopyForId("scoreGridC2");
			if (scoreGridC3) scoreGridC3.headerText = copyProvider.getCopyForId("scoreGridC3");
			if (scoreGridC4) scoreGridC4.headerText = copyProvider.getCopyForId("scoreGridC4");
			if (scoreGridC5) scoreGridC5.headerText = copyProvider.getCopyForId("scoreGridC5");
			if (ScoreEmptyScoreLabelButton) ScoreEmptyScoreLabelButton.label = copyProvider.getCopyForId("ScoreEmptyScoreLabelButton");
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			progressCourseButtonBar.courses = menu.course;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		
			if (_courseChanged) {
				if (progressBar) {
					progressBar.label = copyProvider.getCopyForId("progressBarScore", { course: copyProvider.getCopyForId(StringUtils.capitalize(courseClass)) });
					progressBar.data = menu.course.(@["class"] == courseClass).@averageScore;
				}

				if (courseClass) {
					var buildXML:XMLList = menu.course.(@["class"] == courseClass).unit.exercise.score;
					
					// Then add the caption from the exercise to the score to make it easy to display in the grid
					// If the grid can do some sort of subheading, then I could do something similar with the unit name too
					for each (var score:XML in buildXML) {
						score.@caption = score.parent().@caption;
						
						// Caption is different from PracticeZone and others
						if (score.parent().attribute("group").length() > 0) {
							score.@unitCaption = menu.course.(@["class"] == courseClass).groups.group.(@id == score.parent().@group).@caption;
						} else {
							score.@unitCaption = score.parent().parent().@caption;
						}
						
						// #232. Scores of -1 (nothing to mark) should show in the table as ---
						score.@displayScore = (Number(score.@score) >= 0) ? score.@score : '---';
					}
					
					tableDataProvider = new XMLListCollection(buildXML);

					if (ScoreEmptyScoreLabelButton) {
						if (buildXML.length() == 0) {
							ScoreEmptyScoreLabelButton.visible = true;
						}else {
							ScoreEmptyScoreLabelButton.visible = false;
						}
					}
					
					//alice: get courseClass in scoreDetailsDataGrid;
					scoreDetailsDataGrid.name = courseClass;
					scoreDetailsDataGrid.skin.invalidateDisplayList();
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
		public function onCourseSelect(event:Event):void {
			courseSelect.dispatch(event.target.selectedItem.courseClass.toLowerCase());
		}
		
	}

}