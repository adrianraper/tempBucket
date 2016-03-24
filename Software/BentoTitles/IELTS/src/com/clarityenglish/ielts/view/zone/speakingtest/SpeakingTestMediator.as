package com.clarityenglish.ielts.view.zone.speakingtest {
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;
import org.puremvc.as3.interfaces.INotification;

public class SpeakingTestMediator extends BentoMediator implements IMediator {

    public function SpeakingTestMediator(mediatorName:String, viewComponent:BentoView) {
        super(mediatorName, viewComponent);
    }

    private function get view():SpeakingTestView {
        return viewComponent as SpeakingTestView;
    }

    override public function onRegister():void {
        super.onRegister();

        var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
        if (bentoProxy.menuXHTML) view.href = bentoProxy.menuXHTML.href;
    }

    override public function onRemove():void {
        super.onRemove();
    }

    override public function listNotificationInterests():Array {
        return super.listNotificationInterests();
    }

    override public function handleNotification(note:INotification):void {
        super.handleNotification(note);
    }
}
}
