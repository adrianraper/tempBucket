package com.clarityenglish.ielts.view.support {
import com.clarityenglish.bento.BentoApplication;
import com.clarityenglish.bento.view.base.BentoView;
import com.clarityenglish.ielts.IELTSApplication;

import spark.components.ViewNavigator;

public class SupportView extends BentoView {

		[SkinPart]
		public var helpViewNavigator:ViewNavigator;

		[SkinPart]
		public var creditsViewNavigator:ViewNavigator;

		public function SupportView() {
			super();
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);

			switch (instance) {
				case helpViewNavigator:
					helpViewNavigator.label = copyProvider.getCopyForId("Help");
					break;
				case creditsViewNavigator:
					creditsViewNavigator.label = copyProvider.getCopyForId("credits");
					break;
			}
		}

		protected override function getCurrentSkinState():String {
			switch (productVersion) {
				case BentoApplication.DEMO:
					return "demo";
				case IELTSApplication.TEST_DRIVE:
					return "testDrive";
				case IELTSApplication.FULL_VERSION:
					return "fullVersion";
				case IELTSApplication.LAST_MINUTE:
					return "lastMinute";
				case IELTSApplication.HOME_USER:
					return "homeUser";
				default:
					return super.getCurrentSkinState();
			}
		}

	}
	
}