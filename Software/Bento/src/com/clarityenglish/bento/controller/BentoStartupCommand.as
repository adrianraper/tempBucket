package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.model.ExternalInterfaceProxy;
	import com.clarityenglish.bento.model.SCORMProxy;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.model.ProgressProxy;
	
	import flash.debugger.enterDebugger;
	import flash.utils.setTimeout;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.utilities.statemachine.FSMInjector;
	
	public class BentoStartupCommand extends SimpleCommand {
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// #269
			sendNotification(BBNotifications.ACTIVITY_TIMER_RESET);

			// Register models
			facade.registerProxy(new BentoProxy());
			facade.registerProxy(new ConfigProxy());
			facade.registerProxy(new XHTMLProxy());
			facade.registerProxy(new LoginProxy());
			facade.registerProxy(new ProgressProxy());
			facade.registerProxy(new CopyProxy());
			facade.registerProxy(new ExternalInterfaceProxy());
			// #336
			facade.registerProxy(new SCORMProxy());
			
			// Get copy literals first
			// #322
			// sendNotification(CommonNotifications.COPY_LOAD);
			
			// Start the configuration loading
			sendNotification(CommonNotifications.CONFIG_LOAD);
		}
		
	}
	
}