package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.controller.MenuXHTMLLoadCommand;
	import com.clarityenglish.bento.vo.content.transform.PublicationDatesTransform;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.builder.view.BuilderApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;

	public class BuilderStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Set the transforms that Rotterdam player uses on its menu.xml files
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			MenuXHTMLLoadCommand.transforms = [ new PublicationDatesTransform() ];
			
			facade.registerMediator(new BuilderApplicationMediator(note.getBody()));
		}

	}
}
