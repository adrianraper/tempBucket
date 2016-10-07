package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.bento.model.ExternalInterfaceProxy;
	import com.clarityenglish.bento.model.SCORMProxy;
	import com.clarityenglish.bento.model.XHTMLProxy;
import com.clarityenglish.bento.vo.Href;
import com.clarityenglish.bento.vo.content.transform.DirectStartDisableTransform;
import com.clarityenglish.bento.vo.content.transform.ExercisePathsTransform;
import com.clarityenglish.bento.vo.content.transform.HiddenContentTransform;
import com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform;
import com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform;
import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.model.MemoryProxy;
	import com.clarityenglish.common.model.ProgressProxy;
	
	import flash.system.Capabilities;
	
	import mx.core.FlexGlobals;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class BentoStartupCommand extends SimpleCommand {
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// If we are running in the standalone player use a session name of 'flash' so authentication and uploads still work
			if (Capabilities.playerType == "StandAlone" && FlexGlobals.topLevelApplication.parameters.sessionid == undefined)
				FlexGlobals.topLevelApplication.parameters.sessionid = "flash";
			
			// #269
			sendNotification(BBNotifications.ACTIVITY_TIMER_RESET);

			// Register models
			facade.registerProxy(new BentoProxy());
			facade.registerProxy(new ConfigProxy());
			facade.registerProxy(new XHTMLProxy());
			facade.registerProxy(new LoginProxy());
			facade.registerProxy(new ProgressProxy());
			facade.registerProxy(new CopyProxy());
			facade.registerProxy(new ExternalInterfaceProxy());
			facade.registerProxy(new DataProxy());
			// gh#1067
			facade.registerProxy(new MemoryProxy());
			
			// #336
			facade.registerProxy(new SCORMProxy());
			
			// Start the configuration loading which kicks off the whole app
			sendNotification(CommonNotifications.CONFIG_LOAD);

			// #gh1444, gh#1408
            // Set the transforms that all Bento programs use on menu.xml files
            var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
            var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
            // gh#1444
            var menuTransforms:Array = [ new ProgressExerciseScoresTransform(),
                new ProgressSummaryTransform(),
                new HiddenContentTransform()/*,
                new DirectStartDisableTransform(configProxy.getDirectStart())*/ ];
            xhtmlProxy.registerTransforms(menuTransforms, [ Href.MENU_XHTML ]);

            // gh#1408
            // Set the transforms that all Bento programs use on exercise.xml files
            var exerciseTransforms:Array = [ new ExercisePathsTransform(configProxy.getConfig().paths) ];
            xhtmlProxy.registerTransforms(exerciseTransforms, [ Href.EXERCISE ]);

		}
		
	}
	
}