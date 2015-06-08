package com.clarityenglish.practicalwriting.view.closing {
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.practicalwriting.view.closing.ClosingView;

import org.puremvc.as3.interfaces.IMediator;

    public class ClosingMediator extends BentoMediator implements IMediator {

        public function ClosingMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():ClosingView {
            return viewComponent as ClosingView;
        }
    }
}
