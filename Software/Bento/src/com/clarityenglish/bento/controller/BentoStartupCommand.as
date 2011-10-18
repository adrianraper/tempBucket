package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class BentoStartupCommand extends SimpleCommand {
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Register models
			facade.registerProxy(new ConfigProxy());
			facade.registerProxy(new XHTMLProxy());
			facade.registerProxy(new ExerciseProxy());
			facade.registerProxy(new LoginProxy());

		}
		
	}
	
}