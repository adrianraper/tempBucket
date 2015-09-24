/**
 * Created by alice on 22/4/15.
 */
package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.model.DataProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.CommonNotifications;
import com.clarityenglish.common.events.MemoryEvent;
import com.clarityenglish.common.model.CopyProxy;
import com.clarityenglish.common.model.LoginProxy;
import com.clarityenglish.common.model.MemoryProxy;
import com.googlecode.bindagetools.Bind;

import flash.events.Event;

import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;

import mx.rpc.events.ResultEvent;

import org.davekeen.delegates.RemoteDelegate;
import org.davekeen.rpc.ResultResponder;

import org.puremvc.as3.interfaces.IMediator;
import org.puremvc.as3.interfaces.INotification;

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

            // getEveryoneSummary is only used by the compare mediator, so use a direct call with a responder instead of mucking about with notifications
            new RemoteDelegate("getEveryoneUnitSummary", [ view.productCode, view.config.rootID ]).execute().addResponder(new ResultResponder(
                    function(e:ResultEvent, data:AsyncToken):void {
                        view.everyoneCourseSummaries = e.result;
                    }
                    // gh#1299 Not sure you need to report an error here, there is nothing to be done about it!
                    /*
                    function(e:FaultEvent, data:AsyncToken):void {
                        var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
                        sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorCantLoadEveryoneSummary",null,false));
                    }
                    */
            ));

            var memoryProxy:MemoryProxy = facade.retrieveProxy(MemoryProxy.NAME) as MemoryProxy;
            var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
            if (dataProxy.has("openUnit")) {
                view.openUnitMemories = dataProxy.get("openUnit");
            } else {
                view.openUnitMemories = memoryProxy.memories;
            }

            view.writeMemory.add(onMemoryWrite);
        }

        override public function onRemove():void {
            super.onRemove();

            view.writeMemory.remove(onMemoryWrite);
        }

        override public function listNotificationInterests():Array {
            return super.listNotificationInterests().concat([
                BBNotifications.DATA_CHANGED,
            ]);
        }

        override public function handleNotification(note:INotification):void {
            super.handleNotification(note);

            switch (note.getName()) {
                case BBNotifications.DATA_CHANGED:
                    if (note.getType() == "openUnit") view.openUnitMemories = note.getBody() as String;
                    break;
            }
        }

        private function onMemoryWrite(memoryEvent:MemoryEvent):void {
            var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
            dataProxy.set("openUnit", memoryEvent.memory.openUnit);

            // gh#1313
            var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
            if (!loginProxy.user.isAnonymous()) {
                sendNotification(CommonNotifications.WRITE_MEMORY, memoryEvent);
            }
        }
    }
}
