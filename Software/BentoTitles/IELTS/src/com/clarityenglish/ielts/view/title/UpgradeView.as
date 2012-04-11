package com.clarityenglish.ielts.view.title {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class UpgradeView extends SkinnableComponent {
		
		[SkinPart]
		public var teacherButton:Button;
		
		[SkinPart]
		public var candidateButton:Button;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			/**
			 * #299
			 * 
			 * This view is so simple that the functionality is here, rather than creating mediators and commands
			 */
			switch (instance) {
				case teacherButton:
					teacherButton.addEventListener(MouseEvent.CLICK, onTeacherButtonClick);
					break;
				case candidateButton:
					candidateButton.addEventListener(MouseEvent.CLICK, onCandidateButtonClick);
					break;
			}
		}
		
		protected function onTeacherButtonClick(event:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.clarityenglish.com/loudandclear/index.php"), "_blank");
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onCandidateButtonClick(event:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.ieltspractice.com"), "_blank");
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
	
}