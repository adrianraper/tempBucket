package com.clarityenglish.ielts.view.menu {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.MouseEvent;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class MenuMediator extends BentoMediator implements IMediator {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function MenuMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():MenuView {
			return viewComponent as MenuView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.courseSelected.add(onCourseSelected);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.courseSelected.remove(onCourseSelected);
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				
			}
		}
		
		private function onCourseSelected(course:String):void {
			log.info("Course selected: {0}", course);
		}
		
	}
}
