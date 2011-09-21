package com.clarityenglish.ielts.controller {
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.ielts.view.ApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand {

		public override function execute(note:INotification):void {
			// Register models
			facade.registerProxy(new ConfigProxy());
			facade.registerProxy(new XHTMLProxy());
			
			// Register mediators
			facade.registerMediator(new ApplicationMediator(note.getBody()));
		}

	}
}
