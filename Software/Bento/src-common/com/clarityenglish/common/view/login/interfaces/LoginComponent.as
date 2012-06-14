package com.clarityenglish.common.view.login.interfaces {
	import com.clarityenglish.common.view.interfaces.CopyReceiver;
	import com.clarityenglish.common.vo.config.BentoError;
	
	import flash.events.IEventDispatcher;
	
	/**
	 * The login mediator works on LoginView components that implement this interface
	 * 
	 * @author ...
	 */
	public interface LoginComponent extends IEventDispatcher, CopyReceiver {
		function showInvalidLogin(error:BentoError):void;
		function setLicencee(name:String):void;
		function setLoginOption(loginOption:Number):void;
		function setSelfRegister(selfRegister:Number):void;
		function setVerified(verified:Number):void;
		function clearData():void;
		function setProductVersion(productVersion:String):void;
		function getProductVersion():String;
		function setProductCode(productCode:uint):void;
		function setState(state:String):void;
	}
	
}