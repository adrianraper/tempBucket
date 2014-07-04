package com.clarityenglish.rotterdam.view.unit.ui {
	
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayoutElement;
	import com.clarityenglish.rotterdam.view.unit.widgets.AbstractWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.AnimationWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.AudioWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ExerciseWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ImageWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.OrchidWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.PDFWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.VideoWidget;
	import com.googlecode.bindagetools.util.Util;
	
	import flash.display.DisplayObject;
	import flash.utils.*;
	
	import mx.core.ClassFactory;
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Group;
	
	public class UniversalWidget extends Group {
		
		protected var widgetClass:Class;
		
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		private var _src:String;
		private var _xml:XML;
		private var xmlChanged:Boolean;
		private var _index:Number = 0;
		private var indexChanged:Boolean;
		
		public function UniversalWidget() {
			super();
		}
		
		public function set xml(value:XML):void {
			_xml = value;
			xmlChanged = true;
			invalidateProperties();
		}
		
		public function set index(value:Number):void {
			_index = value;
			indexChanged = true;
			invalidateProperties();
		}
		
		protected function typeToWidgetClass(type:String):Class {
			switch (type) {
				case "pdf":
					return PDFWidget;
				case "video":
					return VideoWidget;
				case "image":
					return ImageWidget;
				case "audio":
					return AudioWidget;
				case "exercise":
					return ExerciseWidget;
				case "animation":
					return AnimationWidget;
				case "orchid":
					return OrchidWidget;
				default:
					log.error("Unsupported widget type " + type);
					return null;
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (xmlChanged || indexChanged) {
				widgetClass = typeToWidgetClass(_xml.exercise[_index].@type);
				
				if (this.numElements == 0 || _xml.exercise[_index].@type != "orchid") {
					this.removeAllElements();
					var classFactory:ClassFactory = new ClassFactory(widgetClass);
					classFactory.properties = { xml: _xml.exercise[_index], editable: false, widgetCaptionChanged: true};
					addElement(classFactory.newInstance());
				} else {
					var orchidWidget:OrchidWidget = this.getElementAt(0) as OrchidWidget;
					orchidWidget.setContentUID(_xml.exercise[_index].@contentuid);
				}
				
				xmlChanged = false;
				indexChanged = false;
			} 
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var element:ILayoutElement = this.getElementAt(0);
			
			if (element is IUnitLayoutElement) {
				var currentElement:IUnitLayoutElement = this.getElementAt(0) as IUnitLayoutElement;
				
				currentElement.setLayoutBoundsSize(width, NaN);
				
				// #17 - this is somewhat hacky, but set the current height of the element in the XML so that WidgetAddCommand can figure out
				// where to put new widgets.  When widget layout is figured out properly this will definitely go.
				currentElement.layoutheight = currentElement.getLayoutBoundsHeight();
			}
		}
	}
}