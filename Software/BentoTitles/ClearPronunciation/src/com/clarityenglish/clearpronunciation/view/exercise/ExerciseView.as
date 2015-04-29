package com.clarityenglish.clearpronunciation.view.exercise {
import com.clarityenglish.bento.BentoApplication;
import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
import com.clarityenglish.bento.vo.content.Exercise;
import com.clarityenglish.clearpronunciation.ClearPronunciationNotifications;
	import com.clarityenglish.clearpronunciation.view.exercise.ui.WindowShade;
	import com.googlecode.bindagetools.Bind;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.setTimeout;
	
	import mx.core.ClassFactory;
	
	import org.davekeen.util.XmlUtils;
	import org.osflash.signals.Signal;
	
	import skins.clearpronunciation.exercise.ui.WindowShadeSkin;
	import skins.clearpronunciation.home.ui.UnitListItemRenderer;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
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
		
		protected override function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
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
					var exerciseSelected:Signal = new Signal(XML);
					
					var unitListItemRenderer:ClassFactory = new ClassFactory(UnitListItemRenderer);
					unitListItemRenderer.properties = { copyProvider: copyProvider, showPieChart: false, selectedExerciseNode: selectedExerciseNode, exerciseSelected: exerciseSelected };
					instance.itemRenderer = unitListItemRenderer;
					
					// When a unit is selected make sure it is visible
					unitList.addEventListener(IndexChangeEvent.CHANGE, function(e:IndexChangeEvent):void { unitList.ensureIndexIsVisible(e.newIndex); });
					
					// Listen for exercise changes
					unitList.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					
					// Select the current unit and exercise
					Bind.fromProperty(this, "selectedExerciseNode").toFunction(function(node:XML):void {
						if (node) {
							unitList.selectedItem = node.parent();
							callLater(function():void {
								unitList.ensureIndexIsVisible(unitList.selectedIndex);
								exerciseSelected.dispatch(node);
							});
						}	
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
			if (e.node) {
				windowShade.close();
				setTimeout(nodeSelect.dispatch, 400, e.node);
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

		public function getEnalbedUnitList(course:XML):XMLList {
			if (course) {
				var units:XMLList = new XMLList();

				// For demo version, except demo unit other units should not show in drop down list in exercise
				for each (var unitNode:XML in course.unit) {
					if (productVersion == BentoApplication.DEMO) {
						if (unitNode.attribute("enabledFlag").length() > 0 && (unitNode.@enabledFlag.toString() & 4)) {
							units += unitNode;
						}
					} else {
						if (unitNode.attribute("enabledFlag").length() > 0 && (unitNode.@enabledFlag.toString() & 3)) {
							units += unitNode;
						}
					}
				}
				return units;
			} else {
				return null;
			}

		}
	}
}