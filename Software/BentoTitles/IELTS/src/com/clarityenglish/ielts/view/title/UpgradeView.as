package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.common.model.ConfigProxy;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class UpgradeView extends SkinnableComponent {

		/**
		 * DEPRECATED July 2012
		 */
		
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
			var feats:String = "scrollbars=0,left=0,top=0,width=700,height=550"
			ExternalInterface.call("window.open", "http://www.clarityenglish.com/enquiry.php?price=Road_to_IELTS_2", "_blank" , feats);  
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
	
		protected function onCandidateButtonClick(event:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.ieltspractice.com"), "_blank");
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
	
}