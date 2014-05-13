package com.clarityenglish.rotterdam.builder.controller.widgets {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.controls.video.UniversalVideoPlayer;
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
			
			var src:String = note.getBody().url;
			
			// Confirm that the video player can handle this source
			if (!UniversalVideoPlayer.canHandleSource(src)) {
				log.error("No provider for video source " + src);
				var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
				facade.sendNotification(RotterdamNotifications.VIDEO_LOAD_ERROR, copyProxy.getBentoErrorForId("errorVideoLoad", { href: src }, false));
				return;
			}
			
			var node:XML;
			if (note.getBody().node) {
				node = note.getBody().node;
			} else {
				node = <exercise type="video" column="0" span="2" caption="Video"><text></text></exercise>;
				facade.sendNotification(RotterdamNotifications.WIDGET_ADD, node);
			}
			
			// gh#875
			node.@src = UniversalVideoPlayer.providerForSource(src);
		}
		
	}
	
}