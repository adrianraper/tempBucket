package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	
	import mx.controls.SWFLoader;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.StringUtils;
	
	import spark.components.Image;
	
	public class OrchidWidget extends AbstractWidget {

		private var orchidConnection:LocalConnection;
		private var orchidReady:Boolean = false;
		
		[SkinPart(required="true")]
		public var fakeThumbnailImage:Image;
		
		[SkinPart(required="true")]
		public var orchidSWFLoader:SWFLoader;
		
		private var _courseID:String;
		private var _exerciseID:String;
		private var _contentUID:String;
		private var contentUIDChanged:Boolean;
		
		public function OrchidWidget() {
			super();
			
			orchidConnection = new LocalConnection();
			orchidConnection.client = this;
			orchidConnection.addEventListener(StatusEvent.STATUS, onStatus);
			orchidConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			try {
				orchidConnection.connect("OrchidResponse");
				log.debug("Connection setup for Orchid to use");
			} catch (error:ArgumentError) {
				log.debug("Connection name can't be used");
			}
		}
		
		public function onOrchidReady(success:Boolean):void {
			if (success) {
				orchidReady = true;
				log.debug("Orchid ready!");
			} else {
				log.debug("Orchid not ready for displayExercise command yet");
			}
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get src():String {
			return _xml.@src;
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get hasSrc():Boolean {
			return _xml.hasOwnProperty("@src");
		}
		
		[Bindable(event="contentuidAttrChanged")]
		public function get contentUID():String {
			return _xml.@contentuid;
		}
		
		public function setContentUID(value:String):void {
			_contentUID = value;
			contentUIDChanged = true;
			invalidateProperties();
		}
		
		public function get orchidUrl():String {
			if (hasSrc)
				return src;
			
			return null;
		}
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (contentUIDChanged) {
				var contentUIDArray:Array = _contentUID.split(".");
				changeContentuid(contentUIDArray[1], contentUIDArray[3]);
			}
		}
		
		protected function changeContentuid(courseID:String, exerciseID:String):void {		
			log.debug("Click to go to a different exercise please");
			
			if (orchidReady) {
				log.debug("Orchid do your thing");
				orchidConnection.send('OrchidCommand','displayExercise', courseID, exerciseID);
				//orchidSWFLoader.talkToMe();
			}
		}
		
		protected function onStatus(event:StatusEvent):void {
			switch (event.level) {
				case "status":
					log.debug("LocalConnection.send() succeeded");
					break;
				case "error":
					log.debug("LocalConnection.send() failed");
					break;
			}
		}
		protected function onSecurityError(event:SecurityErrorEvent):void {
			log.debug("LocalConnection security event " + event);
		}
		public function onReceiveCommand(success:Boolean):void {
			log.debug("LocalConnection, Orchid received our command=" + success);			
		}
		protected override function onRemovedFromStage(event:Event):void {
			try {
				orchidConnection.close();
			} catch (error:ArgumentError) {
				log.debug("LocalConnection can't be closed " + error);			
			}
		}
	}
}