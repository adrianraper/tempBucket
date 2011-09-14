package com.clarityenglish.bento.view {
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * Bento components (designed to automatically add and remove their associated mediators) should extend this class.
	 * It is *vital* that child classes do not override getMediatorName and let Bento take care of this automatically.
	 * 
	 * @author Dave Keen
	 */
	public class BentoMediator extends Mediator implements IMediator  {
		
		public function BentoMediator(mediatorName:String, viewComponent:Object) {
			super(mediatorName, viewComponent);
		}
		
	}
}