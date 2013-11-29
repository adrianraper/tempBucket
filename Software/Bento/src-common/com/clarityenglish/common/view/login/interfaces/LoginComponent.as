package com.clarityenglish.common.view.login.interfaces {
	import com.clarityenglish.common.view.interfaces.CopyReceiver;
	import com.clarityenglish.common.vo.config.BentoError;
	
	import flash.events.IEventDispatcher;
	
	import org.osflash.signals.Signal;
	
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
		// gh#39
		function setProductCode(productCode:String):void;
		function setLicenceType(licenceType:uint):void;
		function setState(state:String):void;
		// gh#41
		function setNoAccount(noAccount:Boolean):void;
		//gh#41
		function getTestDrive():Signal;
		// gh#
		//function setBranding(xml:XML):void;
		function setPlatformTablet(value:Boolean):void;
		function setPlatformipad(value:Boolean):void;
		function setPlatformAndroid(value:Boolean):void;
	}
	
}