package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.model.ProgressProxy;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.resultsmanager.vo.manageable.User;
	import com.clarityenglish.dms.vo.account.Licence;

import mx.core.FlexGlobals;

import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.primitives.Line;
	
	/**
	 * This command clears cached files from within Bento; its used to reset the state to perform a second startup after the network connection has been lost
	 */
	public class BentoResetCommand extends SimpleCommand {
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			progressProxy.reset();
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			bentoProxy.reset();
			
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			xhtmlProxy.reset();
			
			// gh#13
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			configProxy.reset();
		}
	}
}