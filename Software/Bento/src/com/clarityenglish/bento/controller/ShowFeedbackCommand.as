package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	import com.newgonzo.commons.utils.StringUtil;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ShowFeedbackCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
		}
		
	}
	
}