package com.clarityenglish.bento.view.information {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.information.events.InformationEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	
	import org.puremvc.as3.interfaces.INotification;
	
	import spark.components.Button;
	import spark.components.Label;
	
	[Event(name="ok", type="com.clarityenglish.bento.view.information.events.InformationEvent")]
	public class InformationView extends BentoView {
		
		[SkinPart]
		public var okButton:Button;
		
		[SkinPart]
		public var message:Label;
		
		public var type:String;
		
		public var body:Object;

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case okButton:
					instance.addEventListener(MouseEvent.CLICK, onOKButton);
					instance.label = copyProvider.getCopyForId("okButton");
					break;
				case message:
					switch (type) {
						case "xxx":
							instance.text = copyProvider.getCopyForId("xxx");
							break;
						case "status":
						default:
							if (body.text && body.text is String)
								instance.text = body.text;
					}
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case okButton:
					instance.removeEventListener(MouseEvent.CLICK, onOKButton);
					break;
			}
		}
		
		protected function onOKButton(event:MouseEvent):void {
			dispatchEvent(new InformationEvent(InformationEvent.OK));
			
			// Send a close event which will shut the popup (if the view is running in a popup)
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
	
}