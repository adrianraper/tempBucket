package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import mx.collections.IViewCursor;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.core.View;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class WidgetAddCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var xml:XML = note.getBody() as XML;
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			
			// This might not be the best place to do this (and in fact in the future this might not even be necessary), but for now we need to work out the y position
			// of the widget based on what is already there for #17.  This is all very naive, and doesn't take into account anything apart from column 0.  It also
			// necessitates putting the last recorded height of widgets in the XML which is very messy.  However, the layout code is all proof of concept until we
			// figure out exactly what we want so no point making it particularly elegant for the moment.
			xml.@ypos = 0;
			
			if (courseProxy.widgetCollection) {
				var cursor:IViewCursor = courseProxy.widgetCollection.createCursor();
				while (!cursor.afterLast) {
					var item:XML = cursor.current as XML;
					if (item.@column == 0) {
						xml.@ypos = Math.max(parseInt(xml.@ypos), parseInt(item.@ypos) + parseInt(item.@layoutheight) + 20);
					}
					cursor.moveNext();
				}
			} else {
				log.error("No widget collection");
			}
			
			// Finally add the widget
			courseProxy.widgetAdd(xml);
		}
		
	}
	
}