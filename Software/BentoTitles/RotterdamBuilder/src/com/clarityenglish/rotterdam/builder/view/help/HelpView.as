package com.clarityenglish.rotterdam.builder.view.help
{
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import spark.components.Button;
	import spark.components.Label;
	
	public class HelpView extends BentoView
	{
		[SkinPart]
		public var helpButton:Button;
		
		[SkinPart]
		public var helpLabel1:Label;
		
		[SkinPart]
		public var helpLabel2:Label;
		
		private var helpURL:String;
		
		override protected function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			helpURL = copyProvider.getCopyForId("helpURL");
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case helpButton:
					helpButton.label = copyProvider.getCopyForId("helpButton");
					helpButton.addEventListener(MouseEvent.CLICK, onHelpClick);
					break;
				case helpLabel1:
					helpLabel1.text = copyProvider.getCopyForId("helpLabel1");
					break;
				case helpLabel2:
					helpLabel2.text = copyProvider.getCopyForId("helpLabel2");
					break;
			}
				
		}
		
		protected function onHelpClick(event:MouseEvent):void {
			var urlRequest:URLRequest = new URLRequest(helpURL);
			navigateToURL(urlRequest, "_blank");
		}
	}
}