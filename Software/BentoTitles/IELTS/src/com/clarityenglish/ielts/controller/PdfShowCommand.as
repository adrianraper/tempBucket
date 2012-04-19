package com.clarityenglish.ielts.controller {
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
	
	public class PdfShowCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var href:Href = note.getBody() as Href;
			navigateToURL(new URLRequest(href.url), "_blank");
			
			// You can't record that the student has opened this pdf here, because
			// some pdfs (like the eBook download) don't count.
			// Or should that be set by enabledFlag in menu.xml? After all, the pdf is listed as an exercise...
			var exerciseMark:ExerciseMark = new ExerciseMark();
			// TODO. This exercise has 0 duration. Perhaps this will allow us to group offline activities in a report. 
			exerciseMark.duration = 0;
			// How can I find the exerciseUID?
			// This is cheating as I should be setting currentExercise somewhere...
			// TODO. This is also wrong, as some exercises have href and answerHref etc.
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var matchingExerciseNodes:XMLList = bentoProxy.menuXHTML..exercise.(@href == href.filename);
			var pdfNode:XML = matchingExerciseNodes[0];
			
			if (pdfNode && pdfNode.(hasOwnProperty("@id"))) {
				var eid:String = pdfNode.@id;
				var uid:String = pdfNode.parent().@id;			
				var cid:String = pdfNode.parent().parent().@id;			
				var pid:String = pdfNode.parent().parent().parent().@id;
			} else {
				pid = cid = uid = eid = '0';
			}
			
			exerciseMark.UID = pid + "." + cid + "." + uid + "." + eid;
			
			sendNotification(BBNotifications.SCORE_WRITE, exerciseMark)
			
		}
		
	}
}
