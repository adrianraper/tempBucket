package com.clarityenglish.clearpronunciation.view.exercise {
	import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.clearpronunciation.ClearPronunciationNotifications;
	import com.clarityenglish.clearpronunciation.view.exercise.ui.WindowShade;
	import com.googlecode.bindagetools.Bind;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.setTimeout;
	
	import mx.core.ClassFactory;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
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
		public var windowShade:WindowShade;
		
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
					unitListItemRenderer.properties = { copyProvider: copyProvider, showPieChart: false, selectedExercise: selectedExerciseNode };
					instance.itemRenderer = unitListItemRenderer;
					
					// When a unit is selected make sure it is visible
					unitList.addEventListener(IndexChangeEvent.CHANGE, function(e:IndexChangeEvent):void { unitList.ensureIndexIsVisible(e.newIndex); });
					
					// Listen for exercise changes
					unitList.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					
					// Select the current unit and exercise
					/*if (selectedExerciseNode) {
						unitList.selectedItem = selectedExerciseNode.parent();
						callLater(function():void { unitList.ensureIndexIsVisible(unitList.selectedIndex); });
						
						// How am I supposed to select an exercise???
						
					}*/
					Bind.fromProperty(this, "selectedExerciseNode").toFunction(function(node:XML):void {
						unitList.selectedItem = node.parent();
						callLater(function():void { unitList.ensureIndexIsVisible(unitList.selectedIndex); });
					});
					break;
				case phonemicChartButton:
					phonemicChartButton.addEventListener(MouseEvent.CLICK, onPhonemicChartButtonClick);
					break;
				case youWillButton:
					youWillButton.addEventListener(MouseEvent.CLICK, onYouWillButtonClick);
					break;
			}
		}
		
		protected function onExerciseSelected(e:ExerciseEvent):void {
			windowShade.close();
			setTimeout(nodeSelect.dispatch, 400, e.node);
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