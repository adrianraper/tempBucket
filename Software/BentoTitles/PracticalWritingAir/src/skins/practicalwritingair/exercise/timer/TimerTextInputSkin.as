package skins.practicalwritingair.exercise.timer {

import mx.core.mx_internal;

import skins.air.assets.bento.exercise.TextInput_border;

import spark.primitives.Graphic;
import spark.skins.mobile.TextInputSkin;

use namespace mx_internal;

public class TimerTextInputSkin extends TextInputSkin {

    private var dropTargetBorder:Graphic;

    public function TimerTextInputSkin() {
        super();

        borderClass = TextInput_border;
    }

    protected override function createChildren():void {


        if (!dropTargetBorder) {
            dropTargetBorder = new Graphic();
            dropTargetBorder.x = -2;
            dropTargetBorder.y = -1;
            addChild(dropTargetBorder);
        }

        super.createChildren();
    }

    protected override function commitProperties():void {
        super.commitProperties();

        if (hostComponent.editable) {
            if (border) border.visible = false;
            if (dropTargetBorder) dropTargetBorder.visible = false;
        } else {
            if (border) border.visible = false;
            if (dropTargetBorder) dropTargetBorder.visible = true;
        }
    }

    protected override function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
        super.layoutContents(unscaledWidth, unscaledHeight);

        if (dropTargetBorder && dropTargetBorder.visible) {
            dropTargetBorder.graphics.clear();
            dropTargetBorder.graphics.lineStyle(1, 0x000000, 1);
            dropTargetBorder.graphics.moveTo(0,unscaledHeight + 1);
            dropTargetBorder.graphics.lineTo(unscaledWidth + 1, unscaledHeight + 1);
            /*dropTargetBorder.graphics.beginFill(0xE6E6E6);
             dropTargetBorder.graphics.drawRoundRect(0, 0, unscaledWidth + 1, unscaledHeight + 1, 2, 2);
             dropTargetBorder.graphics.endFill();*/
        }

        // Very hacky fix for #403, but it seems to work
        setElementSize(textDisplay, unscaledWidth + 4, textDisplay.height);
        setElementPosition(textDisplay, -4, textDisplay.y);
    }

    override public function set currentState(value:String):void {
        super.currentState = value;

        if (currentState == "disabled") {
            this.alpha = 1;
        }

    }

}
}
