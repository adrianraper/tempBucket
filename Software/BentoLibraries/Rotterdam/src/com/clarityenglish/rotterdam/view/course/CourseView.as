package com.clarityenglish.rotterdam.view.course {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.settings.SettingsView;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	/*[SkinState("uniteditor")] - this is an optional skin state */
	[SkinState("unitplayer")]
	public class CourseView extends BentoView {
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart]
		public var addUnitButton:Button;
		
		[SkinPart]
		public var courseSettingsButton:Button;
		
		[Bindable]
		public var unitListCollection:ListCollectionView;
		
		private var _isPreviewVisible:Boolean;
		
		public var unitSelect:Signal = new Signal(XML);
		
		private function get course():XML {	
			return _xhtml.selectOne("script#model[type='application/xml'] course");
		}
		
		public function set previewVisible(value:Boolean):void {
			if (_isPreviewVisible !== value) {
				_isPreviewVisible = value;
				invalidateSkinState();
			}
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
					
					// #14 - auto select a unit
					unitList.requireSelection = true;
					callLater(function():void {
						if (unitList.dataProvider.length > 0)
							unitList.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
					});
					break;
				case addUnitButton:
					addUnitButton.addEventListener(MouseEvent.CLICK, onAddUnit);
					break;
				case courseSettingsButton:
					courseSettingsButton.addEventListener(MouseEvent.CLICK, onCourseSettings);
					break;
			}
		}
		
		protected function onUnitSelected(event:IndexChangeEvent):void {
			unitSelect.dispatch(event.target.selectedItem);
		}
		
		private function onAddUnit(event:MouseEvent):void {
			// TODO: need to have the designs to know exactly how this will work but for now just use a random name.
			// Also this should use a notification and command instead of adding it directly to the collection.
			unitListCollection.addItem(<unit caption='New unit' />);
		}
		
		protected function onCourseSettings(event:MouseEvent):void {
			navigator.pushView(SettingsView); // this won't work because settings is in builder :(
		}
		
		/**
		 * TODO: Switch between editing and viewing
		 */
		protected override function getCurrentSkinState():String {
			return (_isPreviewVisible) ? "unitplayer" : "uniteditor";
		}

	}
}