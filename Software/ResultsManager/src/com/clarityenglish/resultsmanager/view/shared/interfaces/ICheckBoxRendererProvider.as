package com.clarityenglish.resultsmanager.view.shared.interfaces {
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public interface ICheckBoxRendererProvider {
		
		function isCheckBoxEnabled(data:Object):Boolean;
		function isCheckBoxSelected(data:Object):Boolean;
		function onCheckBoxClick(data:Object, selected:Boolean):void;
		//gh#29
		function isEnableContentEdit():Boolean;
		
	}
	
}