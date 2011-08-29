package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.ApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			// Register the main mediator
			facade.registerMediator(new ApplicationMediator(note.getBody() as BentoApplication));
		}
		
	}
}