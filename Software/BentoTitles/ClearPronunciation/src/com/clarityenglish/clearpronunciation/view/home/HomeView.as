package com.clarityenglish.clearpronunciation.view.home {
	import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import skins.clearpronunciation.home.ui.UnitListItemRenderer;
	
	public class HomeView extends BentoView {
		
		[SkinPart]
		public var courseList:List;
		
		[SkinPart]
		public var unitList:List;
		
		[Bindable]
		public var courses:ListCollectionView;
		
		public var channelCollection:ArrayCollection;
		
		public var mediaFolder:String;
		
		public var nodeSelect:Signal = new Signal(XML);
		
		public function set selectedNode(value:XML):void {
			switch (value.localName()) {
				/*case "menu":
				case "course":
				case "unit":
					currentState = "home";
					break;
				case "exercise":
					currentState = "exercise";
					break;*/
				case "course":
					currentState = value.@["class"];
					unitList.dataProvider = new XMLListCollection(value.unit);
					break;
			}
		}
		
		public function HomeView():void {
			super();
			actionBarVisible = false;
			StateUtil.addStates(this, [ "introduction", "consonants", "vowels", "diphthongs" ]);
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Populate the course list
			courses = new XMLListCollection(xhtml..menu.(@id == productCode).course);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case courseList:
					// Catch course changes
					courseList.addEventListener(IndexChangeEvent.CHANGE, onNodeSelect);
					break;
				case unitList:
					var unitListItemRenderer:ClassFactory = new ClassFactory(UnitListItemRenderer);
					unitListItemRenderer.properties = { copyProvider: copyProvider, showPieChart: true };
					instance.itemRenderer = unitListItemRenderer;
					
					// Catch unit changes
					unitList.addEventListener(IndexChangeEvent.CHANGE, onNodeSelect);
					
					// Catch exercise changes (this one is a special case as the event doesn't come from the right target)
					unitList.addEventListener(ExerciseEvent.EXERCISE_SELECTED, function(e:ExerciseEvent):void { nodeSelect.dispatch(e.node); });
					break;
			}
		}
		
		protected function onNodeSelect(e:Event):void {
			nodeSelect.dispatch(e.target.selectedItem);
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
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