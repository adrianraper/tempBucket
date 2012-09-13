package com.clarityenglish.rotterdam.builder.view.courseeditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.ToggleButton;
	import spark.components.ViewNavigator;
	import spark.events.IndexChangeEvent;
	
	[SkinState("uniteditor")]
	[SkinState("unitplayer")]
	public class CourseEditorView extends BentoView {
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var unitViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var addUnitButton:Button;
		
		[SkinPart]
		public var previewButton:ToggleButton;
		
		private var unitListCollection:ListCollectionView;
		
		private var _selectedUnitXML:XML;
				
		private function get course():XML {	
			return _xhtml.selectOne("script#model[type='application/xml'] course");
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			unitListCollection =  new XMLListCollection(course.unit);
			unitList.dataProvider = unitListCollection;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					unitList.dragEnabled = unitList.dropEnabled = unitList.dragMoveEnabled = true;
					unitList.addEventListener(IndexChangeEvent.CHANGE, onUnitSelected);
					break;
				case addUnitButton:
					addUnitButton.addEventListener(MouseEvent.CLICK, onAddUnit);
					break;
				case previewButton:
					previewButton.addEventListener(MouseEvent.CLICK, onPreview);
					break;
			}
		}
		
		protected function onUnitSelected(event:IndexChangeEvent):void {
			unitViewNavigator.activeView.data = unitList.selectedItem;
		}
		
		private function onAddUnit(event:MouseEvent):void {
			// TODO: need to have the designs to know exactly how this will work but for now just use a random name
			unitListCollection.addItem(<unit caption='New unit' />);
		}
		
		private function onPreview(event:MouseEvent):void {
			invalidateSkinState();
		}
		
		/**
		 * Switch between editing and viewing
		 */
		protected override function getCurrentSkinState():String {
			if (!previewButton)
				return super.getCurrentSkinState();
			
			return (previewButton.selected) ? "unitplayer" : "uniteditor";
		}

	}
}