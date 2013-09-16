package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.model.BentoProxy;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class WordClickCommand extends SimpleCommand {
		
		private static var dictionaryUrl:String = "http://dictionaries.cambridge.org/results.asp?searchword={{word}}&dict=L";
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoApplication:BentoApplication = FlexGlobals.topLevelApplication as BentoApplication;
			
			if (bentoApplication.isCtrlDown) {
				var word:String = note.getBody().toString();
				
				// Replace {{word}} with the actual word and open an external link
				var resolvedDictionaryUrl:String = dictionaryUrl.replace("{{word}}", word);
				navigateToURL(new URLRequest(resolvedDictionaryUrl), "_blank");
				
				// gh#378
				bentoApplication.isCtrlDown = false;
			}
		}
		
	}
	
}