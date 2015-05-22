package com.clarityenglish.practicalwriting.view.settings {
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class SettingsMediator extends BentoMediator implements IMediator {

        public function SettingsMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():SettingsView {
            return viewComponent as SettingsView;
        }

        public override function onRegister():void {
            super.onRegister();
        }
    }
}
