package com.clarityenglish.tensebuster.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.tensebuster.view.home.HomeView;
	import com.clarityenglish.tensebuster.view.unit.UnitView;
	import com.clarityenglish.tensebuster.view.zone.ZoneView;
	
	import flash.events.MouseEvent;
	
	import mx.controls.SWFLoader;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.TabbedViewNavigator;
	import spark.components.mediaClasses.VolumeBar;
	
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var sectionNavigator:TabbedViewNavigator;
		
		[SkinPart]
		public var backToMenuButton:Button;
		
		[SkinPart]
		public var courseThumbnail:SWFLoader;
		
		[SkinPart]
		public var unitThumbnail:SWFLoader;
		
		private var _selectedNode:XML;
		private var courseID:String;
		private var _courseUID:String;
		private var _courseCaption:String;
		private var _unitUID:String;
		private var _unitCaption:String;
		private var _exerciseCaption:String;
		
		public var backToMenu:Signal = new Signal();
		public var thumbnailScript:String;
		
		public function set selectedNode(value:XML):void {
			_selectedNode = value;
			
			switch (_selectedNode.localName()) {
				case "course":
					courseID = _selectedNode.@id;
					_courseUID = "90."+_selectedNode.@id as String;
					courseCaption = _selectedNode.@caption;
					courseThumbnail.source = getThumbnailForUid(_courseUID);
					currentState = "unit";
					break;
				case "unit":
					_unitUID = _courseUID+"."+courseID;
					unitCaption = _selectedNode.@caption;
					unitThumbnail.source = getThumbnailForUid(_unitUID);
					currentState = "zone";
					break;
				case "exercise":
					exerciseCaption = _selectedNode.@caption;
					currentState = "exercise";
					break;
			}
		}
		
		[Bindable]
		public function get courseCaption():String {
			return _courseCaption;
		}
		
		public function set courseCaption(value:String):void {
			_courseCaption = value;
		}
		
		[Bindable]
		public function get unitCaption():String {
			return _unitCaption;
		}
		
		public function set unitCaption(value:String):void {
			_unitCaption = value;
		}
		
		[Bindable]
		public function get exerciseCaption():String {
			return _exerciseCaption;
		}
		
		public function set exerciseCaption(value:String):void {
			_exerciseCaption = value;
		}
		
		public function TitleView() {
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "unit", "zone", "exercise" ], true);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case sectionNavigator:
					setNavStateMap(sectionNavigator, {
						home: { viewClass: HomeView },
						unit: { viewClass: UnitView, stack: true},
						zone: { viewClass: ZoneView, stack: true },
						exercise: { viewClass: ExerciseView, stack: true }
					});
					break;
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
			}
		}
		
		protected function onBackToMenuButtonClick(event:MouseEvent):void {
			backToMenu.dispatch();
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
		public function getThumbnailForUid(uid:String):String {
			trace("uid: "+uid);
			return thumbnailScript + "?uid=" + uid + "&exIndex=" + 4;
		}
		
	}
}