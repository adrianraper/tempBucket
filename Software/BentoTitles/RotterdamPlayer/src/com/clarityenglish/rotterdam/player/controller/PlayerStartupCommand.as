package com.clarityenglish.rotterdam.player.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.view.progress.ProgressMediator;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.transform.CourseAttributeCopyTransform;
	import com.clarityenglish.bento.vo.content.transform.CourseEnabledTransform;
	import com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform;
	import com.clarityenglish.bento.vo.content.transform.HiddenContentTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform;
	import com.clarityenglish.bento.vo.content.transform.PublicationUnitTransform;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.player.view.PlayerApplicationMediator;
	import com.clarityenglish.rotterdam.player.vo.content.transform.SingleVideoNodeTransform;
	
	import flash.system.Capabilities;
	
	import org.puremvc.as3.interfaces.INotification;

	public class PlayerStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);

			// gh#1444 BentoStartupCommand sets generic transforms
			// Set the transforms that Rotterdam player uses on its menu.xml files
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			var menuTransforms:Array = [ new PublicationUnitTransform() ];
			xhtmlProxy.registerTransforms(menuTransforms, [ Href.MENU_XHTML ]);

			// Set the transforms that Rotterdam player uses when loading its courses.xml files (gh#144)
			// gh#689, gh#882
			var courseTransforms:Array = [ new CourseEnabledTransform(), 
										new CourseAttributeCopyTransform() ]; 
			xhtmlProxy.registerTransforms(courseTransforms, [ Href.XHTML ], /^courses.xml$/);
			
			// gh#333
			ProgressMediator.reloadMenuXHTMLOnProgress = true;
			
			facade.registerMediator(new PlayerApplicationMediator(note.getBody()));
		}

	}
}
