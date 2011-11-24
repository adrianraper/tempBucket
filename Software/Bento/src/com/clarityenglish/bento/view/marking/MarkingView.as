package com.clarityenglish.bento.view.marking {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.marking.events.MarkingEvent;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	
	[Event(name="tryAgain", type="com.clarityenglish.bento.view.marking.events.MarkingEvent")]
	[Event(name="seeAnswers", type="com.clarityenglish.bento.view.marking.events.MarkingEvent")]
	[Event(name="moveForward", type="com.clarityenglish.bento.view.marking.events.MarkingEvent")]
	public class MarkingView extends BentoView {
		
		[SkinPart]
		public var tryAgainButton:Button;
		
		[SkinPart]
		public var seeAnswersButton:Button;
		
		[SkinPart]
		public var moveForwardButton:Button;
		
		[Bindable]
		public var exerciseMark:ExerciseMark;
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case tryAgainButton:
					tryAgainButton.addEventListener(MouseEvent.CLICK, onTryAgainButton);
					break;
				case seeAnswersButton:
					seeAnswersButton.addEventListener(MouseEvent.CLICK, onSeeAnswersButton);
					break;
				case moveForwardButton:
					moveForwardButton.addEventListener(MouseEvent.CLICK, onMoveForwardButton);
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case tryAgainButton:
					tryAgainButton.removeEventListener(MouseEvent.CLICK, onTryAgainButton);
					break;
				case seeAnswersButton:
					seeAnswersButton.removeEventListener(MouseEvent.CLICK, onTryAgainButton);
					break;
				case moveForwardButton:
					moveForwardButton.removeEventListener(MouseEvent.CLICK, onTryAgainButton);
					break;
			}
		}
		
		protected function onTryAgainButton(event:MouseEvent):void {
			dispatchEvent(new MarkingEvent(MarkingEvent.TRY_AGAIN));
		}
		
		protected function onSeeAnswersButton(event:MouseEvent):void {
			dispatchEvent(new MarkingEvent(MarkingEvent.SEE_ANSWERS));
			
			// Send a close event which will shut the popup (if the view is running in a popup)
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onMoveForwardButton(event:MouseEvent):void {
			dispatchEvent(new MarkingEvent(MarkingEvent.MOVE_FORWARD));
			
			// Send a close event which will shut the popup (if the view is running in a popup)
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
	
}