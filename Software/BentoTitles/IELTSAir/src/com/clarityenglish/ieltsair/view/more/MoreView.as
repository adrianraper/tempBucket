package com.clarityenglish.ieltsair.view.more {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.Event;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.collections.ArrayCollection;
	
	import org.davekeen.util.StateUtil;
	
	import spark.components.ButtonBar;
	import spark.components.RichEditableText;
	import spark.components.RichText;
	import spark.components.TextArea;
	import spark.events.IndexChangeEvent;
	import spark.utils.TextFlowUtil;
	
	public class MoreView extends BentoView {
		
		[SkinPart]
		public var moreNavBar:ButtonBar;
		
		[SkinPart]
		public var aboutUsRichText1:RichText;
		
		[SkinPart]
		public var aboutUsRichText:RichText;
		
		[SkinPart]
		public var contactUsRichText1:RichText;
		
		[SkinPart]
		public var contactUsRichText2:RichText;
		
		
		public function MoreView() {
			StateUtil.addStates(this, [ "about", "contact" ], true);
		}

		// gh#93
		public function loadCopy(instance:Object):void {
			switch (instance) {
				case contactUsRichText1:
					if (contactUsRichText1) {
						switch (productVersion) {
							case IELTSApplication.TEST_DRIVE:
							case IELTSApplication.LAST_MINUTE:
								var supportEmail:String = this.copyProvider.getCopyForId("supportEmailR2I");
								break;
							case IELTSApplication.HOME_USER:
								supportEmail = this.copyProvider.getCopyForId("supportEmailIP");
								break;
							case IELTSApplication.FULL_VERSION:
							default:
								supportEmail = this.copyProvider.getCopyForId("supportEmailCE");
								break;
						}
						var replaceObj:Object = new Object();
						replaceObj.supportEmail = supportEmail;
						var contactUsContentString1:String = this.copyProvider.getCopyForId("contactUsContent1", replaceObj);
						var contactUsFlow1:TextFlow = TextFlowUtil.importFromString(contactUsContentString1);
						contactUsFlow1.color = "#4E4E4E";
						contactUsFlow1.fontSize = 14;
						contactUsFlow1.paragraphSpaceAfter = 12;
						contactUsFlow1.lineHeight = 22;
						contactUsRichText1.textFlow = contactUsFlow1;
					}
					break;
				case contactUsRichText2:
					if (contactUsRichText2) {
						var contactUsContentString2:String = this.copyProvider.getCopyForId("contactUsContent2");
						var contactUsFlow2:TextFlow = TextFlowUtil.importFromString(contactUsContentString2);
						contactUsFlow2.color = "#4E4E4E";
						contactUsFlow2.fontSize = 14;
						contactUsFlow2.paragraphSpaceAfter = 12;
						contactUsFlow2.lineHeight = 22;
						contactUsRichText2.textFlow = contactUsFlow2;
					}
					break;
				case aboutUsRichText:
					if (aboutUsRichText) {
						var aboutUsContentString:String = this.copyProvider.getCopyForId("aboutUsContent")
						var aboutUsFlow:TextFlow = TextFlowUtil.importFromString(aboutUsContentString);
						aboutUsFlow.color = "#4E4E4E";
						aboutUsFlow.fontSize = 14;
						aboutUsFlow.paragraphSpaceAfter = 12;
						aboutUsFlow.lineHeight = 22;
						aboutUsFlow.columnCount = 2;
						aboutUsRichText.textFlow = aboutUsFlow;
					}
					break;
			}
			
		}
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case moreNavBar:
					moreNavBar.dataProvider = new ArrayCollection( [
						{ label: copyProvider.getCopyForId("moreAboutUs") , data: "about" },
						{ label: copyProvider.getCopyForId("moreContactUs"), data: "contact" },
					] );
					
					moreNavBar.requireSelection = true;
					moreNavBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
			}
			// gh#93
			loadCopy(instance);
		}
		
		protected function onNavBarIndexChange(event:IndexChangeEvent):void {
			currentState = event.target.selectedItem.data;
			invalidateSkinState();
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}
