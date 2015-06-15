/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
import com.clarityenglish.common.model.MemoryProxy;
import com.clarityenglish.common.model.ProgressProxy;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.dms.vo.account.Account;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class SessionStartCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			// #339 Now this comes from FSM so needs to get its own data
			//var data:Object = note.getBody();
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			progressProxy.startSession(loginProxy.user, configProxy.getAccount());

			// Get the memory here
			var memoryProxy:MemoryProxy = facade.retrieveProxy(MemoryProxy.NAME) as MemoryProxy;
			memoryProxy.getMemory("openUnit");
		}
		
	}
}