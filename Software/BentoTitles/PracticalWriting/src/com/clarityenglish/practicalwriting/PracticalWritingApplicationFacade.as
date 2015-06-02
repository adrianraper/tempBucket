package com.clarityenglish.practicalwriting {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.BentoFacade;
import com.clarityenglish.bento.view.exercise.ExerciseMediator;
import com.clarityenglish.practicalwriting.controller.PracticalWritingStartupCommand;
import com.clarityenglish.practicalwriting.view.exercise.ExerciseView;
import com.clarityenglish.practicalwriting.view.home.HomeMediator;
import com.clarityenglish.practicalwriting.view.home.HomeView;
import com.clarityenglish.practicalwriting.view.progress.ProgressAnalysisView;
import com.clarityenglish.practicalwriting.view.progress.ProgressCertificateView;
import com.clarityenglish.practicalwriting.view.progress.ProgressCompareMediator;
import com.clarityenglish.practicalwriting.view.progress.ProgressCompareView;
import com.clarityenglish.practicalwriting.view.progress.ProgressCoverageMediator;
import com.clarityenglish.practicalwriting.view.progress.ProgressCoverageView;
import com.clarityenglish.practicalwriting.view.progress.ProgressMediator;
import com.clarityenglish.practicalwriting.view.progress.ProgressScoreMediator;
import com.clarityenglish.practicalwriting.view.progress.ProgressScoreView;
import com.clarityenglish.practicalwriting.view.progress.ProgressView;
import com.clarityenglish.practicalwriting.view.settings.SettingsMediator;
import com.clarityenglish.practicalwriting.view.settings.SettingsView;
import com.clarityenglish.practicalwriting.view.title.TitleMediator;
import com.clarityenglish.practicalwriting.view.title.TitleView;
import com.clarityenglish.practicalwriting.view.zone.PracticeZoneMediator;
import com.clarityenglish.practicalwriting.view.zone.PracticeZoneView;
import com.clarityenglish.practicalwriting.view.zone.ResourcesZoneMediator;
import com.clarityenglish.practicalwriting.view.zone.ResourcesZoneView;
import com.clarityenglish.practicalwriting.view.zone.StartOutZoneMediator;
import com.clarityenglish.practicalwriting.view.zone.StartOutZoneView;
import com.clarityenglish.practicalwriting.view.zone.ZoneMediator;
import com.clarityenglish.practicalwriting.view.zone.ZoneView;

public class PracticalWritingApplicationFacade extends BentoFacade {

        public static function getInstance():BentoFacade {
            if (instance == null) instance = new PracticalWritingApplicationFacade();
            return instance as BentoFacade;
        }

        override protected function initializeController():void {
            super.initializeController();

            mapView(TitleView, TitleMediator);
            mapView(HomeView, HomeMediator);
            mapView(ZoneView, ZoneMediator);
            mapView(StartOutZoneView, StartOutZoneMediator);
            mapView(PracticeZoneView, PracticeZoneMediator);
            mapView(ResourcesZoneView, ResourcesZoneMediator);
            mapView(ExerciseView, ExerciseMediator);
            mapView(ProgressView, ProgressMediator);
            mapView(ProgressCoverageView, ProgressCoverageMediator);
            mapView(ProgressCompareView, ProgressCompareMediator);
            mapView(ProgressAnalysisView, ProgressAnalysisView);
            mapView(ProgressScoreView, ProgressScoreMediator);
            mapView(ProgressCertificateView, ProgressCertificateView);
            mapView(SettingsView, SettingsMediator);

            registerCommand(BBNotifications.STARTUP, PracticalWritingStartupCommand);
        }
    }
}
