package com.clarityenglish.rotterdam.builder.controller.widgets {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class VideoWidgetAddCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note)
			
			var rawSrc:String = note.getBody().url;
			
			// gh#64
			var type:String = note.getBody().type;
			switch (type) {
				case 'youtube':
					// The current YouTube video link looks like
					//   http://youtu.be/oSn3i4vsGeY
					// others look like
					//   http://www.youtube.com/embed/xxx?rel=0
					// or 
					//   http://www.youtube.com/v/xxx?version=3
					
					// Just for reference, you can get a still shot of the video from http://img.youtube.com/vi/xxx/0.jpg
					/*
					pattern from http://stackoverflow.com/questions/2936467/parse-youtube-video-id-using-preg-match
					*/
					var youtubePattern:RegExp = /(?:youtube(?:-nocookie)?\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|(?:youtu\.be\/))([^"&?\/ ]{11})/i;
					var matches:Array = rawSrc.match(youtubePattern);
					if (matches && matches.length == 2) {
						var src:String = 'http://www.youtube.com/v/' + matches[1] + '?version=3';
						
					} else {
						log.error("Can't parse video ID from " + rawSrc);
						var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
						facade.sendNotification(RotterdamNotifications.VIDEO_LOAD_ERROR, copyProxy.getBentoErrorForId("errorVideoLoad", { href: rawSrc }));
						return;
					}
					break;
			
				default:
					log.error("Unknown video type " + type);
					copyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
					facade.sendNotification(RotterdamNotifications.VIDEO_LOAD_ERROR, copyProxy.getBentoErrorForId("errorVideoLoad", { href: rawSrc }));
					return;
			}
			
			var node:XML;
			if (note.getBody().node) {
				node = note.getBody().node;
			} else {
				node = <exercise type="video" column="0" span="2" caption="Video"><text></text></exercise>;
				facade.sendNotification(RotterdamNotifications.WIDGET_ADD, node);
			}
			
			node.@src = src;
		}
		
	}
	
}