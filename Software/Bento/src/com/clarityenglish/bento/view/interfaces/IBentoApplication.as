package com.clarityenglish.bento.view.interfaces {
	import com.clarityenglish.bento.vo.content.model.answer.Feedback;
	import com.clarityenglish.common.vo.config.BentoError;
	
	public interface IBentoApplication {
		
		function showErrorMessage(error:BentoError):void;
		
	}
}
