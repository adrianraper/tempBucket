package com.clarityenglish.tensebuster.view.title {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.tensebuster.view.help.HelpView;
	import com.clarityenglish.tensebuster.view.home.HomeView;
	import com.clarityenglish.tensebuster.view.progress.ProgressView;
	import com.clarityenglish.tensebuster.view.title.ui.SizedButton;
	import com.clarityenglish.tensebuster.view.title.ui.SizedTabbedViewNavigator;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
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
		public var sizedSectionNavigator:SizedTabbedViewNavigator;
		
		[SkinPart]
		public var homeViewNavigator:ViewNavigator;
		
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
		public var sizedLogoutButton:SizedButton;
		
		[SkinPart]
		public var helpButton:Button;
		
		[SkinPart]
		public var sizedHelpButton:SizedButton;
		
		[SkinPart]
		public var topLeftDemoLabel:Label;
		
		[SkinPart]
		public var topRightDemoLabel:Label;

		[SkinPart]
		public var progressViewNavigator:ViewNavigator;
		
		[Bindable]
		public static var courseCode:String;
		
		private var _selectedNode:XML;
		private var courseID:String;
		private var _courseUID:String;
		private var _courseCaption:String;
		private var _unitUID:String;
		private var _unitCaption:String;
		private var _exerciseCaption:String;
		private var courseCaptionChange:Boolean;
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
					currentState = "home";
					break;
				case "course":
					courseID = _selectedNode.@id;
					_courseUID = "9."+_selectedNode.@id as String;
					courseCaption = _selectedNode.@caption;
					courseCode = courseCaption.charAt(0);
					currentState = "home";
					break;
				case "unit":
					_unitUID = _courseUID+"."+courseID;
					unitCaption = _selectedNode.@caption;
					currentState = "home";
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
			courseCaptionChange = true;
			invalidateProperties();
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
			StateUtil.addStates(this, [ "home", "unit", "zone", "exercise", "progress", "profile", "help" ], true);
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			if (_isDirectStartCourse) {
				courseCaption = _directCourse.@caption;
			}
			
			if (_isDirectStartUnit) {
				unitCaption = _directUnit.@caption;
				courseCaption = _directUnit.parent().@caption;
				_isDirectStartUnit = false;
			}
			
			if (_isDirectStartEx) {
				// gh#604 Unrelated, but tidy up syntax
				var thisUnit:XML = _directExercise.parent();
				var thisCourse:XML = thisUnit.parent();
				unitCaption = thisUnit.@caption;
				courseCaption = thisCourse.@caption;
			}
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
				case sizedSectionNavigator:
					setNavStateMap(sizedSectionNavigator, {
						home: { viewClass: HomeView },
						exercise: { viewClass: ExerciseView, stack: true },
						progress: { viewClass: ProgressView }
					});
					break;
				case homeViewNavigator:
					// remove the right transition when back to the home screen
					homeViewNavigator.defaultPopTransition = new ViewTransitionBase();
					break;
				case backToMenuButton:
					backToMenuButton.label = copyProvider.getCopyForId("backToMenuButton");
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
				case logoutButton:
				case sizedLogoutButton:
					instance.label = copyProvider.getCopyForId("logoutButton");
					instance.addEventListener(MouseEvent.CLICK, onLogoutClick);
					break;
				case helpButton:
				case sizedHelpButton:
					instance.label = copyProvider.getCopyForId("help");
					instance.addEventListener(MouseEvent.CLICK,onHelpClick);
					break;
				case topLeftDemoLabel:
					topLeftDemoLabel.text = copyProvider.getCopyForId("topLeftDemoLabel");
					break;
				case topRightDemoLabel:
					topRightDemoLabel.text = copyProvider.getCopyForId("topRightDemoLabel");
					break;
				// gh#1090 To hide progress tab for pure AA login
				case progressViewNavigator:
					instance.enabled = !config.noLogin;
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