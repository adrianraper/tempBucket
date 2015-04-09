/**
 * Created by Adrian on 02/04/2015.
 */
package com.clarityenglish.common.controller {
import com.clarityenglish.common.model.ConfigProxy;

import org.puremvc.as3.interfaces.INotification;
import org.puremvc.as3.patterns.command.SimpleCommand;

    public class AccountReloadCommand extends SimpleCommand {

        override public function execute(note:INotification):void {

            var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
            configProxy.getConfig().isReloadAccount = true;
            configProxy.getApplicationParameters();
        }
    }
}
