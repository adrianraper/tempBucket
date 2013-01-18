package com.clarityenglish.ielts.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.ielts.view.IELTSApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;

	public class IELTSStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			
			// Set the default function for currentCouseClass to retrieve the class of the first course
			dataProxy.setDefaultFunction("currentCourseClass", function(facade:Facade):Object {
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				return (bentoProxy.menuXHTML) ? bentoProxy.menuXHTML..course[0].@["class"].toString() : null;
			});
			
			facade.registerMediator(new IELTSApplicationMediator(note.getBody()));
		}

	}
}
