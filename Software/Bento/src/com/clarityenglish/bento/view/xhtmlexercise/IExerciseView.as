package com.clarityenglish.bento.view.xhtmlexercise {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	import com.clarityenglish.textLayout.elements.AudioElement;
	
	import flash.events.IEventDispatcher;
	
	import org.osflash.signals.Signal;
	
	public interface IExerciseView extends IEventDispatcher {
		
		function set courseCaption(value:String):void;
		function get exercise():Exercise;
		function selectAnswerMap(question:Question, answerMap:AnswerMap):void;
		function markAnswerMap(question:Question, answerMap:AnswerMap, isShowAnswers:Boolean = false):void
		function setExerciseMarked(marked:Boolean = true):void;
		function stopAllAudio():void;
		function enableFeedbackAudio():void; // gh#348
		function getQuestionFeedback():Signal; // gh#388, gh#413
		function modifyMakingClass(question:Question, selectedAnswerMap:AnswerMap, markableAnswerMap:AnswerMap, marked:Boolean = true):void; // gh#627
	}
	
}