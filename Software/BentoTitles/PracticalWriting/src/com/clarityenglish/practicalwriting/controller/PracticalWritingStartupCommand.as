/**
 * Created by alice on 17/4/15.
 */
package com.clarityenglish.practicalwriting.controller {
import com.clarityenglish.bento.RecorderNotifications;
import com.clarityenglish.bento.controller.BentoStartupCommand;
import com.clarityenglish.bento.model.AudioProxy;
import com.clarityenglish.bento.model.XHTMLProxy;
import com.clarityenglish.bento.model.adaptor.AIRRecorderAdaptor;
import com.clarityenglish.bento.model.adaptor.IRecorderAdaptor;
import com.clarityenglish.bento.model.adaptor.WebRecorderAdaptor;
import com.clarityenglish.bento.vo.Href;
import com.clarityenglish.bento.vo.content.transform.HiddenContentTransform;
import com.clarityenglish.bento.vo.content.transform.ProgressExerciseScoresTransform;
import com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform;
import com.clarityenglish.common.model.ConfigProxy;
import com.clarityenglish.practicalwriting.view.PracticalWritingApplicationMediator;

import org.davekeen.util.PlayerUtils;

import org.puremvc.as3.interfaces.INotification;

public class PracticalWritingStartupCommand extends BentoStartupCommand {

        override public function execute(note:INotification):void {
            super.execute(note);

            // gh#267
            var recorderAdaptor:IRecorderAdaptor = (PlayerUtils.isAirApplication()) ? new AIRRecorderAdaptor() : new WebRecorderAdaptor();
            facade.registerProxy(new AudioProxy(RecorderNotifications.RECORD_PROXY_NAME, true, recorderAdaptor));
            facade.registerProxy(new AudioProxy(RecorderNotifications.MODEL_PROXY_NAME, false, recorderAdaptor));

            // Set the transforms that TenseBuster uses on its menu.xml files
            // TODO: currently these are the same as IELTS
            var xhtmlProxy:XHTMLProxy = facade.retrieveProxy(XHTMLProxy.NAME) as XHTMLProxy;
            var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
            var transforms:Array = [new ProgressExerciseScoresTransform(),
                new ProgressSummaryTransform(),
                new HiddenContentTransform(),
                /*new DirectStartDisableTransform(configProxy.getDirectStart())*/];
            xhtmlProxy.registerTransforms(transforms, [Href.MENU_XHTML]);

            facade.registerMediator(new PracticalWritingApplicationMediator(note.getBody()));
        }
    }
}
