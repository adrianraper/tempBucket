package com.clarityenglish.rotterdam.view.settings {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.controls.DateChooser;
	
	import spark.components.Button;
	import spark.components.TabBar;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
	public class SettingsView extends BentoView {
		
		[SkinPart(required="true")]
		public var tabBar:TabBar;
		
		[SkinPart]
		public var aboutCourseNameTextInput:TextInput;
		
		[SkinPart]
		public var aboutAuthorTextInput:TextInput;
		
		[SkinPart]
		public var aboutEmailTextInput:TextInput;
		
		[SkinPart]
		public var aboutContactNumberTextInput:TextInput;
		
		[SkinPart(required="true")]
		public var backButton:Button;
		
		[SkinPart]
		public var startDateChooser:DateChooser;
		
		private var _currentCourse:XHTML;
		
		private function get course():XML {	
			return _currentCourse.selectOne("script#model[type='application/xml'] course");
		}
		
		public function set currentCourse(value:XHTML):void {
			_currentCourse = value;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_currentCourse) {
				if (startDateChooser) startDateChooser.selectedDate = _currentCourse.hasOwnProperty("@startDate") ? new Date(_currentCourse.@startDate) : new Date();
				
				if (aboutCourseNameTextInput) aboutCourseNameTextInput.text = course.@caption;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case tabBar:
					tabBar.dataProvider = new ArrayList([
						{ label: "About", data: "about" },
						{ label: "Calendar", data: "calendar" },
						{ label: "Email", data: "email" }
					]);
					
					tabBar.requireSelection = true;
					tabBar.addEventListener(IndexChangeEvent.CHANGE, onTabBarChange);
					
					// Start on the first tab
					callLater(function():void {
						tabBar.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
					});
					break;
				case backButton:
					backButton.addEventListener(MouseEvent.CLICK, onBack);
					break;
				case startDateChooser:
					startDateChooser.addEventListener(Event.CHANGE, function(e:Event):void {
						_currentCourse.@startDate = startDateChooser.selectedDate.time;
					});
					break;
			}
		}
		
		protected function onTabBarChange(event:IndexChangeEvent):void {
			invalidateSkinState();
		}
		
		protected function onBack(event:MouseEvent):void {
			navigator.popView();
		}
		
		protected override function getCurrentSkinState():String {
			if (tabBar && tabBar.selectedItem)
				return tabBar.selectedItem.data;
			
			return super.getCurrentSkinState();
		}
		
	}
}