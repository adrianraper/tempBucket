package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.XHTMLProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class MenuXHTMLReloadCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			
			log.debug("Reloading MENU_XHTML");
			
			if (!bentoProxy.menuXHTML) {
				log.error("reloadXHTML was called when no menu xhtml was loaded");
				return;
			}
			
			xhtmlProxy.reloadXHTML(bentoProxy.menuXHTML.href);
		}
		
	}
	
}