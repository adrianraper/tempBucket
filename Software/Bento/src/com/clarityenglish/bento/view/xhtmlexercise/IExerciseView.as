package com.clarityenglish.bento.view.xhtmlexercise {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	
	import flash.events.IEventDispatcher;
	
	public interface IExerciseView extends IEventDispatcher {
		
		function set courseCaption(value:String):void;
		function get exercise():Exercise;
		function selectAnswerMap(question:Question, answerMap:AnswerMap):void;
		function markAnswerMap(question:Question, answerMap:AnswerMap, isShowAnswers:Boolean = false):void
		function setExerciseMarked(marked:Boolean = true):void;
		function stopAllAudio():void;
		
	}
	
}