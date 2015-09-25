package com.clarityenglish.practicalwriting.view.settings {
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.model.ConfigProxy;

import flash.net.SharedObject;

import mx.collections.ArrayCollection;

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

            // Load courses.xml serverside gh#84
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            view.href = bentoProxy.menuXHTML.href;

            var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
            view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);

            view.channelSave.add(onChannelSave);
        }

        protected function onChannelSave(value:Number):void {
            trace("channel save value: "+value);
            var settingsSharedObject:SharedObject = SharedObject.getLocal("settings");
            settingsSharedObject.data["channelIndex"] = value;
            settingsSharedObject.flush();
        }
    }
}
