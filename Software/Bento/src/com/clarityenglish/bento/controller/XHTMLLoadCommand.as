package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.vo.Href;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class XHTMLLoadCommand extends SimpleCommand {
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			xhtmlProxy.loadXHTML(note.getBody() as Href);
		}
		
	}
	
}