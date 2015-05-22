package com.clarityenglish.practicalwritingair {
import com.clarityenglish.bento.BentoFacade;
import com.clarityenglish.practicalwriting.PracticalWritingApplicationFacade;

    public class PracticalWritingAirApplicationFacade extends PracticalWritingApplicationFacade {

        public static function getInstance():BentoFacade {
            if (instance == null) instance = new PracticalWritingApplicationFacade();
            return instance as BentoFacade;
        }

        override protected function initializeController():void {
            super.initializeController();
        }
    }
}
