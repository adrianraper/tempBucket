package com.clarityenglish.ielts.view.login {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.login.LoginView;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.FormHeading;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
	public class LoginView extends com.clarityenglish.bento.view.login.LoginView {
		
		[SkinPart]
		public var buttonBar:ButtonBar;
		
		[SkinPart]
		public var longRateButton:Button;

		[Embed(source="/skins/ielts/assets/LMLogo.png")]
		public var lastMinuteLogo:Class;

		[Embed(source="/skins/ielts/assets/TDLogo.png")]
		public var testDriveLogo:Class;

		[Embed(source="/skins/ielts/assets/DEMOLogo.png")]
		public var demoLogo:Class;

		public var buttonBarArrayCollection:ArrayCollection = new ArrayCollection();
		
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		
		public function get productVersionText():String {
			switch (productCode) {
				case IELTSApplication.ACADEMIC_MODULE:
					switch (_productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return copyProvider.getCopyForId("lastTimeAC");
						case IELTSApplication.TEST_DRIVE:
							return copyProvider.getCopyForId("testDriveAC");
						case BentoApplication.DEMO:
							return copyProvider.getCopyForId("AC");
						case IELTSApplication.FULL_VERSION:
						default:
							return copyProvider.getCopyForId("AC");
					}
					break;
				case IELTSApplication.GENERAL_TRAINING_MODULE:
					switch (productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return copyProvider.getCopyForId("lastTimeGT");
						case IELTSApplication.TEST_DRIVE:
							return copyProvider.getCopyForId("testDriveGT");
						case BentoApplication.DEMO:
							return copyProvider.getCopyForId("GT");
						case IELTSApplication.FULL_VERSION:
						default:
							return copyProvider.getCopyForId("GT");
					}
					break;
				default:
					// No product code set yet so don't set the text
					return null;
			}
			return null;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch(instance) {
				case buttonBar:
					buttonBar.addEventListener(IndexChangeEvent.CHANGE, onButtonBarIndexChange);
					break;
				case longRateButton:
					longRateButton.label = copyProvider.getCopyForId("longRateButton");
					longRateButton.addEventListener(MouseEvent.CLICK, onLongRateButtonClick);
					break;
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if(isIPMatchedProductCodesChange) {
				isIPMatchedProductCodesChange = false;
				
				buttonBar.visible = true;
				for each (var thisProductCode:String in ipMatchedProductCodes) {
					var buttonBarObject:Object = new Object();
					buttonBarObject.caption = copyProvider.getCopyForId("demoButton" + (ipMatchedProductCodes.indexOf(thisProductCode) + 1));
					buttonBarObject.code = thisProductCode;
					buttonBarArrayCollection.addItem(buttonBarObject);
				}
				buttonBar.dataProvider = buttonBarArrayCollection;
				selectedProductCode = buttonBarArrayCollection[0].code;
			}
		}
		
		protected function onButtonBarIndexChange(event:IndexChangeEvent):void {
			selectedProductCode = buttonBar.selectedItem.code;
		}
		
		protected function onLongRateButtonClick(event:MouseEvent):void {
			var urlString:String;			
			if (isPlatformipad) {
				urlString = copyProvider.getCopyForId("ipadRateLink");
			} else if (isPlatformAndroid) {
				urlString = copyProvider.getCopyForId("androidRateLink");
			}
			
			var urlRequest:URLRequest = new URLRequest(urlString);
			navigateToURL(urlRequest, "_blank");
		}
		
		// gh#1090
		override public function onStartDemo(target:Button):void {
			var demoPrefix:String = "TD";
			if (target == demoButton1) {
				startDemo.dispatch(demoPrefix, IELTSApplication.ACADEMIC_MODULE);
			} else {
				startDemo.dispatch(demoPrefix, IELTSApplication.GENERAL_TRAINING_MODULE);
			}
		}
	}
}
