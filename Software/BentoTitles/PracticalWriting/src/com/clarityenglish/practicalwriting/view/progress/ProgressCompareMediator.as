package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class ProgressCompareMediator extends BentoMediator implements IMediator {

        public function ProgressCompareMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }
    }
}
