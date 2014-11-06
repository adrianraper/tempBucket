package com.clarityenglish.clearpronunciation.view.exercise {
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.clearpronunciation.ClearPronunciationNotifications;
	import com.googlecode.bindagetools.Bind;
	
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
		public var currentUnitRenderer:UnitListItemRenderer;
		
		[SkinPart]
		public var unitList:List;
		
		[SkinPart]
		public var phonemicChartButton:Button;
		
		[SkinPart]
		public var youWillButton:Button;
		
		[Bindable]
		public var selectedExerciseNode:XML;
		
		public function ExerciseView() {
			super();
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case currentUnitRenderer:
					currentUnitRenderer.copyProvider = copyProvider;
					Bind.fromProperty(this, "selectedExerciseNode").toFunction(function(node:XML):void {
						currentUnitRenderer.data = node ? node.parent() : null;
					});
					break;
				case unitList:
					var unitListItemRenderer:ClassFactory = new ClassFactory(UnitListItemRenderer);
					unitListItemRenderer.properties = { copyProvider: copyProvider, showPieChart: false };
					instance.itemRenderer = unitListItemRenderer;
					
					if (selectedExerciseNode) {
						unitList.selectedItem = selectedExerciseNode.parent();
						// How am I supposed to select an exercise???
					}
					
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
			
			// Use the generic sendNotification signal so we don't need to override the mediator just for the sake of this
			sendNotification.dispatch(ClearPronunciationNotifications.YOUWILL_SHOW, prefix + exerciseIndex);
		}
		
	}
}