/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	
	import com.clarityenglish.bento.model.SCORMProxy;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.ProgressProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class ScoreWriteCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var data:ExerciseMark = note.getBody() as ExerciseMark;
			
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			progressProxy.writeScore(data);
			
			// #336 If you are running in SCORM, you also need to write a score to the LMS
			var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (configProxy.getConfig().scorm) 
				scormProxy.writeScore(data);
			
		}
		
	}
}