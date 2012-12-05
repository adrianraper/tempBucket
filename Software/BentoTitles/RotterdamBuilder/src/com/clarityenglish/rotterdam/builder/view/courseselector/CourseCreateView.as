package com.clarityenglish.rotterdam.builder.view.courseselector {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.courseselector.events.CourseCreateEvent;
	
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.TextInput;
	
	public class CourseCreateView extends BentoView {
		
		[SkinPart]
		public var captionTextInput:TextInput;
		
		[SkinPart]
		public var createButton:Button;
		
		[SkinPart]
		public var cancelButton:Button;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case createButton:
					createButton.addEventListener(MouseEvent.CLICK, onCreate);
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancel);
					break;
			}
		}
		
		protected function onCreate(event:MouseEvent):void {
			dispatchEvent(new CourseCreateEvent(CourseCreateEvent.COURSE_CREATE, captionTextInput.text, true));
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onCancel(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
}