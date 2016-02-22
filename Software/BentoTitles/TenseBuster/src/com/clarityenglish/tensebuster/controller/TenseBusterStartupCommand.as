package com.clarityenglish.tensebuster.controller {
	import com.clarityenglish.bento.RecorderNotifications;
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.model.AudioProxy;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.model.adaptor.AIRRecorderAdaptor;
	import com.clarityenglish.bento.model.adaptor.IRecorderAdaptor;
	import com.clarityenglish.bento.model.adaptor.WebRecorderAdaptor;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform;
	import com.clarityenglish.bento.vo.content.transform.HiddenContentTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform;
import com.clarityenglish.bento.vo.content.transform.RandomizedTestTransform;
import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.tensebuster.view.TenseBusterApplicationMediator;
	
	import org.davekeen.util.PlayerUtils;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;

	public class TenseBusterStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			// gh#267
			var recorderAdaptor:IRecorderAdaptor = (PlayerUtils.isAirApplication()) ? new AIRRecorderAdaptor() : new WebRecorderAdaptor();
			facade.registerProxy(new AudioProxy(RecorderNotifications.RECORD_PROXY_NAME, true, recorderAdaptor));
			facade.registerProxy(new AudioProxy(RecorderNotifications.MODEL_PROXY_NAME, false, recorderAdaptor));
			
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			
			// Set the default function for currentCourseClass to retrieve the class of the first course
			dataProxy.setDefaultFunction("currentCourseClass", function(facade:Facade):Object {
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				return (bentoProxy.menuXHTML) ? bentoProxy.menuXHTML..course[0].@["class"].toString() : null;
			});
			
			// gh#1455, gh#1444, gh#1408 shift most transforms to BentoStartupCommand as generic
			// Set the transforms that Tense Buster uses on exercise.xml files
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			var exerciseTransforms:Array = [ new RandomizedTestTransform() ];
			xhtmlProxy.registerTransforms(exerciseTransforms, [ Href.EXERCISE ]);

			facade.registerMediator(new TenseBusterApplicationMediator(note.getBody()));
		}

	}
}
