/**
 * Created by alice on 17/4/15.
 */
package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.model.LoginProxy;

import org.puremvc.as3.interfaces.IMediator;
import org.puremvc.as3.interfaces.INotification;

public class ProgressMediator extends BentoMediator implements IMediator {
        // gh#333 (possibly not the neatest to have this as a static variable, but its such a rare use-case that its probably ok)
        public static var reloadMenuXHTMLOnProgress:Boolean;

        public function ProgressMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():ProgressView {
            return viewComponent as ProgressView;
        }

        override public function onRegister():void {
            super.onRegister();

            // This view runs off the menu xml so inject it here
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            view.href = bentoProxy.menuXHTML.href;

            // Inject whether this is an anonymous user or not
            var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
            view.isAnonymousUser = !loginProxy.user || loginProxy.user.isAnonymous();

            // gh#333 If reloadMenuXHTMLOnProgress is true then reload the menu xhtml
            if (reloadMenuXHTMLOnProgress)
                facade.sendNotification(BBNotifications.MENU_XHTML_RELOAD);
        }

        public override function listNotificationInterests():Array {
            return super.listNotificationInterests().concat([
                BBNotifications.SCORE_WRITTEN,
            ])
        }

        public override function handleNotification(note:INotification):void {
            super.handleNotification(note);

            switch(note.getName()) {
                case BBNotifications.SCORE_WRITTEN:
                    var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
                    view.xhtml = bentoProxy.menuXHTML;
                    break;
            }
        }
    }
}