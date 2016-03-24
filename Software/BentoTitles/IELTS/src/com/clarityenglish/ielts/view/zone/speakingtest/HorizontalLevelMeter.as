package com.clarityenglish.ielts.view.zone.speakingtest {
import com.clarityenglish.bento.view.recorder.ui.LevelMeter;

import flash.display.GradientType;
import flash.display.InterpolationMethod;
import flash.display.SpreadMethod;

public class HorizontalLevelMeter extends LevelMeter{

    public function HorizontalLevelMeter() {
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        track.graphics.clear();
        track.graphics.beginFill(0xD1D1D1, 1);
        track.graphics.drawRoundRect(0, 10, unscaledWidth, unscaledHeight - 10, 3, 3);
        track.graphics.endFill();

        levelGradient.graphics.clear();
        levelGradient.graphics.beginGradientFill(GradientType.LINEAR, [ 0xFFFF00, 0xD11800 ], [ 1.0, 1.0 ], [ 0, 220 ], verticalGradientMatrix(0, - unscaledHeight / 4, unscaledWidth, unscaledHeight - 10), SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB);
        levelGradient.graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight - 10, 3, 3);
        levelGradient.graphics.endFill();
    }
}
}
