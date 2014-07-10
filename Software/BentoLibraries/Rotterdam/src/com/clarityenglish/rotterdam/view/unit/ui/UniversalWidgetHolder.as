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
	
	public class UniversalWidgetHolder extends Group {
		
		protected var widgetClass:Class;
		
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		private var _exercise:XML;
		private var _exerciseChanged:Boolean;
		
		public function UniversalWidgetHolder() {
			super();
		}
		
		public function set exercise(value:XML):void {
			_exercise = value;
			_exerciseChanged = true;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_exerciseChanged) {
				widgetClass = AbstractWidget.typeToWidgetClass(_exercise.@type);
				if (!widgetClass)
					log.error("Unsupported widget type " + _exercise.@type);
				
				// for orchid widget, we want to reuse the loaded swf, so if we won't add a new element in container
				if (this.numElements == 0 || _exercise.@type != "orchid") {
					this.removeAllElements();
					var classFactory:ClassFactory = new ClassFactory(widgetClass);
					classFactory.properties = { xml: _exercise, editable: false, widgetCaptionChanged: true};
					addElement(classFactory.newInstance());
				} else {
					var orchidWidget:OrchidWidget = this.getElementAt(0) as OrchidWidget;
					orchidWidget.setContentUID(_exercise.@contentuid);
				}
				
				_exerciseChanged = false;
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