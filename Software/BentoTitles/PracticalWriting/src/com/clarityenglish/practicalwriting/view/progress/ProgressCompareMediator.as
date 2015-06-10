package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.model.DataProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.CommonNotifications;
import com.clarityenglish.common.model.ConfigProxy;
import com.clarityenglish.common.model.CopyProxy;

import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import org.davekeen.delegates.RemoteDelegate;
import org.davekeen.rpc.ResultResponder;
import org.puremvc.as3.interfaces.IMediator;
import org.puremvc.as3.interfaces.INotification;

public class ProgressCompareMediator extends BentoMediator implements IMediator {
    public function ProgressCompareMediator(mediatorName:String, viewComponent:BentoView) {
        super(mediatorName, viewComponent);
    }

    private function get view():ProgressCompareView {
        return viewComponent as ProgressCompareView;
    }

    override public function onRegister():void {
        super.onRegister();

        // This view runs off the menu xml so inject it here
        var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
        view.href = bentoProxy.menuXHTML.href;

        // getEveryoneSummary is only used by the compare mediator, so use a direct call with a responder instead of mucking about with notifications
        new RemoteDelegate("getEveryoneUnitSummary", [ view.productCode, view.config.rootID ]).execute().addResponder(new ResultResponder(
                function(e:ResultEvent, data:AsyncToken):void {
                    view.everyoneCourseSummaries = e.result;
                },
                function(e:FaultEvent, data:AsyncToken):void {
                    var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
                    sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorCantLoadEveryoneSummary"));
                }
        ));

        var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
        if (!configProxy.isPlatformTablet()) {
            view.isPlatformOnline = true;
        }
    }
}
}