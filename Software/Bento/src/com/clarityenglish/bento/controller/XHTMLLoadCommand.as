package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ProgressProxy;
	import com.clarityenglish.common.vo.progress.Progress;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class XHTMLLoadCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			
			var href:Href = note.getBody() as Href;
			
			if (!href) {
				sendNotification(BBNotifications.XHTML_LOADED, { xhtml: null, href: href } ); // #192
			} else if (href.type == Href.MENU_XHTML) {
				// This can go one of two ways; if the menu xhtml is loaded into ProgressProxy (as for IELTS) then get it from that, otherwise it must be in
				// XHTMLProxy (as for Rotterdam).  We assume it must be in one of the two as MENU_XHTML is loaded directly through MENU_XHTML_LOAD.  If it turns out 
				// not to be in either for some reason then throw an error.  Note that progressProxy has constant loadedResource keys and XHTMLProxy has Href
				// loadedResource keys; its all something of a mess, but this does seem to work for the moment.
				if (progressProxy.hasLoadedResource(Progress.PROGRESS_MY_DETAILS)) {
					trace("you are here");
					progressProxy.loadXHTML(href);
				} else if (xhtmlProxy.hasLoadedResource(href)) {
					xhtmlProxy.loadXHTML(href);
				} else {
					throw new Error("menu.xml was not found in either ProgressProxy or XHTMLProxy");
				}
			} else {
				// All normal XHTML files go through XHTMLProxy
				xhtmlProxy.loadXHTML(href);
			}
		}
		
	}
	
}