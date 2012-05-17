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
	
	public class BentoStartupStateMachineCommand extends SimpleCommand {
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Inject the FSM into PureMVC
			// Note that 'changed' means entered, really
			var fsm:XML =				
				<fsm initial={BBStates.STATE_LOGIN}>
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
			
			// #297 - if we are using direct login then we want to add a transition to go the credits on a failed login
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			// TODO. This is actually triggering a LoginEvent if you are doing direct - which is repeated later.
			// #336 Does SCORM have any impact here, or can it be subsumed into directLogin?
			if (configProxy.getDirectLogin()) {
				var loginXML:XML = (fsm..state.(@name == BBStates.STATE_LOGIN))[0];
				loginXML.appendChild(<transition action={CommonNotifications.INVALID_LOGIN} target={BBStates.STATE_CREDITS} />);
				loginXML.appendChild(<transition action={CommonNotifications.INVALID_DATA} target={BBStates.STATE_CREDITS} />);
			}
			// #322
			if (configProxy.getConfig().anyError()) {
				loginXML = (fsm..state.(@name == BBStates.STATE_LOGIN))[0];
				loginXML.appendChild(<transition action={CommonNotifications.CONFIG_ERROR} target={BBStates.STATE_CREDITS} />);
			}
			
			var fsmInjector:FSMInjector = new FSMInjector(fsm);
			fsmInjector.inject();
			
			// Kick off loading of the copy. Mediators that use copy from the xml file should set it when COPY_LOADED is received.
			// Bug, this is not early enough as accountSettings is all done before we get here.
			// Try putting it in BentoStartupCommand instead
			// sendNotification(CommonNotifications.COPY_LOAD);
		}
		
	}
	
}