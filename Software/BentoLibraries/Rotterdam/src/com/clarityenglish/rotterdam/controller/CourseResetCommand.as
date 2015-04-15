package com.clarityenglish.rotterdam.controller {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.XHTMLProxy;
	import com.clarityenglish.common.model.ProgressProxy;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.resultsmanager.vo.manageable.User;
	import com.clarityenglish.dms.vo.account.Licence;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.primitives.Line;
	
	/**
	 * This command clears cached files related to a course.
	 * This is based on BentoResetCommand, but doesn't need to clear out any login information
	 * Perhaps it should just be a variation of that command with a stayLoggedIn parameter?
	 */
	public class CourseResetCommand extends SimpleCommand {
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			
			courseProxy.courseEnd();
			
			progressProxy.reset();
			bentoProxy.reset();
			xhtmlProxy.reset();
			courseProxy.reset();
		}
		
	}
	
}