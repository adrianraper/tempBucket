package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.model.DataProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class ProgressCoverageMediator extends BentoMediator implements IMediator {

        public function ProgressCoverageMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():ProgressCoverageView {
            return viewComponent as ProgressCoverageView;
        }

        override public function onRegister():void {
            super.onRegister();

            // This view runs off the menu xml so inject it here
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
            view.href = bentoProxy.menuXHTML.href;
        }
    }
}
