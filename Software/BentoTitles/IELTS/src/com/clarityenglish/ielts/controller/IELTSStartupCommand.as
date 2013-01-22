package com.clarityenglish.ielts.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.controller.MenuXHTMLLoadCommand;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform;
	import com.clarityenglish.bento.vo.content.transform.HiddenContentTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressCourseSummaryTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform;
	import com.clarityenglish.common.model.ConfigProxy;
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
			
			// Set the transforms that IELTS uses on its menu.xml files
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			MenuXHTMLLoadCommand.transforms = [ new ProgressExerciseScoresTransform(), new ProgressCourseSummaryTransform(), new HiddenContentTransform(), new DirectStartDisableTransform(configProxy.getDirectStart()) ];
			
			facade.registerMediator(new IELTSApplicationMediator(note.getBody()));
		}

	}
}
