package com.clarityenglish.ielts.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.ielts.view.IELTSApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class StartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			facade.registerMediator(new IELTSApplicationMediator(note.getBody()));
		}

	}
}
