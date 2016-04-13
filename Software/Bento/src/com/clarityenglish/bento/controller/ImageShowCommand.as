package com.clarityenglish.bento.controller {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.vo.ExerciseMark;
import com.clarityenglish.bento.vo.Href;

import org.puremvc.as3.interfaces.INotification;
import org.puremvc.as3.patterns.command.SimpleCommand;

public class ImageShowCommand extends SimpleCommand {

    public override function execute(note:INotification):void {
        super.execute(note);

        var href:Href = note.getBody() as Href;
        var exerciseMark:ExerciseMark = new ExerciseMark();
        exerciseMark.duration = 0;

        var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
        var matchingExerciseNodes:XMLList = bentoProxy.menuXHTML..exercise.(@href == href.filename);
        var pdfNode:XML = matchingExerciseNodes[0];

        if (pdfNode && pdfNode.attribute("id").length() > 0) {
            var eid:String = pdfNode.@id;
            var uid:String = pdfNode.parent().@id;
            var cid:String = pdfNode.parent().parent().@id;
            var pid:String = pdfNode.parent().parent().parent().@id;
        } else {
            pid = cid = uid = eid = '0';
        }

        exerciseMark.UID = pid + "." + cid + "." + uid + "." + eid;

        sendNotification(BBNotifications.SCORE_WRITE, exerciseMark)
    }
}
}
