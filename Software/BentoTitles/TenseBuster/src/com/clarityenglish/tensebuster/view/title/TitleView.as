package com.clarityenglish.tensebuster.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.tensebuster.view.home.HomeView;
	import com.clarityenglish.tensebuster.view.progress.ProgressView;
	import com.clarityenglish.tensebuster.view.unit.UnitView;
	import com.clarityenglish.tensebuster.view.zone.ZoneView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.SWFLoader;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.ButtonBarButton;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TabbedViewNavigator;
	import spark.components.mediaClasses.VolumeBar;
	import spark.events.IndexChangeEvent;
	
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var sectionNavigator:TabbedViewNavigator;
		
		[SkinPart]
		public var backToMenuButton:Button;
		
		[SkinPart]
		public var courseThumbnail:SWFLoader;
		
		[SkinPart]
		public var unitThumbnail:SWFLoader;
		
		[SkinPart]
		public var coursePath:HGroup;
		
		[SkinPart]
		public var unitPath:HGroup;
		
		[SkinPart]
		public var exercisePath:HGroup;
		
		[SkinPart]
		public var logoutButton:Button;
		
		private var _selectedNode:XML;
		private var courseID:String;
		private var _courseUID:String;
		private var _courseCaption:String;
		private var _unitUID:String;
		private var _unitCaption:String;
		private var _exerciseCaption:String;
		[Bindable]
		public static var courseCode:String;
		
		public var backToMenu:Signal = new Signal();
		public var logout:Signal = new Signal();
		
		public var thumbnailScript:String;
		
		public function set selectedNode(value:XML):void {
			_selectedNode = value;

			switch (_selectedNode.localName()) {
				case "menu":
					currentState = "home";
					break;
				case "course":
					courseID = _selectedNode.@id;
					_courseUID = "9."+_selectedNode.@id as String;
					courseCaption = _selectedNode.@caption;
					courseThumbnail.source = getThumbnailForUid(_courseUID);
					courseCode = courseCaption.charAt(0);
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
			StateUtil.addStates(this, [ "home", "unit", "zone", "exercise", "progress", "profile" ], true);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();

		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			/*if (currentState == "unit") {
				callLater(function():void {
					coursePath.visible = true;
					unitPath.visible = false;
					exercisePath.visible = false;
				});
			} else if (currentState == "zone") {
				callLater(function():void {
					coursePath.visible = true;
					unitPath.visible = true;
					exercisePath.visible = false;
				});
			} else if (currentState == "exercise") {
				callLater(function():void {
					coursePath.visible = true;
					unitPath.visible = true;
					exercisePath.visible = true;
				});
			}*/
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case sectionNavigator:
					setNavStateMap(sectionNavigator, {
						home: { viewClass: HomeView },
						unit: { viewClass: UnitView, stack: true },
						zone: { viewClass: ZoneView, stack: true },
						exercise: { viewClass: ExerciseView, stack: true },
						progress: { viewClass: ProgressView }
					});
					break;
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
				case logoutButton:
					logoutButton.label = copyProvider.getCopyForId("logoutButton");
					logoutButton.addEventListener(MouseEvent.CLICK, onLogoutClick);
					break;
			}
		}
		
		protected function onBackToMenuButtonClick(event:MouseEvent):void {
			backToMenu.dispatch();
		}
		
		protected override function getCurrentSkinState():String {
			/*if (currentState == "home") {
				if (coursePath)
					coursePath.visible = false;
				if (unitPath)
					unitPath.visible = false;
				if (exercisePath)
					exercisePath.visible = false;
			}*/ 
			// disable Menu button bar button when current page is unit or zone page.
			if (currentState == "unit" || currentState == "zone") {
				ButtonBarButton(sectionNavigator.tabBar.dataGroup.getElementAt(0)).enabled = false;
			} else if (currentState == "progress" || currentState == "help") {
				ButtonBarButton(sectionNavigator.tabBar.dataGroup.getElementAt(0)).enabled = true;
			}
			return currentState;
		}
		
		public function getThumbnailForUid(uid:String):String {
			return thumbnailScript + "?uid=" + uid + "&exIndex=" + 4;
		}
		
		// gh#217
		protected function onLogoutClick(event:Event):void {
			logout.dispatch();
		}
		
	}
}