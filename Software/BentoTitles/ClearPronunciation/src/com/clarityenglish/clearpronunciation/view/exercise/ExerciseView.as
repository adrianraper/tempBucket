package com.clarityenglish.clearpronunciation.view.exercise {
import com.clarityenglish.bento.BentoApplication;
import com.clarityenglish.bento.events.ExerciseEvent;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
import com.clarityenglish.bento.vo.content.Exercise;
import com.clarityenglish.clearpronunciation.ClearPronunciationNotifications;
	import com.clarityenglish.clearpronunciation.view.exercise.ui.WindowShade;
import com.clarityenglish.textLayout.vo.XHTML;
import com.googlecode.bindagetools.Bind;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.setTimeout;

import mx.controls.SWFLoader;

import mx.core.ClassFactory;
	
	import org.davekeen.util.XmlUtils;
	import org.osflash.signals.Signal;
	
	import skins.clearpronunciation.exercise.ui.WindowShadeSkin;
	import skins.clearpronunciation.home.ui.UnitListItemRenderer;
	
	import spark.components.Button;
	import spark.components.Label;
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

		[SkinPart]
		public var makeSoundsLabel:Label;

		[SkinPart]
		public var tabletAnimationAlertLabel:Label;

		[SkinPart]
		public var makeSoundsGroup:spark.components.Group;

		[SkinPart]
		public var instructionLabel:Label;

		[SkinPart]
		public var redArrowTitleLabel:Label;

		[SkinPart]
		public var redArrowLabel:Label;

		[SkinPart]
		public var yellowArrowLabel:Label;

		[SkinPart]
		public var yellowArrowTileLabel:Label;

		[SkinPart]
		public var leftAnimation:SWFLoader;

		[SkinPart]
		public var leftAnimationLabel:Label;

		[SkinPart]
		public var rightAnimation:SWFLoader;

		[SkinPart]
		public var rightAnimationLabel:Label;

		[Bindable]
		public var selectedExerciseNode:XML;

		[Bindable]
		public var rootPath:String;

		public function ExerciseView() {
			super();
		}
		
		protected override function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
		}

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);

			if (xhtml && !isPlatformTablet) {
                var replaceObj:Object = {newline: '\n'};
				if (selectedExerciseNode.parent().hasOwnProperty('@leftAnimation')) {
					leftAnimation.source = xhtml.rootPath + '../../media/' + selectedExerciseNode.parent().@leftAnimation  + '.swf';
					leftAnimationLabel.visible = true;
                    replaceObj.ipa = copyProvider.getCopyForId(selectedExerciseNode.parent().attribute('leftIcon'));
                    replaceObj.compareipa = copyProvider.getCopyForId(selectedExerciseNode.parent().attribute('rightIcon'));
					leftAnimationLabel.text = copyProvider.getCopyForId(selectedExerciseNode.parent().attribute('leftIcon') + "Instruction", replaceObj);
				} else {
					leftAnimation.source = null;
					leftAnimationLabel.visible = false;
				}

				if (selectedExerciseNode.parent().hasOwnProperty('@rightAnimation')) {
					rightAnimation.source = xhtml.rootPath + '../../media/' + selectedExerciseNode.parent().@rightAnimation  + '.swf';
					rightAnimationLabel.visible = true;
                    replaceObj.ipa = copyProvider.getCopyForId(selectedExerciseNode.parent().attribute('rightIcon'));
                    replaceObj.compareipa = copyProvider.getCopyForId(selectedExerciseNode.parent().attribute('leftIcon'));
					rightAnimationLabel.text = copyProvider.getCopyForId(selectedExerciseNode.parent().attribute('rightIcon') + "Instruction", replaceObj);
				} else {
					rightAnimation.source = null;
					rightAnimationLabel.visible = false;
				}
			}

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
				case makeSoundsLabel:
					makeSoundsLabel.text = copyProvider.getCopyForId("makeSoundsLabel");
					break;
				case instructionLabel:
					instructionLabel.text = copyProvider.getCopyForId("instructionLabel");
					break;
				case redArrowTitleLabel:
					redArrowTitleLabel.text = copyProvider.getCopyForId("redArrowTitleLabel");
					break;
				case redArrowLabel:
					redArrowLabel.text = copyProvider.getCopyForId("redArrowLabel");
					break;
				case yellowArrowLabel:
					yellowArrowLabel.text = copyProvider.getCopyForId("yellowArrowLabel");
					break;
				case yellowArrowTileLabel:
					yellowArrowTileLabel.text = copyProvider.getCopyForId("yellowArrowTileLabel");
					break;
				case tabletAnimationAlertLabel:
					tabletAnimationAlertLabel.text = copyProvider.getCopyForId("tabletAnimationAlertLabel");
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