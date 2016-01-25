package com.clarityenglish.clearpronunciation.controller {
	import com.clarityenglish.bento.RecorderNotifications;
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.model.AudioProxy;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.model.adaptor.AIRRecorderAdaptor;
	import com.clarityenglish.bento.model.adaptor.IRecorderAdaptor;
	import com.clarityenglish.bento.model.adaptor.WebRecorderAdaptor;
	import com.clarityenglish.bento.view.progress.ProgressMediator;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform;
import com.clarityenglish.bento.vo.content.transform.ExercisePathsTransform;
import com.clarityenglish.bento.vo.content.transform.HiddenContentTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform;
	import com.clarityenglish.bento.vo.content.transform.PublicationUnitTransform;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.clearpronunciation.view.ClearPronunciationApplicationMediator;
	
	import org.davekeen.util.PlayerUtils;
	import org.puremvc.as3.interfaces.INotification;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.bento.model.BentoProxy;
	import org.puremvc.as3.patterns.facade.Facade;
	
	public class ClearPronunciationStartupCommand extends BentoStartupCommand {
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var recorderAdaptor:IRecorderAdaptor = (PlayerUtils.isAirApplication()) ? new AIRRecorderAdaptor() : new WebRecorderAdaptor();
			facade.registerProxy(new AudioProxy(RecorderNotifications.RECORD_PROXY_NAME, true, recorderAdaptor));
			facade.registerProxy(new AudioProxy(RecorderNotifications.MODEL_PROXY_NAME, false, recorderAdaptor));
			
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;			
			// Set the default function for currentCourseClass to retrieve the class of the first course
			dataProxy.setDefaultFunction("currentCourseClass", function(facade:Facade):Object {
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				return (bentoProxy.menuXHTML) ? bentoProxy.menuXHTML..course[1].@["class"].toString() : null;
			});
			
			// Set the transforms that ClearPronunciation uses on its menu.xml files
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			// gh#1444
			var menuTransforms:Array = [ new ProgressExerciseScoresTransform(),
				new ProgressSummaryTransform(),
				new HiddenContentTransform(),
                /*new DirectStartDisableTransform(configProxy.getDirectStart())*/];
			xhtmlProxy.registerTransforms(menuTransforms, [ Href.MENU_XHTML ]);

			// gh#1408
			var exerciseTransforms:Array = [ new ExercisePathsTransform(configProxy.getConfig().paths) ];
			xhtmlProxy.registerTransforms(exerciseTransforms, [ Href.EXERCISE ]);

			// gh#333
			ProgressMediator.reloadMenuXHTMLOnProgress = true;
			
			facade.registerMediator(new ClearPronunciationApplicationMediator(note.getBody()));
		}
		
	}
}