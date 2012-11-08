package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.ContentEvent;
	import com.sparkTree.Tree;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	
	public class ContentSelectorView extends BentoView {
		
		[SkinPart(required="true")]
		public var tree:Tree;
		
		[SkinPart(required="true")]
		public var selectButton:Button;
		
		[SkinPart(required="true")]
		public var cancelButton:Button;
		
		[Bindable]
		public var titleCollection:ArrayCollection;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case tree:
					break;
				case selectButton:
					selectButton.addEventListener(MouseEvent.CLICK, onSelectButton);
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancelButton);
					break;
			}
		}
		
		protected function onSelectButton(event:MouseEvent):void {
			if (tree.selectedItem) {
				dispatchEvent(new ContentEvent(ContentEvent.CONTENT_SELECT, tree.selectedItem.uid, true));
				dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
			}
		}
		
		protected function onCancelButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
}