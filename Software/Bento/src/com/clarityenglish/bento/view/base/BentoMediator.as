package com.clarityenglish.bento.view.base {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.events.BentoEvent;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * Bento components (designed to automatically add and remove their associated mediators) should extend this class.
	 * It is *vital* that child classes do not override getMediatorName and let Bento take care of this automatically.
	 * 
	 * @author Dave Keen
	 */
	public class BentoMediator extends Mediator implements IMediator  {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * This is used to make sure that BBNotifications.XHTML_LOADED doesn't do anything if the Href is already loaded in this mediator
		 */
		private var currentlyLoadedHref:Href;
		
		public function BentoMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():BentoView {
			return viewComponent as BentoView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			// Add event listeners to the view
			view.addEventListener(BentoEvent.HREF_CHANGED, onHrefChanged);
		}
		
		protected function onXHTMLReady(xhtml:XHTML):void {
			
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			// Remove event listeners from the view
			view.removeEventListener(BentoEvent.HREF_CHANGED, onHrefChanged);
		}
		
		public override function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.XHTML_LOADED,
			]);
		}
		
		public override function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.XHTML_LOADED:
					// If the XHTML Href is the one in the view, and its not already loaded then set the xhtml in the view
					if (note.getBody().href === view.href && note.getBody().href !== currentlyLoadedHref) {
						view.xhtml = note.getBody().xhtml;
						currentlyLoadedHref = note.getBody().href;
						onXHTMLReady(note.getBody().xhtml);
					}
					
					break;
			}
		}
		
		/**
		 * When the href of this view is changed we need to refetch (or fetch for the first time) the XHTML that drives it
		 * 
		 * @param event
		 */
		protected function onHrefChanged(event:Event):void {
			sendNotification(BBNotifications.XHTML_LOAD, view.href);
		}
		
	}
}