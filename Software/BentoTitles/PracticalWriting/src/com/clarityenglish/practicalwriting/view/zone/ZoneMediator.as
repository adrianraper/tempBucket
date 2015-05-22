/**
 * Created by alice on 22/4/15.
 */
package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.view.base.BentoMediator;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.common.CommonNotifications;
import com.clarityenglish.common.model.CopyProxy;
import com.googlecode.bindagetools.Bind;

import flash.events.Event;

import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;

import mx.rpc.events.ResultEvent;

import org.davekeen.delegates.RemoteDelegate;
import org.davekeen.rpc.ResultResponder;

import org.puremvc.as3.interfaces.IMediator;

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
                    },
                    function(e:FaultEvent, data:AsyncToken):void {
                        var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
                        sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorCantLoadEveryoneSummary"));
                    }
            ));
        }
    }
}
