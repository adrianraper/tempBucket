/**
 * Created by alice on 22/4/15.
 */
package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.googlecode.bindagetools.Bind;

import org.puremvc.as3.interfaces.IMediator;

    public class ZoneMediator extends BentoMediator implements IMediator {

        public function ZoneMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():ZoneView {
            return viewComponent as ZoneView;
        }

        override public function onRegister():void {
            super.onRegister();

            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            Bind.fromProperty(bentoProxy, "selectedCourseNode").toProperty(view, "course");
        }
    }
}
