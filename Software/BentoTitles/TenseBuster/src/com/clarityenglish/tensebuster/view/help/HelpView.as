package com.clarityenglish.tensebuster.view.help
{
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	import skins.tensebuster.help.PageNumberDisplay;
	
	import spark.components.DataGroup;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class HelpView extends BentoView {
		
		[SkinPart]
		public var helpList:List;
		
		[SkinPart]
		public var helpDataGroup:DataGroup;
		
		[SkinPart]
		public var pageNumberDisplay:PageNumberDisplay;
		
		[Bindable]
		private var listXML:XML;
		
		[Bindable]
		public var mainMenuXML:XML;
		
		private var _copyProvider:CopyProvider;
		private var listString:String;
		private var mainMenuString:String;
		private var pageNumberCollection:ArrayCollection;
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			listString = copyProvider.getCopyForId("listXML");
			listXML = XML(listString);
			helpList.dataProvider = new XMLListCollection(listXML.item);
		
			mainMenuString = copyProvider.getCopyForId("mainMenuXML");
			mainMenuXML = XML(mainMenuString);
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case helpList:
					helpList.addEventListener(IndexChangeEvent.CHANGE, onIndexChange);
					break;
			}
		}
		
		protected function onIndexChange(event:IndexChangeEvent):void {
			pageNumberCollection = new ArrayCollection();
			for (var i:Number = 0; i < helpDataGroup.dataProvider.length; i++) {
				pageNumberCollection.addItem(i + 1);
			}
			pageNumberDisplay.dataProvider = pageNumberCollection;
			
			if (pageNumberCollection.length > 1){
				pageNumberDisplay.visible = true;
			}
		}
	}
}