package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	
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
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			
			// Construct an href for the menu.xml file.  Note that MENU_XHTML loading is *always* done server-side
			var href:Href = new Href(Href.MENU_XHTML, configProxy.getMenuFilename(), configProxy.getContentPath(), true);
			
			// Allow the menu xml filename to be overridden by an optional parameter (this is used in Rotterdam where the app can load different menu.xml files)
			// and also allow an options object (which is passed verbatim to the transforms) to be specified.
			if (note.getBody()) {
				if (note.getBody().filename) href.filename = note.getBody().filename;
				if (note.getBody().options) href.options = note.getBody().options;
			}
			
			log.debug("Loading MENU_XHTML - {0}", href);
			xhtmlProxy.loadXHTML(href);
		}
		
	}
	
}