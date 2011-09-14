package com.clarityenglish.bento.view.exercise {
	import flash.events.IEventDispatcher;
	
	/**
	 * Not quite sure about this yet, but I have a vague idea that if this defines the API for an exercise section then for particularly difficult ones we might be
	 * able to use custom SWFs instead of ExerciseRichText and HTML/CSS (which is a bit fiddly sometimes).
	 * 
	 * This will be implemented by allowing a special attribute to <section> which gives it an swf files as its source, and ExerciseView will take care of loading
	 * it.
	 * 
	 * TODO: This might actually no longer be necessary
	 * 
	 * @author Dave Keen
	 */
	public interface IExerciseSection extends IEventDispatcher {
		
		/**
		 * For the moment this is just a scratchpad describing the things that we want an exercise section to be able to do:
		 * 
		 * - drag something out of it
		 * - drag something into it
		 * 
		 * - dispatch an 'answered' message, with a score
		 * 
		 * To think about
		 * 
		 * - should feedback happen within the section or within ExerciseView?
		 */
		
	}
	
}