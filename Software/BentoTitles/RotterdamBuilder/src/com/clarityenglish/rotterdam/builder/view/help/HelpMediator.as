package com.clarityenglish.rotterdam.builder.view.help
{
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class HelpMediator extends BentoMediator implements IMediator
	{
		public function HelpMediator(mediatorName:String, viewComponent:BentoView)
		{
			super(mediatorName, viewComponent);
		}
		
		private function get view():HelpView {
			return viewComponent as HelpView;
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				
			}
		}
	}
}