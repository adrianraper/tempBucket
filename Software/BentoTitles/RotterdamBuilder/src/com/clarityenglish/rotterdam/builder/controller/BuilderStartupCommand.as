package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.transform.PublicationDatesTransform;
	import com.clarityenglish.rotterdam.builder.view.BuilderApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;

	public class BuilderStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Set the transforms that Rotterdam builder uses on its menu.xml files
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;		
			xhtmlProxy.registerTransforms([ new PublicationDatesTransform() ], [ Href.MENU_XHTML ]);
			
			facade.registerMediator(new BuilderApplicationMediator(note.getBody()));
		}

	}
}
