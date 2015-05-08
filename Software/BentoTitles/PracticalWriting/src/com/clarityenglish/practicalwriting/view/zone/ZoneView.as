package com.clarityenglish.practicalwriting.view.zone {
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.textLayout.vo.XHTML;

    public class ZoneView extends BentoView {

        [Bindable]
        public var course:XML;

        override protected function updateViewFromXHTML(xhtml:XHTML):void {
            super.updateViewFromXHTML(xhtml);
        }

    }
}
