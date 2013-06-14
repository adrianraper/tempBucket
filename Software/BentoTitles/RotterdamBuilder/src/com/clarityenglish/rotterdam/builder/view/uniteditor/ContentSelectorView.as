package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.ContentEvent;
	import com.sparkTree.Tree;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
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
		
		public var thumbnailScript:String;
		public var exIndex:Number;
		
		[Embed(source="/skins/rotterdam/builder/assets/unit/icon_program_arrow_right.png")]
		public var arrowRight:Class;
		
		[Embed(source="/skins/rotterdam/builder/assets/unit/icon_program_arrow_down.png")]
		public var arrowDown:Class;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case tree:
					tree.setStyle("disclosureClosedIcon", arrowRight);
					tree.setStyle("disclosureOpenIcon", arrowDown);
					tree.setStyle("padddingLeft", 10);
					break;
				case selectButton:
					selectButton.addEventListener(MouseEvent.CLICK, onSelectButton);
					selectButton.label = copyProvider.getCopyForId("selectContentButton");
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancelButton);
					cancelButton.label = copyProvider.getCopyForId("cancelButton");
					break;
			}
		}
		
		protected function onSelectButton(event:MouseEvent):void {
			if (tree.selectedItem) {
				//gh #181
				if (getQualifiedClassName(tree.selectedItem).indexOf("Exercise") == -1) {
					tree.selectedItem.name = "";
				}
				//gh #181 enhancement: adding program title to each practice you select
				var rootItem:Object = tree.selectedItem
				while (rootItem.parent) {
					rootItem = rootItem.parent;
				}
				// gh#366
				// Due to we delete course id in filter for single course title, here we insert the course id back
				var uid:String =  tree.selectedItem.uid;
				if (getQualifiedClassName(tree.selectedItem).indexOf("Unit") != -1) {
					var title:Object = tree.selectedItem.parent;
					if (title.courseID) {
						uid = title.id + "." + title.courseID + "." + tree.selectedItem.id;
					}
				} else if (getQualifiedClassName(tree.selectedItem).indexOf("Exercise") != -1) {
					title = tree.selectedItem.parent.parent;
					if (title.courseID) {
						uid = title.id + "." + title.courseID + "." + tree.selectedItem.parent.id + "." + tree.selectedItem.id;
					}
				}	
				dispatchEvent(new ContentEvent(ContentEvent.CONTENT_SELECT, uid, tree.selectedItem.name, rootItem.name, true));
				dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
			}
		}
		
		protected function onCancelButton(event:MouseEvent):void {
			//gh #212
			dispatchEvent(new ContentEvent(ContentEvent.CONTENT_CANCEL, null, null, null, true));
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		public function getThumbnailForUid(uid:String):String {
			return thumbnailScript + "?uid=" + uid;
		}
		
	}
}