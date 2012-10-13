package com.clarityenglish.ielts.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.ielts.model.IELTSProxy;
	import com.clarityenglish.ielts.view.IELTSApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;

	public class IELTSStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Register models
			facade.registerProxy(new IELTSProxy());
			
			facade.registerMediator(new IELTSApplicationMediator(note.getBody()));
		}

	}
}
