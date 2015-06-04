package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.model.DataProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;
import org.puremvc.as3.interfaces.INotification;

public class ProgressScoreMediator extends BentoMediator implements IMediator {

    public function ProgressScoreMediator(mediatorName:String, viewComponent:BentoView) {
        super(mediatorName, viewComponent);
    }

    private function get view():ProgressScoreView {
        return viewComponent as ProgressScoreView;
    }

    override public function onRegister():void {
        super.onRegister();

        // This view runs off the menu xml so inject it here
        var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
        var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
        view.href = bentoProxy.menuXHTML.href;
    }

    override public function onRemove():void {
        super.onRemove();
    }
}
}