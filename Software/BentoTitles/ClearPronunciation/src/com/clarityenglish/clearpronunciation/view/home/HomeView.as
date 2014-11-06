package com.clarityenglish.clearpronunciation.view.home {
	import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.VideoSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import skins.clearpronunciation.home.ui.UnitListItemRenderer;
	
	public class HomeView extends BentoView {
		
		[SkinPart]
		public var introductionTutorialLabel:Label;
		
		[SkinPart]
		public var homeInstructionLabel:Label;
		
		[SkinPart]
		public var introductionList:List;
		
		[SkinPart]
		public var introductionVideoSelector:VideoSelector;
		
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
				case "course":
					// There is one state per course
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
			
			var introductionCourse:XML = _xhtml..course.(@["class"] == "introduction")[0];
			
			// Configure the introduction
			if (introductionVideoSelector) {
				introductionVideoSelector.href = href;
				introductionVideoSelector.channelCollection = channelCollection;
				introductionVideoSelector.videoCollection = new XMLListCollection(new XMLList(<item href={introductionCourse.@videoHref} />));
				introductionVideoSelector.placeholderSource = href.rootPath + "/" + introductionCourse.@videoPoster;
			}
			
			if (introductionList) {
				introductionList.dataProvider = new XMLListCollection(introductionCourse.unit.exercise);
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
				case introductionList:
					introductionList.addEventListener(IndexChangeEvent.CHANGE, onNodeSelect);
					break;
			}
		}
		
		protected function onNodeSelect(e:Event):void {
			nodeSelect.dispatch(e.target.selectedItem);
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}