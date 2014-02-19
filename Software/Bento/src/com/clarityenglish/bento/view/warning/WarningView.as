package com.clarityenglish.bento.view.warning {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.warning.events.WarningEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	
	import org.puremvc.as3.interfaces.INotification;
	
	import spark.components.Button;
	import spark.components.Label;
	
	[Event(name="no", type="com.clarityenglish.bento.view.warning.events.WarningEvent")]
	[Event(name="yes", type="com.clarityenglish.bento.view.warning.events.WarningEvent")]
	public class WarningView extends BentoView {
		
		[SkinPart]
		public var noButton:Button;
		
		[SkinPart]
		public var yesButton:Button;
		
		[SkinPart]
		public var warningMessage:Label;
		
		public var type:String;
		
		public var body:Object;

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case noButton:
					instance.addEventListener(MouseEvent.CLICK, onNoButton);
					instance.label = copyProvider.getCopyForId("noButton");
					break;
				case yesButton:
					instance.addEventListener(MouseEvent.CLICK, onYesButton);
					instance.label = copyProvider.getCopyForId("yesButton");
					break;
				case warningMessage:
					switch (type) {
						case "lose_answers":
							instance.text = copyProvider.getCopyForId("loseAnswerWarning1") + copyProvider.getCopyForId("loseAnswerWarning2");
							break;
						case "feedback_not_seen":
							instance.text = copyProvider.getCopyForId("feedbackWarning");
							break;
						case "changes_not_saved":
							if (body && body.message) {
								instance.text = body.message; // gh#90 (allow a custom message for changes_not_saved)
							} else {
								instance.text = copyProvider.getCopyForId("loseChangesWarning");
							}
							break;
						case "recording_not_saved":
							instance.text = copyProvider.getCopyForId("loseRecordingWarning");
							break;
					}
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case noButton:
					instance.removeEventListener(MouseEvent.CLICK, onNoButton);
					break;
				case yesButton:
					instance.removeEventListener(MouseEvent.CLICK, onYesButton);
					break;
			}
		}
		
		protected function onNoButton(event:MouseEvent):void {
			dispatchEvent(new WarningEvent(WarningEvent.NO));
			
			// Send a close event which will shut the popup (if the view is running in a popup)
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onYesButton(event:MouseEvent):void {
			dispatchEvent(new WarningEvent(WarningEvent.YES));
			
			// Send a close event which will shut the popup (if the view is running in a popup)
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
	
}