package com.clarityenglish.clearpronunciation.view.course
{
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.clearpronunciation.view.unit.UnitView;
	import com.clarityenglish.clearpronunciation.vo.WindowShade;
	import com.clarityenglish.clearpronunciation.vo.transform.SingleVideoNodeTransform;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.rotterdam.view.course.events.UnitDeleteEvent;
	import com.clarityenglish.rotterdam.view.course.ui.PublishButton;
	import com.clarityenglish.rotterdam.view.schedule.ScheduleView;
	import com.clarityenglish.rotterdam.view.settings.SettingsView;
	import com.clarityenglish.rotterdam.view.unit.UnitHeaderView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.globalization.DateTimeFormatter;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.SWFLoader;
	import mx.events.CloseEvent;
	import mx.events.EffectEvent;
	import mx.skins.halo.WindowBackground;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.ToggleButton;
	import spark.components.ViewNavigator;
	import spark.effects.Animate;
	import spark.events.IndexChangeEvent;
	
	import ws.tink.spark.controls.Alert;
	
	/*[SkinState("uniteditor")] - this is an optional skin state */
	public class CourseView extends BentoView {
		
		[SkinPart]
		public var unitView:UnitView;
		
		[SkinPart]
		public var swfloaderHGroup:HGroup;
		
		[SkinPart]
		public var expandUnitListButton:ToggleButton;
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart]
		public var unitListExpandAnimate:Animate;
		
		[SkinPart]
		public var unitListCollapseAnimate:Animate;
		
		[SkinPart]
		public var settingsButton:Button;
		
		[SkinPart]
		public var anim:Animate;
		
		[SkinPart]
		public var recorderButton:Button;
		
		[SkinPart]
		public var backButton:Button;
		
		[SkinPart]
		public var nextButton:Button;
		
		[SkinPart]
		public var unitViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var backToMenuButton:Button;
		
		[SkinPart]
		public var windowShade:WindowShade;
		
		[Bindable]
		public var unitListCollection:ListCollectionView;
		
		[Bindable]
		public var mediaFolder:String;
		
		// gh#208 DK: should we pass the group from the mediator to here so that the view can create the default node
		// or should we just let the mediator do it?
		public var group:com.clarityenglish.common.vo.manageable.Group;
		
		private var _course:XML;
		// gh#870
		private var _unit:XML;
		private var _unitChanged:Boolean;
		private var courseChanged:Boolean;
		// gh#211
		private var currentIndex:Number;
		private var unitListLength:Number;		
		private var isOutsideClick:Boolean;
		private var isItemClick:Boolean;
		private var isHidden:Boolean;
		private var _isExerciseVisible:Boolean;
		private var _exerciseVisibleChanged:Boolean;
		private var _currentExerciseIndex:Number;
		private var exerciseLength:Number;
		
		public var unitSelect:Signal = new Signal(XML);
		// gh#849
		public var settingsShow:Signal = new Signal();
		public var record:Signal = new Signal();
		public var exerciseShow:Signal = new Signal(XML);
		public var nextExercise:Signal = new Signal();
		public var backExercise:Signal = new Signal();
		
		public function CourseView():void {
			super();
			actionBarVisible = false;
			// if we don't add it, randomly click title bar will cause error
			tabBarVisible = false;
		}
		
		[Bindable]
		public function get course():XML {
			return _course;
		}
		
		public function set course(value:XML):void {
			if (_course != value) {
				_course = value;
				courseChanged = true;
				invalidateProperties();
			}
		}
		
		[Bindable]
		public function get unit():XML {
			return _unit;
		}
		
		public function set unit(value:XML):void {
			_unit = value;
			_unitChanged = true;
			
			invalidateProperties();
		}
		
		// use to know whether the current page is unit widget or exercise
		[Bindable]
		public function get isExerciseVisible():Boolean {
			return _isExerciseVisible;
		}
		
		public function set isExerciseVisible(value:Boolean):void {
			_isExerciseVisible = value;
			_exerciseVisibleChanged = true;
			
			invalidateProperties();
			invalidateSkinState();
		}
		
		[Bindable]
		public function get currentExerciseIndex():Number {
			return _currentExerciseIndex;
		}
		
		public function set currentExerciseIndex(value:Number):void {
			_currentExerciseIndex = value;
		}
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			course = _xhtml.selectOne("script#model[type='application/xml'] course");
		}
		
		// gh#208
		protected override function onAddedToStage(event:Event):void {
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			// set unit list to select the correct unit
			if (_unitChanged) {
				unitList.selectedItem = unit;
				_unitChanged = true;
			}
			
			if (_exerciseVisibleChanged) {
				if (isExerciseVisible) {
					backButton.enabled = true;
				} else {
					backButton.enabled = false;
					nextButton.enabled = true;
				}
				_exerciseVisibleChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:									
					unitList.dragEnabled = unitList.dropEnabled = unitList.dragMoveEnabled = true;
					unitList.addEventListener(IndexChangeEvent.CHANGE, onUnitSelected);
					break;
				case settingsButton:
					instance.addEventListener(MouseEvent.CLICK, onSettingsClick);
					instance.label = copyProvider.getCopyForId("settingButton");
					break;
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuClick);
					break;
				case recorderButton:
					recorderButton.addEventListener(MouseEvent.CLICK, onRecorderClick);
					break;
				case nextButton:
					nextButton.addEventListener(MouseEvent.CLICK, onNextButtonClick);
					nextButton.label = copyProvider.getCopyForId("Next");
					break;
				case backButton:
					backButton.addEventListener(MouseEvent.CLICK, onBackButtonClick);
					backButton.label = copyProvider.getCopyForId("Back");
					break;
			}
		}
		
		protected function onUnitSelected(event:IndexChangeEvent):void {
			if (unitList.selectedIndex != -1) {
				// to hide vertical scroll bar, use verticalScrollPolicy = off
				windowShade.close();
			}
			
			if (isExerciseVisible) {
				isExerciseVisible = false;
			}
			unitSelect.dispatch(event.target.selectedItem);
		}
		
		/**
		 * TODO: Switch between editing and viewing
		 */
		protected override function getCurrentSkinState():String {
			return (isExerciseVisible)? "unitExercise" : "unitWidget";
		}
		
		
		// gh#208
		protected function onStageClick(event:MouseEvent):void {						
		}
		
		protected function onSettingsClick(event:MouseEvent):void {
			// gh#849
			settingsShow.dispatch();
		}
		
		protected function onRecorderClick(event:Event):void {
			record.dispatch();
		}
		
		protected function onNextButtonClick(event:Event):void {
			if (getCurrentSkinState() == "unitWidget") {
				isExerciseVisible = true;
				
				exerciseShow.dispatch(unit.exercise.(@["class"] == "exercise").exercise[0]);
				currentExerciseIndex = 1;
				exerciseLength = unit.exercise.(@["class"] == "exercise").exercise.length();
			} else {
				nextExercise.dispatch();
				currentExerciseIndex++;
			}
			
			if (currentExerciseIndex == exerciseLength) {
				nextButton.enabled = false;
			} else {
				nextButton.enabled = true;
			}
		}
		
		protected function onBackButtonClick(event:Event):void {
			if (getCurrentSkinState() == "unitExercise") {
				nextButton.enabled = true;
				
				if (currentExerciseIndex == 1) {
					isExerciseVisible = false;					
				} else {
					backExercise.dispatch();
					currentExerciseIndex--;
				}
			}
		}
		
		protected function onBackToMenuClick(event:Event):void {
			navigator.popView();
		}
		
	}
}