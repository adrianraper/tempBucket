package com.clarityenglish.rotterdam.builder.view.courseeditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
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
		public var backButton:Button;
		
		[SkinPart]
		public var previewButton:ToggleButton;
		
		[Bindable]
		public var unitListCollection:ListCollectionView;
		
		public var courseLoad:Signal = new Signal(XML);
		public var unitSelect:Signal = new Signal(XML);
		
		private function get course():XML {	
			return _xhtml.selectOne("script#model[type='application/xml'] course");
		}
		
		/**
		 * For the CourseEditorView the data property is the XML node from courses.xml that has been selected (this will trigger a load of the matching menu.xml in
		 * the correct folder).
		 * 
		 * @param value
		 */
		public override function set data(value:Object):void {
			super.data = value;
			
			// Tell the mediator to set the href of this view to the menu.xml file specified in the course node
			if (data)
				courseLoad.dispatch(data);
			
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
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
				case backButton:
					backButton.addEventListener(MouseEvent.CLICK, onBack);
					break;
				case previewButton:
					previewButton.addEventListener(MouseEvent.CLICK, onPreview);
					break;
			}
		}
		
		protected function onUnitSelected(event:IndexChangeEvent):void {
			unitSelect.dispatch(event.target.selectedItem);
		}
		
		private function onAddUnit(event:MouseEvent):void {
			// TODO: need to have the designs to know exactly how this will work but for now just use a random name
			unitListCollection.addItem(<unit caption='New unit' />);
		}
		
		/**
		 * No longer used
		 */
		protected function onBack(event:MouseEvent):void {
			navigator.popToFirstView();
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