package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class ProgressAnalysisMeidator extends BentoMediator implements IMediator {

        public function ProgressAnalysisMeidator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }
    }
}
