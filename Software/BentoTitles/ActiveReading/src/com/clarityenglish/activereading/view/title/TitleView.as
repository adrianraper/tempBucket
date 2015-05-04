package com.clarityenglish.activereading.view.title {
	import com.clarityenglish.activereading.view.exercise.ExerciseView;
	import com.clarityenglish.activereading.view.home.HomeView;
	import com.clarityenglish.activereading.view.progress.ProgressView;
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.controls.SWFLoader;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.ButtonBarButton;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TabbedViewNavigator;
	import spark.components.ViewNavigator;
	import spark.components.mediaClasses.VolumeBar;
	import spark.events.IndexChangeEvent;
	import spark.transitions.ViewTransitionBase;
	
	[SkinState("home")]
	[SkinState("progress")]
	[SkinState("exercise")]
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var sectionNavigator:TabbedViewNavigator;
		
		[SkinPart]
		public var homeViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var progressViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var backToMenuButton:Button;
		
		[SkinPart]
		public var courseThumbnail:SWFLoader;
		
		[SkinPart]
		public var coursePath:HGroup;
		
		[SkinPart]
		public var unitPath:HGroup;
		
		[SkinPart]
		public var exercisePath:HGroup;
		
		[SkinPart]
		public var logoutButton:Button;
		
		[SkinPart]
		public var helpButton:Button;
		
		[SkinPart]
		public var topLeftDemoLabel:Label;
		
		[SkinPart]
		public var topRightDemoLabel:Label;
		
		[Bindable]
		public static var courseCode:String;
		
		private var _selectedNode:XML;
		private var _isDirectStartCourse:Boolean;
		private var _directCourse:XML;
		private var _isDirectStartUnit:Boolean;
		private var _directUnit:XML;
		private var _isDirectStartEx:Boolean;
		private var _directExercise:XML;
		private var _isDirectLogout:Boolean;

		public var backToMenu:Signal = new Signal();
		public var logout:Signal = new Signal();	
		
		public function set selectedNode(value:XML):void {
			_selectedNode = value;
			
			switch (_selectedNode.localName()) {
				case "menu":
				case "course":
				case "unit":
					currentState = "home";	
					break;
				case "exercise":
					currentState = "exercise";
					break;
			}
		}
		
		public function set isDirectStartCourse(value:Boolean):void {
			_isDirectStartCourse = value;
		}
		
		public function set directCourse(value:XML):void {
			_directCourse = value;
		}
		// gh#853
		public function get directCourse():XML {
			return _directCourse;
		}
		
		public function set isDirectStartUnit(value:Boolean):void {
			_isDirectStartUnit = value;
		}
		
		public function set directUnit(value:XML):void {
			_directUnit = value;
		}
		public function get directUnit():XML {
			return _directUnit;
		}
		
		public function set isDirectStartExercise(value:Boolean):void {
			_isDirectStartEx = value;
		}
		
		public function set directExercise(value:XML):void {
			_directExercise = value;
		}
		public function get directExercise():XML {
			return _directExercise;
		}
		
		public function set isDirectLogout(value:Boolean):void {
			_isDirectLogout = value;
		}
		
		[Bindable]
		public function get isDirectLogout():Boolean {
			return _isDirectLogout;
		}

		public function get isDemo():Boolean {
			return productVersion == BentoApplication.DEMO;
		}
		
		public function TitleView() {
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "exercise", "progress" ], true);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case sectionNavigator:
					setNavStateMap(sectionNavigator, {
						home: { viewClass: HomeView },
						exercise: { viewClass: ExerciseView, stack: true },
						progress: { viewClass: ProgressView }
					});
					break;
				case backToMenuButton:
					backToMenuButton.label = copyProvider.getCopyForId("backToMenuButton");
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
				case logoutButton:
					instance.addEventListener(MouseEvent.CLICK, onLogoutClick);
					break;
				case helpButton:
					instance.label = copyProvider.getCopyForId("help");
					instance.addEventListener(MouseEvent.CLICK,onHelpClick);
					break;
				case topLeftDemoLabel:
					topLeftDemoLabel.text = copyProvider.getCopyForId("topLeftDemoLabel");
					break;
				case topRightDemoLabel:
					topRightDemoLabel.text = copyProvider.getCopyForId("topRightDemoLabel");
					break;
			}
			
		}

		protected function onBackToMenuButtonClick(event:MouseEvent):void {
			_isDirectLogout? logout.dispatch() : backToMenu.dispatch();
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
		// gh#217
		protected function onLogoutClick(event:Event):void {
			logout.dispatch();
		}
		
		protected function onHelpClick(event:MouseEvent):void {
			var url:String = copyProvider.getCopyForId("helpURL");
			var urlRequest:URLRequest = new URLRequest(url);
			navigateToURL(urlRequest, "_blank");
		}
		
	}
}