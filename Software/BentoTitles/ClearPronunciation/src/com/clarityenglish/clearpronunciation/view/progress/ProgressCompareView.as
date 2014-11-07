package com.clarityenglish.clearpronunciation.view.progress {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.charts.BarChart;
	import mx.charts.CategoryAxis;
	import mx.charts.LinearAxis;
	import mx.charts.series.BarSeries;
	import mx.collections.XMLListCollection;
	import mx.containers.Grid;
	import mx.events.FlexEvent;
	
	import spark.components.BusyIndicator;
	import spark.components.Button;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;
	
	import org.osflash.signals.Signal;
	
	public class ProgressCompareView extends BentoView {
		
		[SkinPart]
		public var progressCourseButtonBar:ProgressCourseButtonBar;		
		
		[SkinPart(required="true")]
		public var compareChart:BarChart;
		
		[SkinPart(required="true")]
		public var verticalAxis:CategoryAxis;
				
		[SkinPart]
		public var horizontalAxis:LinearAxis;
		
		[SkinPart]
		public var myBarSeries:BarSeries;
		
		[SkinPart]
		public var everyOneBarSeries:BarSeries;
		
		[SkinPart]
		public var myGrid:Grid;
		
		[SkinPart]
		public var compareInstructionLabel:Label;
		
		[SkinPart]
		public var mylegendLabel:Label;
		
		[SkinPart]
		public var everyonelegendLabel:Label;
		
		[SkinPart]
		public var compareEmptyScoreLabel:Button;
		
		[SkinPart]
		public var chartCaptionLabel:Label;
		
		[SkinPart]
		public var busyIndicator:BusyIndicator;
		
		private var _everyoneCourseSummaries:Object;
		private var _everyoneCourseSummariesChanged:Boolean;
		private var _courseClass:String;
		private var _courseChanged:Boolean;
		private var _isPlatformOnline:Boolean;
		private var isNoData:Boolean;
		private var everyOneScoreObject:Object = new Object();
		private var isCompareChartCreated:Boolean;
		
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
		
		public function set isPlatformOnline(value:Boolean):void {
			_isPlatformOnline = value;
		}
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		[Bindable]
		public function get isPlatformOnline():Boolean {
			return _isPlatformOnline;
		}
		
		public function set everyoneCourseSummaries(value:Object):void {
			_everyoneCourseSummaries = value;
			_everyoneCourseSummariesChanged = true;
			for (var i:Number = 0; i < _everyoneCourseSummaries.length; i++) {
				everyOneScoreObject[_everyoneCourseSummaries[i].UnitID] = _everyoneCourseSummaries[i].AverageScore;
			}
			invalidateProperties();
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			var courseXMLList:XMLList = new XMLList();
			for each (var course:XML in menu.course) {
				if (course.@["class"] != "introduction") {
					courseXMLList += course;
				}
			}
			if (progressCourseButtonBar) progressCourseButtonBar.courses = courseXMLList;
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (progressCourseButtonBar) progressCourseButtonBar.copyProvider = copyProvider;
			//horizontalAxis.title = copyProvider.getCopyForId("verticalAxisTitle");
			chartCaptionLabel.text = copyProvider.getCopyForId("chartCaptionLabel");
			compareInstructionLabel.text = copyProvider.getCopyForId("compareInstructionLabel");
			mylegendLabel.text = copyProvider.getCopyForId("mylegendLabel");
			everyonelegendLabel.text = copyProvider.getCopyForId("everyonelegendLabel");
			compareEmptyScoreLabel.label = copyProvider.getCopyForId("compareEmptyScoreLabel");
		}
		
		
		protected override function commitProperties():void {
			super.commitProperties();

			if (_courseChanged && menu && _everyoneCourseSummariesChanged) {
				
				// #176. Make sure the buttons in the progressCourseBar component reflect current state
				if (progressCourseButtonBar) progressCourseButtonBar.courseClass = courseClass;
				
				// alice: Flag for empty score
				isNoData = true;
				
				// Merge the my and everyone summary into some XML and return a list collection of the course nodes
				var xml:XML = <progress />;
				
				for each (var unitNode:XML in menu.course.(@["class"] == courseClass).unit) {
					var everyoneAverageScore:Number = (everyOneScoreObject[unitNode.@id]) ? everyOneScoreObject[unitNode.@id] : 0;
					// gh#1092
					xml.appendChild(<unit caption={unitNode.@caption} myAverageScore={unitNode.@averageScore} everyoneAverageScore={everyoneAverageScore} />);
					if (unitNode.@averageScore > 0 || everyoneAverageScore > 0) {
						isNoData = false;
					}
				}
				verticalAxis.dataProvider = compareChart.dataProvider = new XMLListCollection(xml.unit).toArray().reverse();
				
				if (isNoData) {
					compareEmptyScoreLabel.visible = true;					
				} else {
					compareEmptyScoreLabel.visible = false;
				}				
				
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressCourseButtonBar:
					progressCourseButtonBar.addEventListener(IndexChangeEvent.CHANGE, onCourseSelect);
					break;
				case compareChart:
					compareChart.addEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete);
					break;
			}
		}
		
		protected override function getCurrentSkinState():String {
			if (_isPlatformOnline) {
				return super.getCurrentSkinState() + "Online";
			} else {
				return super.getCurrentSkinState();
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
		
		protected function onUpdateComplete(event:Event):void {
			if (isCompareChartCreated) {
				busyIndicator.visible = false;
				this.invalidateSkinState();
			} else {
				isCompareChartCreated = true;
			}			
		}
	}
}