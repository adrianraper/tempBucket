package com.clarityenglish.rotterdam.view.settings {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.DateChooser;
	
	import spark.components.Button;
	
	public class SettingsView extends BentoView {
		
		[SkinPart(required="true")]
		public var backButton:Button;
		
		[SkinPart]
		public var startDateChooser:DateChooser;
		
		private var _currentCourse:XHTML;
		
		public function set currentCourse(value:XHTML):void {
			_currentCourse = value;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_currentCourse) {
				startDateChooser.selectedDate = _currentCourse.hasOwnProperty("@startDate") ? new Date(_currentCourse.@startDate) : new Date();
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
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
		
		protected function onBack(event:MouseEvent):void {
			navigator.popView();
		}
		
	}
}