package com.clarityenglish.ieltsair.view.more {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.Event;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.collections.ArrayCollection;
	
	import org.davekeen.util.StateUtil;
	
	import spark.components.ButtonBar;
	import spark.components.RichText;
	import spark.events.IndexChangeEvent;
	import spark.utils.TextFlowUtil;
	
	public class MoreView extends BentoView {
		
		[SkinPart]
		public var moreNavBar:ButtonBar;
		
		[SkinPart]
		public var aboutUsRichText:RichText;
		
		[SkinPart]
		public var contactUsRichText1:RichText;
		
		[SkinPart]
		public var contactUsRichText2:RichText;
		
		public function MoreView() {
			StateUtil.addStates(this, [ "about", "contact" ], true);
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
				case aboutUsRichText:
					var aboutUsContentString:String = this.copyProvider.getCopyForId("aboutUsContent")
					var aboutUsFlow:TextFlow = TextFlowUtil.importFromString(aboutUsContentString);
					aboutUsFlow.color = "#4E4E4E";
					aboutUsFlow.fontSize = 14;
					aboutUsFlow.paragraphSpaceAfter = 12;
					aboutUsFlow.lineHeight = 22;
					instance.textFlow = aboutUsFlow;
					break;
				case contactUsRichText1:
					var contactUsContentString1:String = this.copyProvider.getCopyForId("contactUsContent1");
					var contactUsFlow1:TextFlow = TextFlowUtil.importFromString(contactUsContentString1);
					contactUsFlow1.color = "#4E4E4E";
					contactUsFlow1.fontSize = 14;
					contactUsFlow1.paragraphSpaceAfter = 12;
					contactUsFlow1.lineHeight = 22;
					instance.textFlow = contactUsFlow1;
					break;
				case contactUsRichText2:
					var contactUsContentString2:String = this.copyProvider.getCopyForId("contactUsContent2");
					var contactUsFlow2:TextFlow = TextFlowUtil.importFromString(contactUsContentString2);
					contactUsFlow2.color = "#4E4E4E";
					contactUsFlow2.fontSize = 14;
					contactUsFlow2.paragraphSpaceAfter = 12;
					contactUsFlow2.lineHeight = 22;
					instance.textFlow = contactUsFlow2;
					break;
			}
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
