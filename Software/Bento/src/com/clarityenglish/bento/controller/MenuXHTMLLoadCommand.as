package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.model.ProgressProxy;
	import com.clarityenglish.common.vo.progress.Progress;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class MenuXHTMLLoadCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			var href:Href = new Href(Href.MENU_XHTML, configProxy.getMenuFilename(), configProxy.getContentPath());
			
			// Allow the menu xml filename to be overridden by an optional parameter (this is used in Rotterdam where the app can load different menu.xml files)
			if (note.getBody() && note.getBody().filename) {
				href.filename = note.getBody().filename;
			}
			
			// Allow the selection of normal or progress versions of the XML (also for Rotterdam where we can be in editing mode and don't want any progress)
			if (note.getBody() && note.getBody().noProgress) {
				log.debug("Loading non-progress version of {0}", href);
				var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
				xhtmlProxy.loadXHTML(href);
			} else {
				log.debug("Loading progress version of {0}", href);
				progressProxy.getProgressData(loginProxy.user, configProxy.getAccount(), href, Progress.PROGRESS_MY_DETAILS);
			}
		}
		
	}
	
}