package com.clarityenglish.rotterdam.builder.view.filemanager {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.builder.view.filemanager.events.FileManagerEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.controls.DataGrid;
	import mx.events.CloseEvent;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.Label;
	import spark.components.List;
	
	public class FileManagerView extends BentoView {
		
		[SkinPart(required="true")]
		public var fileList:spark.components.DataGrid;
		
		[SkinPart]
		public var selectButton:Button;
		
		[SkinPart]
		public var cancelButton:Button;
		
		[SkinPart]
		public var PDFFilesTotal:Label;
		
		[SkinPart]
		public var ImageFilesTotal:Label;
		
		[SkinPart]
		public var AudioFilesTotal:Label;
		
		private var fileListCollection:XMLListCollection;
		private var _piechartCollection:ArrayCollection;
		
		private var _typeFilter:Array;
		private var _typeFilterChanged:Boolean;
		
		private var _selectMode:Boolean;
		
		private var totalPDF:Number;
		private var totalImage:Number;
		private var totalAudio:Number;
		private var totalFile:Number;
		
		public function FileManagerView():void {
			super();
			
			fileListCollection = new XMLListCollection();
			_piechartCollection = new ArrayCollection();
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
		
		public function get piechartCollection():ArrayCollection {
			return _piechartCollection;
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
			
			PDFFilesTotal.text = Math.round((totalPDF/totalFile)*100).toString()+ "%";
			ImageFilesTotal.text =  Math.round((totalImage/totalFile)*100).toString()+ "%";
			AudioFilesTotal.text = Math.round((totalAudio/totalFile)*100).toString()+ "%";
			
		}

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			fileListCollection.source = xhtml.files.file;
			
			totalPDF = 0;
			totalImage = 0;
			totalAudio = 0;
			for each (var file:XML in fileListCollection) {
				var fileType:String = file.@mimeType;
				if (fileType.search("pdf") > 0) {
					totalPDF ++;
				}
				if (fileType.search("image") == 0) {
					totalImage ++;
				}
				if (fileType.search("octet-stream") > 0) {
					totalAudio ++;
				}
			}
			totalFile = fileListCollection.length;
			_piechartCollection.addItem({type: "PDF", total: totalPDF});
			_piechartCollection.addItem({type: "Image", total: totalImage});
			_piechartCollection.addItem({type: "Audio", total: totalAudio});
			
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case fileList:
					fileList.dataProvider = fileListCollection;
					fileList.addEventListener(MouseEvent.CLICK, onSelectItem);
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
				dispatchEvent(new FileManagerEvent(FileManagerEvent.FILE_SELECT, fileList.selectedItem as XML, true));
				dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
			}
		}
		
		protected function onCancel(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onSelectItem (event:MouseEvent):void {
			this.selectMode = true;
		}
		
		protected override function getCurrentSkinState():String {
			return (_selectMode) ? "select" : super.getCurrentSkinState();
		}
		
	}
}