package com.clarityenglish.practicalwriting.view.home {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;

import org.puremvc.as3.interfaces.IMediator;

    public class HomeMediator extends BentoMediator implements IMediator {

        public function HomeMediator(mediatorName:String, viewComponent:BentoView) {
            super(mediatorName, viewComponent);
        }

        private function get view():HomeView {
            return viewComponent as HomeView;
        }

        override public function onRegister():void {
            super.onRegister();

            // Load courses.xml serverside gh#84
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            if (bentoProxy.menuXHTML) view.href = bentoProxy.menuXHTML.href;

            view.courseSelect.add(onCourseSelect);
        }

        protected function onCourseSelect(course:XML):void {
            sendNotification(BBNotifications.SELECTED_NODE_CHANGE, course);
        }
    }
}
