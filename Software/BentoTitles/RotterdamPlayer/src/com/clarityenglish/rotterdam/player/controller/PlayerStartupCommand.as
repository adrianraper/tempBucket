package com.clarityenglish.rotterdam.player.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.controller.MenuXHTMLLoadCommand;
	import com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform;
	import com.clarityenglish.bento.vo.content.transform.HiddenContentTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressCourseSummaryTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform;
	import com.clarityenglish.bento.vo.content.transform.PublicationDatesTransform;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.player.view.PlayerApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;

	public class PlayerStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Set the transforms that Rotterdam player uses on its menu.xml files
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			MenuXHTMLLoadCommand.transforms = [ new ProgressExerciseScoresTransform(), new ProgressCourseSummaryTransform(), new HiddenContentTransform(), new DirectStartDisableTransform(configProxy.getDirectStart()), new PublicationDatesTransform() ];
			
			facade.registerMediator(new PlayerApplicationMediator(note.getBody()));
		}

	}
}
