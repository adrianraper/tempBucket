package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ExerciseShowNextCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			var menuXHTML:XHTML = bentoProxy.menuXHTML;
			var currentExercise:Exercise = bentoProxy.currentExercise;
			
			if (!currentExercise) {
				log.error("Attempt to go to next exercise when there is no current exercise");
				return;
			}
			
			// Locate the exercise node in menuXHTML for currentExercise by matching the hrefs
			var matchingExerciseNodes:XMLList = menuXHTML..exercise.(@href == currentExercise.href.filename);
			
			if (matchingExerciseNodes.length() > 1) {
				log.error("Unable to find any Exercise nodes in the menu xml matching {0}", currentExercise.href);
				return;
			} else if (matchingExerciseNodes.length() == 0) {
				
			} else {
				
			}
		}
		
	}
	
}