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
	import spark.components.Panel;
	import spark.components.gridClasses.GridColumn;
	
	public class FileManagerView extends BentoView {
		
		[SkinPart]
		public var resourseCloudLabel:Label;
		
		[SkinPart(required="true")]
		public var fileList:spark.components.DataGrid;
		
		[SkinPart]
		public var nameGridColumn:GridColumn;
		
		[SkinPart]
		public var sizeGridColumn:GridColumn;
		
		[SkinPart]
		public var settingPanel:Panel;
		
		[SkinPart]
		public var selectButton:Button;
		
		[SkinPart]
		public var cancelButton:Button;
		
		[SkinPart]
		public var pdfFilesLabel:Label;
		
		[SkinPart]
		public var imageFilesLabel:Label;
		
		[SkinPart]
		public var audioFilesLabel:Label;

		public var pdfFilesTotal:Label;
		

		public var imageFilesTotal:Label;
		

		public var audioFilesTotal:Label;
		
		[SkinPart]
		public var emptyFileLabel:Label;
		
		[Bindable]
		private var fileListCollection:XMLListCollection;
		private var _pieChartCollection:ArrayCollection;
		
		private var _typeFilter:Array;
		private var _typeFilterChanged:Boolean;
		
		private var _selectMode:Boolean;
		//gh158
		private var _popUpMode:Boolean;
		
		private var _totalPDF:Number = 0;
		private var _totalImage:Number = 0;
		private var _totalAudio:Number = 0;
		private  var _totalFile:Number = 0;
		
		[Bindable]
		public var textPDF:String;
		[Bindable]
		public var textImage:String;
		[Bindable]
		public var textAudio:String;
		
		public function FileManagerView():void {
			super();
			
			fileListCollection = new XMLListCollection();
			_pieChartCollection = new ArrayCollection();
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
		
		public function set popUpMode(value:Boolean):void {
			if (_popUpMode !== value) {
				_popUpMode = value;
			}
		}
		
		public function get pieChartCollection():ArrayCollection {
			return _pieChartCollection;
		}
		
		[Bindable]
		public function set totalFile(value:Number):void {
			_totalFile = value;
		}
		public function get totalFile():Number {
			return _totalFile;
		}
		
		[Bindable]
		public function set totalPDF(value:Number):void {
			_totalPDF = value;
		}
		public function get totalPDF():Number {
			return _totalPDF;
		}
		
		[Bindable]
		public function set totalImage(value:Number):void {
			_totalImage = value;
		}
		public function get totalImage():Number {
			return _totalImage;
		}
		
		[Bindable]
		public function set totalAudio(value:Number):void {
			_totalAudio = value;
		}
		public function get totalAudio():Number {
			return _totalAudio;
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
							// gh#332
							var originalName:String = fileNode.@originalName;
							if (StringUtils.endsWith(originalName.toLowerCase(), extension))
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

			for each (var file:XML in fileListCollection) {
				var fileType:String = file.@mimeType;
				if (fileType.search("pdf") > 0) {
					_totalPDF ++;
				}
				if (fileType.search("image") == 0) {
					_totalImage ++;
				}
				if (fileType.search("octet-stream") > 0) {
					_totalAudio ++;
				}
			}
			this.totalFile = fileListCollection.length;
			_pieChartCollection.addItem({type: "PDF", total: _totalPDF});
			_pieChartCollection.addItem({type: "Image", total: _totalImage});
			_pieChartCollection.addItem({type: "Audio", total: _totalAudio});
			
			if (totalPDF == 0) {
				textPDF = "0%";
			} else {
				textPDF = Math.round((_totalPDF/_totalFile)*100).toString()+ "%";
			}
			
			if (totalImage == 0) {
				textImage = "0%";
			} else {
				textImage = Math.round((_totalImage/_totalFile)*100).toString()+ "%";
			}
			
			if (totalAudio == 0) {
				textAudio = "0%";
			} else {
				textAudio = Math.round((_totalAudio/_totalFile)*100).toString()+ "%";
			}			
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case resourseCloudLabel:
					resourseCloudLabel.text = copyProvider.getCopyForId("resourseCloudLabel");
					break;
				case fileList:
					fileList.dataProvider = fileListCollection;
					fileList.addEventListener(MouseEvent.CLICK, onSelectItem);
					break;
				case nameGridColumn:
					nameGridColumn.headerText = copyProvider.getCopyForId("nameGridColumn");
					break;
				case sizeGridColumn:
					sizeGridColumn.headerText = copyProvider.getCopyForId("sizeGridColumn");
					break;
				case settingPanel:
					settingPanel.title = copyProvider.getCopyForId("settingPanel");
					break;
				case selectButton:
					selectButton.addEventListener(MouseEvent.CLICK, onSelect);
					selectButton.label = copyProvider.getCopyForId("selectButton");
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancel);
					cancelButton.label = copyProvider.getCopyForId("cancelButton");
					break;
				case emptyFileLabel:
					if (this.getCurrentSkinState() == "normal"){
						emptyFileLabel.text = copyProvider.getCopyForId("emptyFileLabel");
					} else {
						emptyFileLabel.text = copyProvider.getCopyForId("emptyFileLabel2");
					}					
					break;
				case pdfFilesLabel:
					pdfFilesLabel.text = copyProvider.getCopyForId("pdfFilesLabel");
					break;
				case imageFilesLabel:
					imageFilesLabel.text = copyProvider.getCopyForId("imageFilesLabel");
					break;
				case audioFilesLabel:
					audioFilesLabel.text = copyProvider.getCopyForId("audioFilesLabel");
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
			//gh #212
			dispatchEvent(new FileManagerEvent(FileManagerEvent.FILE_CANCEL, null, true));
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onSelectItem (event:MouseEvent):void {
			this.selectMode = true;
		}
		
		protected override function getCurrentSkinState():String {
			//gh#158
			if (_selectMode == true) {
				if (_popUpMode == true) {
					return "select";
				}
			} 
			return super.getCurrentSkinState();
			//return (_selectMode) ? "select" : super.getCurrentSkinState();
		}
		
	}
}