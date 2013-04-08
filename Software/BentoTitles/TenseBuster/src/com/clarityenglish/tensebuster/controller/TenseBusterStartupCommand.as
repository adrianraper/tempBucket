package com.clarityenglish.tensebuster.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	
	import org.puremvc.as3.interfaces.INotification;

	public class TenseBusterStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			/*var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			
			// Set the default function for currentCouseClass to retrieve the class of the first course
			dataProxy.setDefaultFunction("currentCourseClass", function(facade:Facade):Object {
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				return (bentoProxy.menuXHTML) ? bentoProxy.menuXHTML..course[0].@["class"].toString() : null;
			});
			
			// Set the transforms that IELTS uses on its menu.xml files
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;			
			var transforms:Array = [ new ProgressExerciseScoresTransform(),
									 new ProgressSummaryTransform(),
									 new HiddenContentTransform(),
									 new DirectStartDisableTransform(configProxy.getDirectStart()) ];
			xhtmlProxy.registerTransforms(transforms, [ Href.MENU_XHTML ]);
			
			facade.registerMediator(new IELTSApplicationMediator(note.getBody()));*/
			
			trace("STARTUP!!!!!!!!!!!!");
		}

	}
}
