package com.clarityenglish.rotterdam.builder.view.filemanager {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.builder.view.filemanager.events.FileManagerEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	
	import org.davekeen.util.StringUtils;
	
	import spark.components.Button;
	import spark.components.List;
	
	public class FileManagerView extends BentoView {
		
		[SkinPart(required="true")]
		public var fileList:List;
		
		[SkinPart]
		public var selectButton:Button;
		
		[SkinPart]
		public var cancelButton:Button;
		
		private var fileListCollection:XMLListCollection;
		
		private var _typeFilter:Array;
		private var _typeFilterChanged:Boolean;
		
		private var _selectMode:Boolean;
		
		public function FileManagerView():void {
			super();
			
			fileListCollection = new XMLListCollection();
		}
		
		public function set typeFilter(value:Array):void {
			if (_typeFilter !== value) {
				_typeFilter = value;
				_typeFilterChanged = true;
				invalidateProperties();
			}
		}
		
		public function set selectMode(value:Boolean):void {
			if (_selectMode !== value) {
				_selectMode = value;
				invalidateSkinState();
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_typeFilterChanged) {
				if (_typeFilter) {
					// Build up a list of accepted extensions
					var extensions:Array = [];
					for each (var fileFilter:FileFilter in _typeFilter) {
						for each (var fileFilterExtension:String in fileFilter.extension.split(";")) {
							extensions.push(fileFilterExtension.split(".")[1]);
						}
					}
					
					// Create a filter function that only shows files with the appropriate extension
					fileListCollection.filterFunction = function(fileNode:XML):Boolean {
						for each (var extension:String in extensions) {
							if (StringUtils.endsWith(fileNode.@originalName, extension))
								return true;
						}
						return false;
					};
				} else {
					fileListCollection.filterFunction = null;
				}
				fileListCollection.refresh();
			}
		}

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			fileListCollection.source = xhtml.files.file;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case fileList:
					fileList.dataProvider = fileListCollection;
					break;
				case selectButton:
					selectButton.addEventListener(MouseEvent.CLICK, onSelect);
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancel);
					break;
			}
		}
		
		protected function onSelect(event:MouseEvent):void {
			if (fileList.selectedItem) {
				dispatchEvent(new FileManagerEvent(FileManagerEvent.FILE_SELECT, fileList.selectedItem, true));
				dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
			}
		}
		
		protected function onCancel(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected override function getCurrentSkinState():String {
			return (_selectMode) ? "select" : super.getCurrentSkinState();
		}
		
	}
}