package com.clarityenglish.ieltstester.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.ieltstester.view.IELTSTesterApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	
	public class StartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			facade.registerMediator(new IELTSTesterApplicationMediator(note.getBody()));
		}

	}
}