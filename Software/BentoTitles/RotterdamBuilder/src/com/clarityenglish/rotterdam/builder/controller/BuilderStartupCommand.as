package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.controller.BentoStartupCommand;
	import com.clarityenglish.rotterdam.builder.view.BuilderApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;

	public class BuilderStartupCommand extends BentoStartupCommand {

		public override function execute(note:INotification):void {
			super.execute(note);
			
			facade.registerMediator(new BuilderApplicationMediator(note.getBody()));
		}

	}
}
