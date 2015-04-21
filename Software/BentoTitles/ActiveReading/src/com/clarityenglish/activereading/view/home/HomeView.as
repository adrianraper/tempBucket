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
	import mx.effects.Move;
	import mx.effects.easing.Back;
import mx.events.EffectEvent;

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

		// gh#1090
		[Bindable]
		public var userNameCaption:String;
		
		[Bindable]
		public var exerciseXMLListCollection:XMLListCollection;

		[Bindable]
		public var isFirstClickCurrentUnitList:Boolean;

		[Bindable]
		public var isAnimationPlayed:Boolean;
		
		public var courseSelect:Signal = new Signal(XML);
		public var unitSelect:Signal = new Signal(XML);
		public var exerciseSelect:Signal = new Signal(XML);
		
		// gh#757
		private var _course:XML;
		private var _unit:XML;
		[Bindable]
		private var courseChanged:Boolean;
		private var unitChanged:Boolean;
		private var _courseIndex:Number;
		private var _isBackToHome:Boolean;
		private var _isInitialSelect:Boolean =  true;
		private var _isCourseSelectorClick:Boolean;
		private var _isUnitListClick:Boolean;
		private var _isDirectStart:Boolean;
		private var _directCourseID:String;
		private var _directUnitID:String;
		
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
			if (value) {
				_unit = value;
				unitChanged = true;
				invalidateProperties();
			}
		}
		
		[Bindable]
		public function get courseIndex():Number {
			return _courseIndex;
		}
		
		public function set courseIndex(value:Number):void {
			_courseIndex = value;
		}		
		
		[Bindable]
		public function get isBackToHome():Boolean {
			return _isBackToHome;
		}
		
		public function set isBackToHome(value:Boolean):void {
			_isBackToHome = value;
		}
		
		[Bindable]
		public function get isInitialSelect():Boolean {
			return _isInitialSelect;
		}
		
		public function set isInitialSelect(value:Boolean):void {
			_isInitialSelect = value;
		}
		
		[Bindable]
		public function get isCourseSelectorClick():Boolean {
			return _isCourseSelectorClick;
		}
		
		public function set isCourseSelectorClick(value:Boolean):void {
			_isCourseSelectorClick = value;
		}
		
		[Bindable]
		public function get isUnitListClick():Boolean {
			return _isUnitListClick;
		}
		
		public function set isUnitListClick(value:Boolean):void {
			_isUnitListClick = value;
		}
		
		public function set isDirectStart(value:Boolean):void {
			_isDirectStart = value;
		}
		
		[Bindable]
		public function get isDirectStart():Boolean {
			return _isDirectStart;
		}
		
		public function set directCourseID(value:String):void {
			_directCourseID = value;
		}
		
		[Bindable]
		public function get directCourseID():String {
			return _directCourseID;
		}
		
		public function set directUnitID(value:String):void {
			_directUnitID = value;
		}
		
		[Bindable]
		public function get directUnitID():String {
			return _directUnitID;
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
				courseSelector.isDirectStart = true;
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
			
			// for re-login
			if (!course && !unit) {
				courseSelector.level = null;
				unitList.visible = false;
				demoTooltipGroup.visible = false;
				isInitialSelect = true;
				courseSelector.level = null;
			}
			
			// for back from exercise or progress
			// This is the only place we set isBackToHome to true base on the courseSelector and unitList isn't clicked 
			if (!isCourseSelectorClick && !isUnitListClick) {
				if (course != null && courseChanged != false) {
					isBackToHome = true;
				}		
			} else if (isCourseSelectorClick) {
				isCourseSelectorClick = false;
			} else if (isUnitListClick) {
				isUnitListClick = false;
			}
			
			if (courseChanged && course) {
				courseIndex = menu.course.(@caption == course.@caption).childIndex();
				courseSelector.level = course;
				unitList.dataProvider = new XMLListCollection(course.unit);
				courseChanged = false;
			}
			
			if (unitChanged) {
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

				if (unitList.selectedIndex < 7) {
					exerciseGroup.verticalCenter = unitList.selectedIndex * 39 - 100;
				} else {
					exerciseGroup.verticalCenter = 7 * 39 - 100;
				}

				if (isFirstClickCurrentUnitList && !isAnimationPlayed) {
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
			
			if (!isDirectStart &&  event.node.@["class"].length() > 0) {
				courseSelect.dispatch(menu.course.(@["class"] == event.node.@["class"])[0]);
			}
		}
		
		protected function onUnitListClick(event:MouseEvent = null):void {
			var unitXML:XML =  unitList.selectedItem as XML;
			
			if (unitXML) {
				isUnitListClick = true;
				exerciseList.visible = true;
				demoTooltipGroup.visible = false;
				exerciseGroup.alpha = 1;

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
			isFirstClickCurrentUnitList = false;
		}
		
		protected function onExerciseGroupMoveEnd(event:Event):void {
			exerciseGroup.alpha = 1;
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
	}
}