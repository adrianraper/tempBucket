package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.model.ConfigProxy;

import mx.collections.ArrayCollection;

import org.puremvc.as3.interfaces.IMediator;

    public class StartOutZoneMediator extends BentoMediator implements IMediator {

        public function StartOutZoneMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        public function get view():StartOutZoneView {
            return viewComponent as StartOutZoneView;
        }

        public override function onRegister():void {
            super.onRegister();

            // This view runs off the menu xml so inject it here
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            if (bentoProxy.menuXHTML) view.href = bentoProxy.menuXHTML.href;

            var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
            view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);
        }
    }
}
