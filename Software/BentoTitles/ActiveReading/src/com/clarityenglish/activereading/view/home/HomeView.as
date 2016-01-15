package com.clarityenglish.activereading.view.home {
	import com.clarityenglish.activereading.view.event.NodeSelectEvent;
	import com.clarityenglish.activereading.view.home.ui.ARCourseSelector;
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.textLayout.vo.XHTML;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import mx.collections.XMLListCollection;
	import mx.core.FlexGlobals;
	import mx.core.ScrollPolicy;
import mx.effects.Fade;
import mx.effects.Move;
import mx.effects.Resize;
import mx.effects.easing.Back;
    import mx.events.EffectEvent;
import mx.graphics.SolidColorStroke;

import org.osflash.signals.Signal;

	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
import spark.effects.Scale;
    import spark.primitives.Path;
    import spark.primitives.Rect;

    public class HomeView extends BentoView {
		
		[SkinPart]
		public var instructionGroup:Group;
		
		[SkinPart]
		public var instructionLabel:Label; 
		
		[SkinPart]
		public var homeInstructionLabel:Label;
		
		[SkinPart]
		public var courseSelector:ARCourseSelector;
		
		[SkinPart]
		public var unitList:List;
		
		[SkinPart]
		public var levelTitleGroup:Group;

		[SkinPart]
		public var levelTitleGroupLabel:Label;
		
		[SkinPart]
		public var trianglePath:Path;
		
		[SkinPart]
		public var exerciseGroup:Group;

		[SkinPart]
		public var exerciseRect:Rect;
		
		[SkinPart]
		public var triangleGroup:Group;

		[SkinPart]
		public var exerciseListLabel:Label;
		
		[SkinPart]
		public var exerciseList:List;
		
		[SkinPart]
		public var triangleReferenceGroup:Group;
		
		[SkinPart]
		public var demoTooltipGroup:Group;
		
		[SkinPart]
		public var demoTooltipLabel1:Label;
		
		[SkinPart]
		public var demoTooltipLabel2:Label;
		
		[SkinPart]
		public var versionLabel:Label;
		
		[SkinPart]
		public var copyrightLabel:Label;

		[SkinPart]
		public var unitTitleBarStrokeColour:SolidColorStroke;

		// gh#1090
		[Bindable]
		public var userNameCaption:String;
		
		[Bindable]
		public var exerciseXMLListCollection:XMLListCollection;

		[Bindable]
		public var courseIndex:Number;

		[Bindable]
		public var isAnimationPlayed:Boolean;

		[Bindable]
		public var isUnitListClicked:Boolean;

		[Bindable]
		public var isClickOnUnitList:Boolean;

		[Bindable]
		public var isClickOnCourseSelector:Boolean;

		[Bindable]
		public var isInitialSelect:Boolean;

		[Bindable]
		public var isDirectStart:Boolean;

		[Bindable]
		public var directCourseID:String;

		[Bindable]
		public var directUnitID:String;

		[Bindable]
		public var directExerciseID:String;

		[Bindable]
		public var exListAlphaArray:Array = [];
		
		public var courseSelect:Signal = new Signal(XML);
		public var unitSelect:Signal = new Signal(XML);
		public var exerciseSelect:Signal = new Signal(XML);
		
		// gh#757
		private var _course:XML;
		private var _unit:XML;
		[Bindable]
		private var courseChanged:Boolean;
		private var unitChanged:Boolean;
		
		// gh#757
		[Bindable]
		public function get course():XML {
			return _course;
		}
		
		// gh#757
		public function set course(value:XML):void {
			_course = value;
			courseChanged = true;
			invalidateProperties();
		}
		
		[Bindable]
		public function get unit():XML {
			return _unit;
		}
		
		public function set unit(value:XML):void {
			_unit = value;
			unitChanged = true;
			invalidateProperties();
		}
		
		public function HomeView():void {
			actionBarVisible = false;
		}
		
		// gh#487
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		override protected function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (!courseSelector.level) {
				instructionGroup.visible = true;
				var downMove:Move = new Move();
				downMove.yFrom = 0;
				downMove.yTo = 160;
				downMove.duration = 300;
				downMove.play([instructionGroup]);
			}
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			if (courseSelector)
				courseSelector.dataProvider = menu;
			
			if (isDirectStart) {
				if (directCourseID)
					course = menu.course.(@id == directCourseID)[0];
				if (directUnitID) {
					unit = course.unit.(@id == directUnitID)[0];
				}
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case homeInstructionLabel:
					homeInstructionLabel.text = copyProvider.getCopyForId("homeInstructionLabel");
					break;
				case courseSelector:
					courseSelector.addEventListener(NodeSelectEvent.NODE_SELECT, onCourseSelect);
					courseSelector.addEventListener("animationCompleted", onCourseAnimationCompleted, false, 0, true);
					break;
				case unitList:
					unitList.addEventListener(MouseEvent.CLICK, onUnitListClick);
					unitList.setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
					break;
				case exerciseList:
					exerciseList.addEventListener(MouseEvent.CLICK, onExerciseListClick);
					exerciseList.setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
					break;
				case instructionLabel:
					instructionLabel.text = copyProvider.getCopyForId("instructionLabel");				
					break;
				case demoTooltipLabel1:
					demoTooltipLabel1.text = copyProvider.getCopyForId("demoTooltipLabel1");
					break;
				case demoTooltipLabel2:
					demoTooltipLabel2.text = copyProvider.getCopyForId("demoTooltipLabel2");
					break;
				case versionLabel:
					versionLabel.text = copyProvider.getCopyForId("versionLabel", {versionNumber: FlexGlobals.topLevelApplication.versionNumber});
					break;
				case copyrightLabel:
					copyrightLabel.text = copyProvider.getCopyForId("copyright");
					break;
			}
		}
		
		protected override function commitProperties():void {			
			super.commitProperties();

			// gh#1194
			userNameCaption = '';
			if (config.username == null || config.username == '') {
				if (config.email)
					userNameCaption = copyProvider.getCopyForId('welcomeLabel', {name: config.email});
			} else if (config.username.toLowerCase() != 'anonymous') {
				userNameCaption = copyProvider.getCopyForId('welcomeLabel', {name: config.username});
			}
			
			// For re-login, reset all value
			if (!course && !unit) {
				isInitialSelect = true;
				courseSelector.level = null;
				unitList.visible = false;
				demoTooltipGroup.visible = false;
				courseSelector.level = null;
				levelTitleGroup.alpha = 0;
				isClickOnCourseSelector = false;
				exerciseGroup.visible = false;
				exerciseGroup.alpha = 0;
			}

			if (courseChanged && course) {
				courseIndex = menu.course.(@caption == course.@caption).childIndex();
				courseSelector.level = course;
				unitList.dataProvider = new XMLListCollection(course.unit);
				if (!isClickOnCourseSelector) {
					levelTitleGroup.alpha = 1;
					levelTitleGroupLabel.text = course.@caption;
					levelTitleGroupLabel.setStyle("color", getOutlineStrokeColour(courseIndex));
					unitList.height = unitList.dataProvider.length * 39 + 5;
					unitList.visible = true;
				}
				courseChanged = false;
			}
			
			if (unitChanged && unit) {
				// used to put reload exercise in unit click handler, but turns out that evaluation to unit.exercise will cause unit select effect disfunctional
				// so the exercise reload function will be put here and the data provider.
				exerciseXMLListCollection = new XMLListCollection(getExercisesList(unit));
				exerciseList.dataProvider = exerciseXMLListCollection;

				exerciseListLabel.text = unit.attribute("alt");
				if (exerciseListLabel.text.length < 21) {
					exerciseGroup.height = exerciseRect.height = exerciseXMLListCollection.length * 31 + 75;
				} else {
					exerciseGroup.height = exerciseRect.height = exerciseXMLListCollection.length * 31 + 95;
				}

				if (!exerciseGroup.visible && !isAnimationPlayed) {
					exerciseGroup.visible = true;
					exerciseGroup.alpha = 1;
					if (isClickOnUnitList) {
						var scale:Scale = new Scale();
						scale.scaleYFrom = 0;
						scale.scaleYTo = 1;
						scale.duration = 500;
						scale.addEventListener(EffectEvent.EFFECT_END, onScaleEnd);
						scale.play([exerciseRect]);

						var fadeIn:mx.effects.Fade = new mx.effects.Fade();
						fadeIn.alphaFrom = 0;
						fadeIn.alphaTo = 1;
						fadeIn.duration = 400;
						fadeIn.startDelay = 200;
						fadeIn.play([triangleGroup, exerciseListLabel]);

						isClickOnUnitList = false;
					} else {
						unitList.selectedIndex = course.unit.(@id == unit.@id).childIndex();
						exerciseGroup.verticalCenter = unitList.selectedIndex < 7 ? (unitList.selectedIndex * 39 - 100) : (7 * 39 - 100);
						triangleReferenceGroup.y = unitList.selectedIndex * 37 + 65;
						exerciseRect.scaleY = 1;
						triangleGroup.alpha = exerciseListLabel.alpha = 1;
						isUnitListClicked = true;
					}

					// for exercise list frame, when the list doesn't roll out completely and we selecte another unit, we don't want it to roll out again
					isAnimationPlayed = true;
				}

				unitChanged = false;
			}
		}
		
		override protected function getCurrentSkinState():String {
				return super.getCurrentSkinState();
		}
		
		protected function onCourseSelect(event:NodeSelectEvent):void {
			instructionGroup.visible = false;
			isClickOnCourseSelector = true;
			unitList.visible = false;
			exerciseList.visible = false;

			if (!isDirectStart &&  event.node.@["class"].length() > 0) {
				courseSelect.dispatch(menu.course.(@["class"] == event.node.@["class"])[0]);
			}

			// we need to detect the first click. If it is, the levelTitleGroup won't fade out, because it never fade in before.
			if (isInitialSelect) {
				isInitialSelect = false;
			} else {
				var titleFadeOut:mx.effects.Fade = new Fade();
				titleFadeOut.alphaFrom = 1.0;
				titleFadeOut.alphaTo = 0.0;
				titleFadeOut.duration = 200;
				titleFadeOut.play([levelTitleGroup]);
				titleFadeOut.addEventListener(EffectEvent.EFFECT_END, OnLevelTitleGroupFadeOutEnd);

				// if we don't add the following condition, the  will flash when we only switch the unit list
				if (exerciseGroup.visible) {
					var exerciseFadeOut:mx.effects.Fade = new mx.effects.Fade();
					exerciseFadeOut.alphaFrom = 1;
					exerciseFadeOut.alphaTo = 0;
					exerciseFadeOut.duration = 100;
					exerciseFadeOut.play([exerciseGroup, triangleGroup]);
					exerciseFadeOut.addEventListener(EffectEvent.EFFECT_END, onExerciseGroupFadeOutEnd);

					isUnitListClicked = false;
				}
			}
		}

		protected function onCourseAnimationCompleted(event:Event):void {
			if (isClickOnCourseSelector) {
				levelTitleGroupLabel.text = course.@caption;
				levelTitleGroupLabel.setStyle("color", getOutlineStrokeColour(courseIndex));
				var	fadeIn:mx.effects.Fade = new Fade();
				fadeIn.alphaFrom = 0.0;
				fadeIn.alphaTo = 1.0;
				fadeIn.duration = 100;
				fadeIn.play([levelTitleGroup]);
				fadeIn.addEventListener(EffectEvent.EFFECT_END, onUnitTitleBarFadeInEnd);

				isClickOnCourseSelector = false;
			}
		}
		
		protected function onUnitListClick(event:MouseEvent = null):void {
			var unitXML:XML =  unitList.selectedItem as XML;

			if (unitXML) {
				isClickOnUnitList = true;
				exerciseList.visible = true;
				demoTooltipGroup.visible = false;
				exerciseGroup.verticalCenter = unitList.selectedIndex < 7 ? (unitList.selectedIndex * 39 - 100) : (7 * 39 - 100);

				if (triangleReferenceGroup.y) {
					var move:Move = new Move();
					move.easingFunction = Back.easeOut;
					move.yFrom = triangleReferenceGroup.y;
					move.yTo = unitList.selectedIndex * 38 + 65;	
					move.duration = 300;
					move.play([triangleReferenceGroup]);
				} else {
					triangleReferenceGroup.y = unitList.selectedIndex * 38 + 65;
				}

				unitSelect.dispatch(unitXML);
			}	
		}

		protected function onScaleEnd(event:Event):void {
			// for the item on exercise list, when you first click unit with 6 exercises, and then click another with 11,
			// the first 6 items has played fade in already and won't play again, but we also don't want the rest 5 items played fade in. So we use isFirstClickUnitList to avoid playing
			isUnitListClicked = true;
		}
		
		// hide the invisible exercise
		public function getExercisesList(unit:XML):XMLList {
			if (unit) {
				var exercises:XMLList = new XMLList();
				
				for each (var exerciseNode:XML in unit.exercise) {
					if (Exercise.showExerciseInMenu(exerciseNode)){
						exercises += exerciseNode;
					}
				}				
				return exercises;
			} else {
				return null;
			}
			
		}
		
		public function onExerciseListClick(event:MouseEvent):void {
			var exercise:XML = event.currentTarget.selectedItem as XML;
			if (exercise && Exercise.exerciseEnabledInMenu(exercise)) exerciseSelect.dispatch(exercise);
			
			if(this.productVersion == BentoApplication.DEMO && !Exercise.exerciseEnabledInMenu(exercise)) {
				var pt:Point = new Point(event.localX, event.localY);
				pt = event.target.localToGlobal(pt);
				pt = exerciseGroup.globalToContent(pt);
				demoTooltipGroup.top = pt.y;
				demoTooltipGroup.visible = true;
			}
		}

		private function OnLevelTitleGroupFadeOutEnd(event:Event):void {
			unitTitleBarStrokeColour.color = getOutlineStrokeColour(courseIndex);
		}

		private function onExerciseGroupFadeOutEnd(event:Event):void {
			exerciseGroup.visible = false;
		}

		private function onUnitTitleBarFadeInEnd(event:Event):void {
			unitList.visible = true;

			var resize:mx.effects.Resize = new Resize();
			resize.heightFrom = 0;
			// calculate the unit list height here, 13 is the sum for padding top and bottom
			resize.heightTo = unitList.dataProvider.length * 39 + 5;
			resize.duration = 300;
			resize.addEventListener(EffectEvent.EFFECT_END, onUnitListResizeEnd);
			resize.play([unitList]);
		}

		private function onUnitListResizeEnd(event:Event):void {
			isAnimationPlayed = false;
			isClickOnUnitList = false;
			isUnitListClicked = false;
			exListAlphaArray = [];
			triangleGroup.alpha = 0;
			exerciseListLabel.alpha = 0;
			triangleReferenceGroup.y = new Number();
		}

		private function getOutlineStrokeColour(index:Number):Number {
			var colors:Array = getStyle("outlineColors");
			return colors[index]
		}
	}
}