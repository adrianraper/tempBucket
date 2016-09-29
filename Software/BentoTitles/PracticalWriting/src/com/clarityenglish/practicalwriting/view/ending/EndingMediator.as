package com.clarityenglish.practicalwriting.view.ending {
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.practicalwriting.view.ending.EndingView;

import org.puremvc.as3.interfaces.IMediator;

    public class EndingMediator extends BentoMediator implements IMediator {

        public function EndingMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():EndingView {
            return viewComponent as EndingView;
        }
    }
}
