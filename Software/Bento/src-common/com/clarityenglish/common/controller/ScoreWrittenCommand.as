/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform;
	import com.clarityenglish.common.vo.progress.Score;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class ScoreWrittenCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			// gh#925 We might have chosen to skip score writing (for teachers in C-Builder)
			if (note.getBody() === true)
				return;
			
			var score:Score = note.getBody() as Score;
			
			// #109 When a score has been successfully written we want to update the menu XML on the client.  Although this
			// would be neater on the server, its much more efficient to do it this way.
			
			// First find the exercise xml
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			// gh#165 just in case you have already logged out
			if (bentoProxy.menuXHTML)
				var exercise:XML = bentoProxy.menuXHTML.selectOne("script#model[type='application/xml'] exercise[id='" + score.exerciseID + "']");
			
			if (exercise) {
				// 1. Insert a new <score> node as a child of the <exercise> (the same as ProgressExerciseScoresTransform does on the server)
				exercise.appendChild(<score score={score.score} duration={score.duration} datetime={score.dateStamp} />);
				
				// 2. Increment the @done attribute of the <exercise>
				exercise.@done = (exercise.hasOwnProperty("@done")) ? Number(exercise.@done) + 1 : 1;
				
				// 3. Rerun the ProgressCourseSummaryTransform on the client to update the summary data
				// TODO: I would have thought that this wouldn't work because of namespacing differences, but actually it seems to work fine
				//new ProgressSummaryTransform(exercise.@id).transform(bentoProxy.menuXHTML.xml);
			}
		}
		
	}
}