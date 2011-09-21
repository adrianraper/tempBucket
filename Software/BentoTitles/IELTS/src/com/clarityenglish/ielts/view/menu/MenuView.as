package com.clarityenglish.ielts.view.menu {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.module.ModuleView;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	
	[SkinState("module")]
	[SkinState("progress")]
	public class MenuView extends BentoView {
		
		[SkinPart]
		public var course1Button:Button;
		
		[SkinPart]
		public var course2Button:Button;
		
		[SkinPart]
		public var course3Button:Button;
		
		[SkinPart]
		public var course4Button:Button;
		
		[SkinPart]
		public var moduleView:ModuleView;
		
		[SkinPart]
		public var progressView:ProgressView;
		
		public var courseSelected:Signal = new Signal(String);
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_xhtml) {
				// Set the course selection button labels from the XHTML
				var courses:Array = _xhtml.select("course");
				for (var n:uint = 0; n < courses.length; n++) {
					var courseButton:Button = this["course" + (n + 1) + "Button"];
					courseButton.label = courses[n].@caption;
					courseButton.visible = true;
				}
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case course1Button:
				case course2Button:
				case course3Button:
				case course4Button:
					// TODO: This should maybe send something other than the label (i.e. the course xml?? but can deal with that later)
					instance.addEventListener(MouseEvent.CLICK, onCourseSelected);
					break;
			}
		}
		
		protected override function getCurrentSkinState():String {
			return "module";
		}
		
		protected function onCourseSelected(e:Event):void {
			var caption:String = e.target.label;
			moduleView.course = _xhtml.selectOne("course[caption='" + caption + "']");
		}
		
	}
	
}