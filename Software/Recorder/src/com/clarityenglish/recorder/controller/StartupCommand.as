/*
Simple Command - PureMVC
 */
package com.clarityenglish.recorder.controller {
	import com.clarityenglish.recorder.adaptor.IRecorderAdaptor;
	import com.clarityenglish.recorder.ApplicationFacade;
	import com.clarityenglish.recorder.model.AudioProxy;
	import com.clarityenglish.recorder.model.LocalConnectionProxy;
	import com.clarityenglish.recorder.view.ApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class StartupCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			// Get the adaptor that allows us to treat AIR and web versions of recorder in the same way
			var recorderAdaptor:IRecorderAdaptor = note.getBody().parentApplication.recorderAdaptor as IRecorderAdaptor;
			
			// Register proxies
			facade.registerProxy(new AudioProxy(ApplicationFacade.RECORD_PROXY_NAME, true, recorderAdaptor)); // Record enabled
			facade.registerProxy(new AudioProxy(ApplicationFacade.MODEL_PROXY_NAME, false, recorderAdaptor)); // Record disabled
			
			facade.registerProxy(new LocalConnectionProxy());
			
			// Register mediators
			facade.registerMediator(new ApplicationMediator(note.getBody()));
		}
		
	}
}