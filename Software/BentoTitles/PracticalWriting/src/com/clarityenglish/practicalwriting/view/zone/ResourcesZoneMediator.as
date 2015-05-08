package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class ResourcesZoneMediator extends BentoMediator implements IMediator {

        public function ResourcesZoneMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }
    }
}
