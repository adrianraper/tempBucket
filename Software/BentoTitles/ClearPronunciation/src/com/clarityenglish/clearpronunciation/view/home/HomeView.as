package com.clarityenglish.clearpronunciation.view.home {
	import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.controls.video.VideoSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.googlecode.bindagetools.Bind;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import org.davekeen.util.StateUtil;
	import org.davekeen.util.XmlUtils;
	import org.osflash.signals.Signal;
	
	import skins.clearpronunciation.home.ui.UnitListItemRenderer;
	
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
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
		
		private var _selectedNode:XML;
		
		public var nodeSelect:Signal = new Signal(XML);
		
		public function set selectedNode(value:XML):void {
			_selectedNode = value;
		}
		
		public function HomeView():void {
			super();
			actionBarVisible = false;
			StateUtil.addStates(this, [ "normal", "introduction", "consonants", "vowels", "diphthongs" ], true);
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Populate the course list
			courses = new XMLListCollection(xhtml..menu.(@id == productCode).course);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			// Configure the introduction (TODO: this only needs to happen once... should I do it elsewhere?)
			var introductionCourse:XML = _xhtml..course.(@["class"] == "introduction")[0];
			if (introductionCourse) {
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
					// Bind the course list to the state and to the unit list so that these always reflect the currently selected course
					Bind.fromProperty(courseList, "selectedItem").toFunction(function(course:XML):void {
						currentState = (course) ? course.@["class"] : "normal";
						if (unitList) unitList.dataProvider = (course) ? new XMLListCollection(course.unit) : null;
					});
					
					// Auto select the course if necessary
					if (_selectedNode) courseList.selectedItem = XmlUtils.searchUpForNode(_selectedNode, "course");
					
					// Listen for course changes
					courseList.addEventListener(IndexChangeEvent.CHANGE, onNodeSelect);
					break;
				case unitList:
					// Set the item renderer
					var unitListItemRenderer:ClassFactory = new ClassFactory(UnitListItemRenderer);
					unitListItemRenderer.properties = { copyProvider: copyProvider, showPieChart: true };
					instance.itemRenderer = unitListItemRenderer;
					
					// Auto select the unit if necessary
					if (_selectedNode) unitList.selectedItem = XmlUtils.searchUpForNode(_selectedNode, "unit");
					
					// Listen for unit changes
					unitList.addEventListener(IndexChangeEvent.CHANGE, onNodeSelect);
					
					// Listen for exercise changes (this one is a special case as the event doesn't come from the expected target)
					unitList.addEventListener(ExerciseEvent.EXERCISE_SELECTED, function(e:ExerciseEvent):void { 
						// gh#1116
						if (e.node)
							nodeSelect.dispatch(e.node);
					});
					break;
				case introductionList:
					introductionList.addEventListener(IndexChangeEvent.CHANGE, onNodeSelect);
					break;
			}
		}
		
		protected function onNodeSelect(e:Event):void {
			// gh#1116
			if (e.target.selectedItem)
				nodeSelect.dispatch(e.target.selectedItem);
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}