package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.BuilderStates;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.utilities.statemachine.FSMInjector;
	
	public class BuilderStartupStateMachineCommand extends SimpleCommand {
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Inject the FSM into PureMVC
			// Note that 'changed' means entered, really
			var fsm:XML =				
				<fsm initial={BBStates.STATE_LOAD_COPY}>
					<state name={BBStates.STATE_LOAD_COPY} changed={CommonNotifications.COPY_LOAD}>
						<transition action={CommonNotifications.COPY_LOADED} target={BBStates.STATE_LOAD_ACCOUNT} />
					</state>
					
					<state name={BBStates.STATE_LOAD_ACCOUNT} changed={CommonNotifications.ACCOUNT_LOAD}>
						<transition action={CommonNotifications.ACCOUNT_LOADED} target={BBStates.STATE_LOGIN} />
					</state>
					
					<state name={BBStates.STATE_LOGIN}>
						<transition action={CommonNotifications.LOGGED_IN} target={BuilderStates.STATE_COURSE_SELECTOR} />
					</state>
					
					<state name={BuilderStates.STATE_COURSE_SELECTOR}>
						
					</state>
					
					<state name={BuilderStates.STATE_COURSE_EDITOR}>
						
					</state>
					
					<state name={BBStates.STATE_CREDITS}>
					</state>
				</fsm>;
			
			// #297 - if we are using direct login then we want to add a transition to go the credits on a failed login
			//var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			// TODO. This is actually triggering a LoginEvent if you are doing direct - which is repeated later.
			// #336 Does SCORM have any impact here, or can it be subsumed into directLogin?
			/*if (configProxy.getDirectLogin()) {
				var loginXML:XML = (fsm..state.(@name == BBStates.STATE_LOGIN))[0];
				loginXML.appendChild(<transition action={CommonNotifications.INVALID_LOGIN} target={BBStates.STATE_CREDITS} />);
				loginXML.appendChild(<transition action={CommonNotifications.INVALID_DATA} target={BBStates.STATE_CREDITS} />);
			}*/
			// #322
			/*if (configProxy.getConfig().anyError()) {
				loginXML = (fsm..state.(@name == BBStates.STATE_LOGIN))[0];
				loginXML.appendChild(<transition action={CommonNotifications.CONFIG_ERROR} target={BBStates.STATE_CREDITS} />);
			}*/
			
			// #377 - when disableAutoTimeout is on we want to go back to the login screen instead of the credits screen
			/*if (configProxy.getConfig().disableAutoTimeout) {
				for each (var creditTransition:XML in fsm..transition.(@target == BBStates.STATE_CREDITS)) {
					creditTransition.@target = BBStates.STATE_LOGIN;
				}
			}*/
			
			// Kick off the state machine
			var fsmInjector:FSMInjector = new FSMInjector(fsm);
			fsmInjector.inject();
		}
		
	}
	
}