package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.transform.CourseAttributeCopyTransform;
	import com.clarityenglish.bento.vo.content.transform.PublicationDatesTransform;
	import com.clarityenglish.rotterdam.builder.view.BuilderApplicationMediator;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import org.puremvc.as3.interfaces.INotification;

	public class BuilderStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Set the transforms that Rotterdam builder uses on its menu.xml files
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;		
			xhtmlProxy.registerTransforms([ new PublicationDatesTransform() ], [ Href.MENU_XHTML ]);
			
			// Set the transforms that Rotterdam player uses when loading its courses.xml files
			xhtmlProxy.registerTransforms([ new CourseAttributeCopyTransform() ], [ Href.XHTML ], /^courses.xml$/);
			
			// Setup some hook functions that allow us to do stuff before and after an XHTML file has loaded (gh#90)
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			xhtmlProxy.beforeXHTMLLoadFunction = courseProxy.beforeXHTMLLoad;
			xhtmlProxy.afterXHTMLLoadFunction = courseProxy.afterXHTMLLoad;
			
			facade.registerMediator(new BuilderApplicationMediator(note.getBody()));
		}

	}
}
