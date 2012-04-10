package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.model.ExternalInterfaceProxy;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
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
			
			// Register models
			facade.registerProxy(new BentoProxy());
			facade.registerProxy(new ConfigProxy());
			facade.registerProxy(new XHTMLProxy());
			facade.registerProxy(new LoginProxy());
			facade.registerProxy(new ProgressProxy());
			facade.registerProxy(new ExternalInterfaceProxy());
			
			// Inject the FSM into PureMVC
			// Note that 'changed' means entered, really
			var fsm:XML =
				<fsm initial={BBStates.STATE_LOAD_CONFIG}>
					
					<state name={BBStates.STATE_LOAD_CONFIG} changed={CommonNotifications.CONFIG_LOAD}>
						<transition action={CommonNotifications.CONFIG_LOADED} target={BBStates.STATE_LOGIN} />
					</state>
					
					<state name={BBStates.STATE_LOGIN}>
						<transition action={CommonNotifications.LOGGED_IN} target={BBStates.STATE_LOAD_MENU} />
					</state>
					
					<state name={BBStates.STATE_LOAD_MENU} changed={BBNotifications.MENU_XHTML_LOAD}>
						<transition action={BBNotifications.MENU_XHTML_LOADED} target={BBStates.STATE_TITLE} />
					</state>
					
					<state name={BBStates.STATE_TITLE}>
						<transition action={CommonNotifications.LOGGED_OUT} target={BBStates.STATE_CREDITS} />
					</state>
					
					<state name={BBStates.STATE_CREDITS}>
					</state>
					
				</fsm>;
			
			var fsmInjector:FSMInjector = new FSMInjector(fsm);
			fsmInjector.inject();
			
			// #269
			sendNotification(BBNotifications.ACTIVITY_TIMER_RESET);
		}
		
	}
	
}