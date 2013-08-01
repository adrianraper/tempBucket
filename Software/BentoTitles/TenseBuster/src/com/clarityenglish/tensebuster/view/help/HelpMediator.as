package com.clarityenglish.tensebuster.view.help
{
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import org.puremvc.as3.interfaces.IMediator;
	
	public class HelpMediator extends BentoMediator implements IMediator
	{
		public function HelpMediator(mediatorName:String, viewComponent:BentoView)
		{
			super(mediatorName, viewComponent);
		}
	}
}