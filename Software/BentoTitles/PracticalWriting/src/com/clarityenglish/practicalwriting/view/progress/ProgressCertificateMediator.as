package com.clarityenglish.practicalwriting.view.progress{
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.model.DataProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.model.ConfigProxy;
import com.clarityenglish.common.model.LoginProxy;

import org.puremvc.as3.interfaces.INotification;

public class ProgressCertificateMediator extends BentoMediator {

    public function ProgressCertificateMediator(mediatorName:String, viewComponent:BentoView) {
        super(mediatorName, viewComponent);
    }

    private function get view():ProgressCertificateView {
        return viewComponent as ProgressCertificateView;
    }

    override public function onRegister():void {
        super.onRegister();

        // This view runs off the menu xml so inject it here
        var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
        var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
        view.href = bentoProxy.menuXHTML.href;

        var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
        view.user = loginProxy.user;

        var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
        view.isPlatformTablet = configProxy.isPlatformTablet();
    }


    override public function onRemove():void {
        super.onRemove();
    }
}
}