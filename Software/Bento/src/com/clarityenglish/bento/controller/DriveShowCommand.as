package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.Href;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class DriveShowCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var href:Href = note.getBody() as Href;
			navigateToURL(new URLRequest(href.url), "_blank");
			
			var exerciseMark:ExerciseMark = new ExerciseMark();
			exerciseMark.duration = 0;
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var matchingExerciseNodes:XMLList = bentoProxy.menuXHTML..exercise.(@href == href.filename);
			var driveNode:XML = matchingExerciseNodes[0];
			
			if (driveNode && driveNode.(hasOwnProperty("@id"))) {
				var eid:String = driveNode.@id;
				var uid:String = driveNode.parent().@id;			
				var cid:String = driveNode.parent().parent().@id;			
				var pid:String = driveNode.parent().parent().parent().@id;
			} else {
				pid = cid = uid = eid = '0';
			}
			
			exerciseMark.UID = pid + "." + cid + "." + uid + "." + eid;
			
			sendNotification(BBNotifications.SCORE_WRITE, exerciseMark)
		}
		
	}
}
