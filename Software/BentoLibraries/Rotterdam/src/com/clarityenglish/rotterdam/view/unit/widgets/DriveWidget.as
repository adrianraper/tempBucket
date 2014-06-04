package com.clarityenglish.rotterdam.view.unit.widgets {
	import flash.events.MouseEvent;
	
	import org.davekeen.util.StringUtils;
	
	import spark.components.Image;
	
	public class DriveWidget extends AbstractWidget {
		
		[SkinPart(required="true")]
		public var thumbnailImage:Image;
		
		public function DriveWidget() {
			super();
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get src():String {
			return _xml.@src;
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get hasSrc():Boolean {
			return _xml.hasOwnProperty("@src");
		}
		
		// gh#679
		[Bindable(event="permissionProviderAttrChanged")]
		public function get permissionProvider():String {
			return _xml.@permissionProvider;
		}
		
		[Bindable(event="permissionAttrChanged")]
		public function get hasPermission():Boolean {
			return _xml.hasOwnProperty("@permission");
		}
		
		[Bindable(event="permissionAttrChanged")]
		public function get permission():String {
			return _xml.@permission;
		}
		
		// gh#679 perhaps this should be in AbstractWidget as permission could apply to other widgets
		public function set permission(token:String):void {
			_xml.@permission = token;
		}
		
		[Bindable(event="permissionAttrChanged")]
		public function get permissionToken():String {
			return (hasPermission) ? permission : '';
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case thumbnailImage:
					thumbnailImage.buttonMode = true;
					thumbnailImage.addEventListener(MouseEvent.CLICK, onDriveImageClick);
					
					// gh#679 Sure this is not the right place to do it
					getPermission.dispatch(xml, permissionProvider);
					break;
			}
		}
		
		protected function onDriveImageClick(event:MouseEvent):void {
			if (hasSrc) {
				// gh#679 Get an attribute of this file from Google Drive 
				openMedia.dispatch(xml, src);
			} else {
				log.error("The user managed to click on a Drive link when no src attribute was set");
			}
		}
		
	}
}
