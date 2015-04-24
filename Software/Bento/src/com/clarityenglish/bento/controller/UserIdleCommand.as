package com.clarityenglish.bento.controller {
    import com.clarityenglish.bento.BBNotifications;
    import com.clarityenglish.common.model.LoginProxy;

    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

    /**
     * gh#604
     */
    public class UserIdleCommand extends SimpleCommand {

        public override function execute(note:INotification):void {
            super.execute(note);

            var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
            loginProxy.userIdleHandler(note.getName() == BBNotifications.USER_IDLE);
        }

    }
}