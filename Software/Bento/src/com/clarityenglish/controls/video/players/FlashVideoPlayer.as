package com.clarityenglish.controls.video.players {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.IVideoProvidable;
	import com.clarityenglish.controls.video.IVideoProvider;
	
	import flash.events.Event;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Group;
	
	public class FlashVideoPlayer extends Group implements IVideoPlayer, IVideoProvidable {
		
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		protected var _provider:IVideoProvider;
		protected var _providerChanged:Boolean;
		
		protected var _source:Object;
		protected var _sourceChanged:Boolean;
		
		public function FlashVideoPlayer() {
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			if (_provider) _provider.destroy();
		}

		public function set provider(value:IVideoProvider):void {
			// If a provider already exists then give it an opportunity to clean up
			if (_provider) _provider.destroy();
			
			_provider = value;
			_providerChanged = true;
			invalidateProperties();
		}
		
		public function set source(value:Object):void {
			log.info("Source set to " + value);
			_source = value;
			_sourceChanged = true;
			
			// Create the component
			_provider.create(source);
			
			invalidateProperties();
		}
		
		public function get source():Object {
			return _source;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (_provider) _provider.resize();
		}
		
		public function play():void {
			if (_provider) _provider.play();
		}

		public function stop():void {
			if (_provider) _provider.stop();
		}
		
	}
}
