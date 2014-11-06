package com.clarityenglish.clearpronunciation.view.exercise {
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.clearpronunciation.ClearPronunciationNotifications;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.ClassFactory;
	
	import spark.components.Button;
	import spark.components.List;
	
	import org.davekeen.util.XmlUtils;
	
	import skins.clearpronunciation.home.ui.UnitListItemRenderer;
	
	/**
	 * This extends the default ExerciseView to add a few CP specific features
	 */
	public class ExerciseView extends com.clarityenglish.bento.view.exercise.ExerciseView {
		
		[SkinPart]
		public var unitList:List;
		
		[SkinPart]
		public var phonemicChartButton:Button;
		
		[SkinPart]
		public var youWillButton:Button;
		
		private var _selectedExerciseNode:XML;
		
		[Bindable]
		public function get selectedExerciseNode():XML {
			return _selectedExerciseNode;
		}
		
		public function set selectedExerciseNode(value:XML):void {
			_selectedExerciseNode = value;
		}
		
		public function ExerciseView() {
			super();
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					var unitListItemRenderer:ClassFactory = new ClassFactory(UnitListItemRenderer);
					unitListItemRenderer.properties = { copyProvider: copyProvider, showPieChart: false };
					instance.itemRenderer = unitListItemRenderer;
					//unitList.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
				case phonemicChartButton:
					phonemicChartButton.addEventListener(MouseEvent.CLICK, onPhonemicChartButtonClick);
					break;
				case youWillButton:
					youWillButton.addEventListener(MouseEvent.CLICK, onYouWillButtonClick);
					break;
			}
		}
		
		protected function onPhonemicChartButtonClick(event:MouseEvent):void { 
			navigateToURL(new URLRequest(copyProvider.getCopyForId("phonemicChartURL")), "_blank");
		}
		
		protected function onYouWillButtonClick(event:MouseEvent):void {
			var prefix:String = (XmlUtils.searchUpForNode(selectedExerciseNode, "course").@["class"] == "introduction") ? "introductionYouWillLabel" : "youWillLabel";
			var exerciseIndex:String = selectedExerciseNode.childIndex();
			sendNotification.dispatch(ClearPronunciationNotifications.YOUWILL_SHOW, prefix + exerciseIndex);
		}
		
	}
}