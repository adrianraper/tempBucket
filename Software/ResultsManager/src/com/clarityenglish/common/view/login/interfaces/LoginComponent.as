package com.clarityenglish.common.view.login.interfaces {
	import com.clarityenglish.common.view.interfaces.CopyReceiver;
	import flash.events.IEventDispatcher;
	
	/**
	 * The login mediator works on LoginView components that implement this interface
	 * 
	 * @author ...
	 */
	public interface LoginComponent extends IEventDispatcher, CopyReceiver {
		function showInvalidLogin():void;
		function clearData():void;
	}
	
}