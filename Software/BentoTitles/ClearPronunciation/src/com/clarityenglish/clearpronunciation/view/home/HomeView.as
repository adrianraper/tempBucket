package com.clarityenglish.clearpronunciation.view.home {
	import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	import org.osflash.signals.Signal;
	
	import skins.clearpronunciation.home.ui.UnitListItemRenderer;
	
	public class HomeView extends BentoView {
		
		[SkinPart]
		public var courseList:List;
		
		[SkinPart]
		public var unitList:List;
		
		public var channelCollection:ArrayCollection;
		
		public var mediaFolder:String;
		
		public var exerciseSelect:Signal = new Signal(XML);
		
		public function HomeView():void {
			super();
			actionBarVisible = false;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Populate the course list
			courseList.dataProvider = new XMLListCollection(xhtml..menu.(@id == productCode).course);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case courseList:
					courseList.addEventListener(IndexChangeEvent.CHANGE, onCourseListIndexChange);
					break;
				case unitList:
					var unitListItemRenderer:ClassFactory = new ClassFactory(UnitListItemRenderer);
					unitListItemRenderer.properties = { copyProvider: copyProvider, showPieChart: true };
					instance.itemRenderer = unitListItemRenderer;
					unitList.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
			}
		}
		
		protected function onCourseListIndexChange(event:Event):void {
			unitList.dataProvider = new XMLListCollection(courseList.selectedItem.unit);
		}
		
		protected function onExerciseSelected(event:ExerciseEvent):void {
			exerciseSelect.dispatch(event.node);
		}
		
		/*[SkinPart]
		public var introductionList:List;
		
		[SkinPart]
		public var introductionGroup:Group;
		
		[SkinPart]
		public var videoSelector:VideoSelector;
		
		[SkinPart]
		public var introductionTutorialLabel:Label;
		
		[SkinPart]
		public var unitListInstructionGroup:Group;
		
		[SkinPart]
		public var homeInstructionLabel:Label;
		
		[Bindable]
		public var mediaFolder:String;
		
		public var channelCollection:ArrayCollection;
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			introductionList.dataProvider = new XMLListCollection(xhtml..menu.(@id == productCode).course.(@["class"] == "introduction").unit.exercise.(@["class"] == "exercise").exercise);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (videoSelector) {
				videoSelector.href = href;
				videoSelector.channelCollection = channelCollection;
				videoSelector.videoCollection = new XMLListCollection(course[0].unit[0].exercise.(@type == "videoSelector").exercise);
				videoSelector.placeholderSource = href.rootPath + "/" + _course[0].unit[0].exercise.@placeholder;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case introductionTutorialLabel:
					introductionTutorialLabel.text = copyProvider.getCopyForId("introductionTutorialLabel");
					break;
				case homeInstructionLabel:
					homeInstructionLabel.text = copyProvider.getCopyForId("homeInstructionLabel");
					break;
			}		
		}
		
		protected function onIntroductionListIndexChange(event:IndexChangeEvent):void {
			exerciseShow.dispatch(introductionList.selectedItem);
		}
		*/
	}
}