package com.clarityenglish.controls.video.players {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.IVideoProvidable;
	import com.clarityenglish.controls.video.IVideoProvider;
	
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
			
		}
		
		public function set provider(value:IVideoProvider):void {
			_provider = value;
			_providerChanged = true;
			invalidateProperties();
		}
		
		public function set source(value:Object):void {
			log.info("Source set to " + value);
			_source = value;
			_sourceChanged = true;
			invalidateProperties();
		}
		
		public function get source():Object {
			return _source;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			
		}
		
		public function play():void {
			// TODO Auto-generated method stub
		}

		public function stop():void {
			// TODO Auto-generated method stub
		}
	}
}
