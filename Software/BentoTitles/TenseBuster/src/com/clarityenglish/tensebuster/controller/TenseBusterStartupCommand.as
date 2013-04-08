package com.clarityenglish.tensebuster.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform;
	import com.clarityenglish.bento.vo.content.transform.HiddenContentTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.tensebuster.view.TenseBusterApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;

	public class TenseBusterStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			/*var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			
			// Set the default function for currentCourseClass to retrieve the class of the first course
			dataProxy.setDefaultFunction("currentCourseClass", function(facade:Facade):Object {
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				return (bentoProxy.menuXHTML) ? bentoProxy.menuXHTML..course[0].@["class"].toString() : null;
			});*/
			
			// Set the transforms that TenseBuster uses on its menu.xml files
			// TODO: currently these are the same as IELTS
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;			
			var transforms:Array = [ new ProgressExerciseScoresTransform(),
									 new ProgressSummaryTransform(),
									 new HiddenContentTransform(),
									 new DirectStartDisableTransform(configProxy.getDirectStart()) ];
			xhtmlProxy.registerTransforms(transforms, [ Href.MENU_XHTML ]);
			
			facade.registerMediator(new TenseBusterApplicationMediator(note.getBody()));
		}

	}
}
