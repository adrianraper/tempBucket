package com.clarityenglish.bento.controller {
    import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.BentoApplication;
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.common.model.LoginProxy;

import flash.events.Event;

import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

    /**
     * gh#604
     */
    public class UserActiveCommand extends SimpleCommand {

        public override function execute(note:INotification):void {
            super.execute(note);

            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            bentoProxy.onUserPresent();
        }

    }
}