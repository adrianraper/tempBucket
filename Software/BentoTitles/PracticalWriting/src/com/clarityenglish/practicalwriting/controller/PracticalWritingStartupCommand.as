/**
 * Created by alice on 17/4/15.
 */
package com.clarityenglish.practicalwriting.controller {
import com.clarityenglish.bento.controller.BentoStartupCommand;
import com.clarityenglish.practicalwriting.view.PracticalWritingApplicationMediator;

import org.puremvc.as3.interfaces.INotification;

public class PracticalWritingStartupCommand extends BentoStartupCommand {

        // gh#1444 BentoStartupCommand sets generic transforms
        override public function execute(note:INotification):void {
            super.execute(note);

            facade.registerMediator(new PracticalWritingApplicationMediator(note.getBody()));
        }
    }
}
