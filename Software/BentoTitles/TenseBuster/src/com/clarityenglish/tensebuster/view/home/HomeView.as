package com.clarityenglish.tensebuster.view.home {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.tensebuster.view.home.courseselector.TBCourseSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.collections.XMLListCollection;
	import mx.core.FlexGlobals;
	import mx.effects.Fade;
	import mx.effects.Move;
	import mx.effects.Parallel;
	import mx.effects.Resize;
	import mx.effects.easing.Back;
	import mx.effects.easing.Bounce;
	import mx.effects.easing.Elastic;
	import mx.events.CollectionEvent;
	import mx.events.EffectEvent;
	import mx.graphics.GradientEntry;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.VGroup;
	import spark.primitives.Path;
	
	public class HomeView extends BentoView {
		
		[SkinPart]
		public var instructionGroup:Group;
		
		[SkinPart]
		public var instructionLabel:Label; 
		
		[SkinPart]
		public var homeInstructionLabel:Label;
		
		[SkinPart]
		public var courseSelector:TBCourseSelector;
		
		[SkinPart]
		public var unitList:List;
		
		[SkinPart]
		public var levelTitleGroup:Group;
		
		[SkinPart]
		public var trianglePath:Path;
		
		[SkinPart]
		public var exerciseGroup:Group;
		
		[SkinPart]
		public var triangleGroup:Group;
		
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
		
		public var courseSelect:Signal = new Signal(XML);
		public var unitSelect:Signal = new Signal(XML);
		public var exerciseSelect:Signal = new Signal(XML);
		
		[Bindable]
		public var accountName:String;
		
		// gh#757
		private var _course:XML;
		private var _unit:XML;
		[Bindable]
		private var courseChanged:Boolean;
		private var unitChanged:Boolean;
		private var _courseIndex:Number;
		private var _isBackToHome:Boolean;
		private var _isInitialSelect:Boolean =  true;
		private var _androidSize:String;
		private var _isCourseSelectorClick:Boolean
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
			_unit = value;
			unitChanged = true;
			invalidateProperties();
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
		
		public function set androidSize(value:String):void {
			_androidSize = value;
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
			
			// gh#1090 Allow username on home screen
			if (config.signInAs == Title.SIGNIN_TRACKING)
				accountName = copyProvider.getCopyForId("accountNameLabel", {name:config.username});
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
					courseSelector.addEventListener("elementarySelected", onCourseSelectorClick, false, 0, true);
					courseSelector.addEventListener("lowerInterSelected", onCourseSelectorClick, false, 0, true);
					courseSelector.addEventListener("intermediateSelected", onCourseSelectorClick, false, 0, true);
					courseSelector.addEventListener("upperInterSelected", onCourseSelectorClick, false, 0, true);
					courseSelector.addEventListener("advancedSelected", onCourseSelectorClick, false, 0, true);
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
			}
		}
		
		protected override function commitProperties():void {			
			super.commitProperties();
			
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
				exerciseList.dataProvider = new XMLListCollection(getExercisesList(unit));
				unitChanged = false;
			}
		}
		
		override protected function getCurrentSkinState():String {
			if (_androidSize) {
				return super.getCurrentSkinState() + _androidSize;
			} else {
				return super.getCurrentSkinState();
			}
		}
		
		protected function onCourseSelectorClick(event:Event):void {
			instructionGroup.visible = false;
			
			if (!isDirectStart) {
				switch (event.type) {
					case "elementarySelected":
						courseSelect.dispatch(menu.course.(@["class"] == "elementary")[0]);
						break;
					case "lowerInterSelected":
						courseSelect.dispatch(menu.course.(@["class"] == "lowerintermediate")[0]);
						break;
					case "intermediateSelected":
						courseSelect.dispatch(menu.course.(@["class"] == "intermediate")[0]);
						break;
					case "upperInterSelected":
						courseSelect.dispatch(menu.course.(@["class"] == "upperintermediate")[0]);
						break;
					case "advancedSelected":
						courseSelect.dispatch(menu.course.(@["class"] == "advanced")[0]);
						break;
					default:
						log.error("Unable to find a matching course");
				}
			}
		}
		
		protected function onUnitListClick(event:MouseEvent = null):void {
			var unitXML:XML =  unitList.selectedItem as XML;

			if (unitXML) {
				if (triangleReferenceGroup.y) {
					var move:Move = new Move();
					move.easingFunction = Back.easeOut;
					move.yFrom = triangleReferenceGroup.y;
					move.yTo = 50 + unitList.selectedIndex * 39;	
					move.duration = 300;
					move.play([triangleReferenceGroup]);
				} else {
					triangleReferenceGroup.y = 50 + unitList.selectedIndex * 39;
				}
				
				//trianglePath.top = 50 + event.currentTarget.selectedIndex * 39;				
				// adjust exercise group position for elementary last unit
				if (courseIndex == 0 && course.unit.(@id == unitXML.@id).childIndex() == (course.unit.length() - 1)) {
					exerciseGroup.verticalCenter = 40;
				} else {
					exerciseGroup.verticalCenter = 0;
				}

				unitSelect.dispatch(unitXML);
			}	
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