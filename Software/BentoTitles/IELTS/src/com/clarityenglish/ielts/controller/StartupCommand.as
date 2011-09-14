package com.clarityenglish.ielts.controller {
	import com.clarityenglish.ielts.view.ApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand {

		public override function execute(note:INotification):void {
			facade.registerMediator(new ApplicationMediator(note.getBody()));
		}

	}
}
