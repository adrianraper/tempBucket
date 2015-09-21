package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class ResourcesZoneMediator extends BentoMediator implements IMediator {

        public function ResourcesZoneMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():ResourcesZoneView {
            return viewComponent as ResourcesZoneView;
        }

        override public function onRegister():void {
            super.onRegister();

            // Load courses.xml serverside gh#84
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            view.href = bentoProxy.menuXHTML.href;
        }
    }
}
