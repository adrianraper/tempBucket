/**
 * Created by alice on 17/4/15.
 */
package com.clarityenglish.practicalwriting.view.progress {
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class ProgressMediator extends BentoMediator implements IMediator {

        public function ProgressMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():ProgressView {
            return viewComponent as ProgressView;
        }
    }
}
