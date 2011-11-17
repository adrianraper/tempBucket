package com.clarityenglish.ielts.view.exercise {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	
	public class ExerciseView extends BentoView {
		
		[SkinPart]
		public var forwardButton:Button;
		
		[SkinPart]
		public var backButton:Button;
		
		[SkinPart]
		public var markingButton:Button;
		
		[SkinPart]
		public var feedbackButton:Button;
		
		[SkinPart(required="true")]
		public var dynamicView:DynamicView;
		
		[Bindable]
		public var exerciseTitle:String;
		
		[Bindable]
		public var backgroundColorTop:Number;
		
		[Bindable]
		public var backgroundColorBottom:Number;
		
		public var showMarking:Signal = new Signal();
		public var nextExercise:Signal = new Signal();
		public var previousExercise:Signal = new Signal();
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			dynamicView.href = href;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case markingButton:
					markingButton.addEventListener(MouseEvent.CLICK, function():void { showMarking.dispatch(); } );
					break;
				case forwardButton:
					forwardButton.addEventListener(MouseEvent.CLICK, function():void { nextExercise.dispatch(); } );
					break;
				case backButton:
					backButton.addEventListener(MouseEvent.CLICK, function():void { previousExercise.dispatch(); } );
					break;
			}
		}
		
	}
	
}