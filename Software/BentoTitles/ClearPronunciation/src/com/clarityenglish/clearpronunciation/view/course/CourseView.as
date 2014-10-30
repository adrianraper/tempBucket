package com.clarityenglish.clearpronunciation.view.course
{
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.clearpronunciation.view.home.event.ListItemSelectedEvent;
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
	import flash.net.*;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.SWFLoader;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.events.EffectEvent;
	import mx.skins.halo.WindowBackground;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import skins.clearpronunciation.home.ui.UnitListItemRenderer;
	
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
	import spark.components.DataGroup;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
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
		
		[SkinPart]
		public var phonemicChartButton:Button;
		
		[SkinPart]
		public var youWillButton:Button;
		
		[SkinPart]
		public var logoutButton:Button;
		
		[Bindable]
		public var mediaFolder:String;
		
		[Bindable]
		private var unitLength:Number;
		
		// gh#870
		private var _unit:XML;
		private var _unitChanged:Boolean;
		private var _bentoExercise:XML;
		private var _bentoExerciseChanged:Boolean;
		private var _isExerciseVisible:Boolean;
		private var _exerciseVisibleChanged:Boolean;
		private var _currentExerciseIndex:Number = 0;
		private var _currentExerciseIndexChanged:Boolean;
		private var _unitListCollection:ListCollectionView;
		private var _unitListCollectionChanged:Boolean;
		private var _isPlatformTablet:Boolean;
		// gh#211
		private var currentIndex:Number;
		private var unitListLength:Number;		
		private var isOutsideClick:Boolean;
		private var isItemClick:Boolean;
		private var isHidden:Boolean;
		private var exerciseLength:Number;
		
		public var itemShow:Signal = new Signal(XML);
		// gh#849
		public var settingsShow:Signal = new Signal();
		public var record:Signal = new Signal();
		public var exerciseShow:Signal = new Signal(XML);
		public var nextExercise:Signal = new Signal();
		public var backExercise:Signal = new Signal();
		public var dirtyWarningShow:Signal = new Signal(Function);
		public var youWillShow:Signal = new Signal(String);
		public var logout:Signal = new Signal();
		
		public function CourseView():void {
			super();
			actionBarVisible = false;
			// if we don't add it, randomly click title bar will cause error
			tabBarVisible = false;
		}
		
		[Bindable]
		public function get unitListCollection():ListCollectionView {
			return _unitListCollection;
		}
		
		public function set unitListCollection(value:ListCollectionView):void {
			if (value) {
				if (!_unitListCollection) {
					_unitListCollection = value;
				} else if (value.toString() != _unitListCollection.toString()) {
					_unitListCollection = value;
				}	
			}
		}
		
		[Bindable]
		public function get unit():XML {
			return _unit;
		}
		
		public function set unit(value:XML):void {
			if (value) {
				_unit = value;
				_unitChanged = true;
				
				invalidateProperties();
			}		
		}
		
		public function set bentoExercise(value:XML):void {
			_bentoExercise = value;
			_bentoExerciseChanged = true;
			
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
			_currentExerciseIndexChanged = true;
			
			invalidateProperties();
		}
		
		public function set isPlatformTablet(value:Boolean):void {
			_isPlatformTablet = value;
		}
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
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
				// "+1" is add "practise exercise"
				unitLength = unit.exercise.(@["class"] == "exercise").exercise.length() + 1;
				_unitChanged = false;
			}
			
			if (_bentoExerciseChanged) {
				currentExerciseIndex = unit.exercise.(@["class"] == "exercise").exercise.(@id == _bentoExercise.@id).childIndex() + 1;
				_bentoExerciseChanged = false;
			}
			
			if (_exerciseVisibleChanged) {
				if (!_isExerciseVisible) {
					currentExerciseIndex = 0;
				}
			}
			
			if (_currentExerciseIndexChanged) {
				if (currentExerciseIndex == 0) {
					backButton.enabled = false;
					nextButton.enabled = true;
				} else if (currentExerciseIndex == (unitLength - 1)) {
					backButton.enabled = true;
					nextButton.enabled = false;
				} else {
					backButton.enabled = true;
					nextButton.enabled = true;
				}
				_currentExerciseIndexChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					var unitListItemRenderer:ClassFactory = new ClassFactory(UnitListItemRenderer);
					unitListItemRenderer.properties = { copyProvider: copyProvider, showPieChart: false, isPlatformTablet: _isPlatformTablet};
					unitList.itemRenderer = unitListItemRenderer;
					unitList.addEventListener(ListItemSelectedEvent.SELECTED, onListItemSelected);
					unitList.selectedIndex = unit.childIndex();
					callLater(scrollToIndex, [unitList, unit.childIndex()]);
					break;
				case settingsButton:
					settingsButton.addEventListener(MouseEvent.CLICK, onSettingsClick);
					settingsButton.label = copyProvider.getCopyForId("settingButton");
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
				case phonemicChartButton:
					phonemicChartButton.addEventListener(MouseEvent.CLICK, onPhonemicChartButtonClick);
					break;
				case youWillButton:
					youWillButton.addEventListener(MouseEvent.CLICK, onYouWillButtonClick);
					break;
				case logoutButton:
					logoutButton.addEventListener(MouseEvent.CLICK, OnLogoutButtonClick);
					break;
			}
		}
		
		protected function onListItemSelected(event:ListItemSelectedEvent):void {
			if (event.item) {
				if (unitList.selectedIndex != -1) {
					windowShade.contentGroup.height = 0;
				}
				
				var item:XML = event.item;
				if (item.hasOwnProperty("@class") && item.(@["class"] == "practiseSounds")) {				
					isExerciseVisible = false;
				} else {
					bentoExercise = item;
					isExerciseVisible = true;
				}
				itemShow.dispatch(item);
			}
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
			} else {
				nextExercise.dispatch();
				currentExerciseIndex ++;
			}
		}
		
		protected function onBackButtonClick(event:Event):void {
			if (getCurrentSkinState() == "unitExercise") {
				if (currentExerciseIndex > 1) {
					backExercise.dispatch();
				} else {
					isExerciseVisible = false;
				}
				currentExerciseIndex --;
			}
		}
		
		protected function onBackToMenuClick(event:Event):void {
			var next:Function = function():void {navigator.popView()};
			dirtyWarningShow.dispatch(next);	
		}
		
		protected function onPhonemicChartButtonClick(event:MouseEvent):void { 
			navigateToURL(new URLRequest(copyProvider.getCopyForId("phonemicChartURL")), "_blank");
		}
		
		protected function OnLogoutButtonClick(event:MouseEvent):void {
			logout.dispatch();
		}
		
		protected function onYouWillButtonClick(event:MouseEvent):void {
			if (unit.parent().@["class"] == "introduction") {
				youWillShow.dispatch("introductionYouWillLabel" + currentExerciseIndex);
			} else {
				youWillShow.dispatch("youWillLabel" + currentExerciseIndex);
			}
		}
		
		private function scrollToIndex(list:List,index:int):void
		{
			if (!list.layout)
				return;
			
			var dataGroup:DataGroup = list.dataGroup;
			
			var spDelta:Point = dataGroup.layout.getScrollPositionDeltaToElement(index);
			
			if (spDelta)
			{
				dataGroup.horizontalScrollPosition += spDelta.x;
				//move it to the top if the list has enough items
				if(spDelta.y > 0)
				{
					var maxVSP:Number = dataGroup.contentHeight - dataGroup.height + 160;
					var itemBounds:Rectangle = list.layout.getElementBounds(index);
					var newHeight:Number = dataGroup.verticalScrollPosition + spDelta.y 
						+ dataGroup.height - itemBounds.height;
					dataGroup.verticalScrollPosition = Math.min(maxVSP, newHeight);
				}
				else
				{
					dataGroup.verticalScrollPosition += spDelta.y;
					
				}
			}
		}
	}
}