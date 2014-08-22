package com.clarityenglish.rotterdam.builder.view.uniteditor.ui {
	
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.AuthoringEvent;
	
	import flash.events.MouseEvent;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Button;
	import spark.components.TitleWindow;
	
	public class TitleSettingsWindow extends TitleWindow {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function TitleSettingsWindow(){
			super();
		}

		[SkinPart (required="false")]
		public var settingsButton:Button;
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			if (instance == settingsButton)
				instance.addEventListener(MouseEvent.CLICK, onSettingsButtonClick);
		}
		
		override protected function partRemoved(partName:String, instance:Object): void {
			super.partRemoved(partName, instance);
		}
		
		protected function onSettingsButtonClick(event:MouseEvent):void {
			dispatchEvent(new AuthoringEvent(AuthoringEvent.OPEN_SETTINGS, true));
		}
	}
}