package com.clarityenglish.rotterdam.player.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.transform.CourseAttributeCopyTransform;
	import com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform;
	import com.clarityenglish.bento.vo.content.transform.HiddenContentTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform;
	import com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform;
	import com.clarityenglish.bento.vo.content.transform.PublicationCourseTransform;
	import com.clarityenglish.bento.vo.content.transform.PublicationUnitTransform;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.rotterdam.player.view.PlayerApplicationMediator;
	import com.clarityenglish.rotterdam.player.vo.content.transform.SingleVideoNodeTransform;
	
	import flash.system.Capabilities;
	
	import org.puremvc.as3.interfaces.INotification;

	public class PlayerStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Set the transforms that Rotterdam player uses on its menu.xml files
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;			
			var transforms:Array = [ new ProgressExerciseScoresTransform(),
									 new ProgressSummaryTransform(),
									 new HiddenContentTransform(),
									 new DirectStartDisableTransform(configProxy.getDirectStart()),
									 new PublicationUnitTransform() ];
			
			// gh#294
			if (Capabilities.version.split(" ")[0] == "IOS") {
				transforms.push(new SingleVideoNodeTransform());
			}
			
			xhtmlProxy.registerTransforms(transforms, [ Href.MENU_XHTML ]);
			
			// Set the transforms that Rotterdam player uses when loading its courses.xml files (gh#144)
			xhtmlProxy.registerTransforms([ new CourseAttributeCopyTransform(), new PublicationCourseTransform() ], [ Href.XHTML ], /^courses.xml$/);
			
			facade.registerMediator(new PlayerApplicationMediator(note.getBody()));
		}

	}
}
