package com.clarityenglish.clearpronunciation.view.progress {
	import com.adobe.utils.StringUtil;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.IStackedChart;
	import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
	import com.clarityenglish.clearpronunciation.view.progress.event.StackedBarMouseOutEvent;
	import com.clarityenglish.clearpronunciation.view.progress.event.StackedBarMouseOverEvent;
	import com.clarityenglish.clearpronunciation.view.progress.ui.StackedCircleWedgeChart;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	import mx.events.DragEvent;
	import mx.graphics.SolidColor;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.events.IndexChangeEvent;
	import spark.primitives.Rect;
	
	/**
	 * TODO: This class is way too specific; we don't want to be specifying course classes in here since we want it to be shared between all titles.
	 */
	public class ProgressAnalysisView extends BentoView {
		
		// Alice: for TB
		[SkinPart]
		public var progressCourseButtonBar:ProgressCourseButtonBar;
		
		[SkinPart(required="true")]
		public var stackedChart:StackedCircleWedgeChart;
		
		[SkinPart(required="true")]
		public var analysisTimeLabel:Label;
		
		[SkinPart(required="true")]
		public var durationDataGroup:DataGroup;
		
		[SkinPart]
		public var circleWedgeCourseLabel:Label;
		
		[SkinPart]
		public var analyseInstructionLabel:Label;
		
		[SkinPart]
		public var circleWedgeInstructionLabel:Button;
		
		[SkinPart]
		public var minLabel:Label;
		
		[SkinPart]
		public var totalLabel:Label;
		
		[SkinPart]
		public var totalDurationLabel:Label;
		
		[SkinPart]
		public var totalMinLabel:Label;
		
		[SkinPart]
		public var totalTimeLabel:Label;
		
		[SkinPart]
		public var totalTimeNumberLabel:Label;
		
		[SkinPart]
		public var totalTimeMinLabel:Label;
		
		[SkinPart]
		public var timeWedgeVGroup:VGroup;
		
		[SkinPart]
		public var totalTimeWedgeVGroup:VGroup;
		
		[Bindable]
		public var unitListCollection:ListCollectionView;
		
		// #18 - analysis can be course based (e.g. IELTS) or unit based (e.g. CCB)
		public static const UNIT_BASED:String = "progressanalysisview/unit_based";
		public static const COURSE_BASED:String = "progressanalysisview/course_based";
		
		// Alice: for TB 
		private var _courseCaption:String;
		private var _courseClass:String;
		private var _courseChanged:Boolean;
		private var _androidSize:String;
		public var courseSelect:Signal = new Signal(String);
		
		// Alice: for stackedCircleWedge		
		public function set courseCaption(value:String):void {
			if (value)
				_courseCaption = value;
		}
		
		[Bindable]
		public function get courseCaption():String {
			return _courseCaption;
		}
		
		// Alice: for TB
		public function set courseClass(value:String):void {
			_courseClass = value;
			_courseChanged = true;
			
			invalidateProperties();
		}
		
		[Bindable]
		public function get courseClass():String {
			return _courseClass;
		}
		
		// gh#11
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
		}
		
		public function set androidSize(value:String):void {
			_androidSize = value;
		}
		
		[Bindable]
		public function get androidSize():String {
			return _androidSize;
		}
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		// Alice: for TB
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
			
			if (_courseChanged && menu) {
				if (progressCourseButtonBar) progressCourseButtonBar.copyProvider = copyProvider;
			}
			
			totalLabel.text = copyProvider.getCopyForId("totalLabel");
			totalMinLabel.text = copyProvider.getCopyForId("minLabel");
			totalTimeLabel.text = copyProvider.getCopyForId("totalTimeLabel");
			totalTimeMinLabel.text = copyProvider.getCopyForId("minLabel");
			minLabel.text = copyProvider.getCopyForId("minLabel");
			circleWedgeInstructionLabel.label = copyProvider.getCopyForId("circleWedgeInstructionLabel");
		}
		
		protected override function commitProperties():void {
			super.commitProperties();

			if (_courseChanged && menu){
				courseCaption = menu.course.(@["class"] == courseClass).@caption;
				// gh#1092
				stackedChart.dataProvider = menu.course.(@["class"] == courseClass).unit;
				stackedChart.colours = getStyle("circleWedgeColors");
				
				unitListCollection = new XMLListCollection(menu.course.(@["class"] == courseClass).unit);
				
				analyseInstructionLabel.text = copyProvider.getCopyForId("analyseInstructionLabel", {course: copyProvider.getCopyForId(StringUtils.capitalize(courseClass))});				
				
				if (progressCourseButtonBar) progressCourseButtonBar.courseClass = courseClass;
			}
			
			// gh#1092
			var duration:Number = 0;
			for each (var item:XML in menu.course.(@["class"] == courseClass).unit) {
				var itemDuration:Number = new Number(item.@duration)
				duration += Math.floor(itemDuration / 60);
			}				
			totalDurationLabel.text = String(duration);
			
			totalTimeNumberLabel.text = String(duration);	
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case stackedChart:
					// set the field we will be drawing
					stackedChart.field = "duration";
					stackedChart.addEventListener(StackedBarMouseOverEvent.WEDGE_OVER, onStackedBarMouseOver);
					stackedChart.addEventListener(StackedBarMouseOutEvent.WEDGE_OUT, onStackedBarMouseOut);
					stackedChart.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
					break;
				case progressCourseButtonBar:
					progressCourseButtonBar.addEventListener(IndexChangeEvent.CHANGE, onCourseSelect);
					break;
			}
		}
		
		protected override function getCurrentSkinState():String {
			if (_androidSize) {
				return super.getCurrentSkinState() + _androidSize;
			}
			return super.getCurrentSkinState();
		}
		
		[Bindable(event="progressChanged")]
		public function get totalDuration():Number {
			var duration:Number = 0;
			
			for each (var course:XML in menu.course)
			duration += new Number(course.@duration);
			
			return duration;
		}
		
		// Alice: for TB
		public function onCourseSelect(event:IndexChangeEvent):void {
			courseSelect.dispatch(event.target.selectedItem.courseClass.toLowerCase());
		}
		
		protected function onStackedBarMouseOver(event:StackedBarMouseOverEvent):void {
			totalTimeWedgeVGroup.visible = false;
			// gh#1092
			var duration:Number = menu.course.(@["class"] == courseClass).unit.(@caption == event.caption).@duration;

			analysisTimeLabel.text = String(Math.floor(duration / 60) );
			
			circleWedgeCourseLabel.text = event.caption;
			
			timeWedgeVGroup.visible = true;
		}
		
		protected function onStackedBarMouseOut(event:StackedBarMouseOutEvent):void {
				timeWedgeVGroup.visible = false;
				totalTimeWedgeVGroup.visible = true;
		}
		
		protected function onMouseOut(event:MouseEvent):void {
				totalTimeWedgeVGroup.visible = true;
		}
	}
}