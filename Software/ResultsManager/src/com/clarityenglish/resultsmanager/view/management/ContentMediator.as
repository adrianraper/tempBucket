/*
 Mediator - PureMVC
 */
package com.clarityenglish.resultsmanager.view.management {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.Reportable;
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.common.vo.content.Exercise;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.resultsmanager.view.management.components.*;
	import com.clarityenglish.resultsmanager.view.management.events.ContentEvent;
	import com.clarityenglish.resultsmanager.view.management.events.ReportEvent;
	import com.clarityenglish.resultsmanager.view.shared.interfaces.ICheckBoxRendererProvider;
	import com.clarityenglish.utils.TraceUtils;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.davekeen.utils.ArrayUtils;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	//import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * A Mediator
	 */
	public class ContentMediator extends Mediator implements IMediator, ICheckBoxRendererProvider {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "ContentMediator";
		
		// The manageable selected in the manageable view - we need to know this to display the show/hide checkboxes in the
		// content tree
		private var selectedManageable:Manageable;
		
		public function ContentMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			contentView.addEventListener(ReportEvent.SHOW_REPORT_WINDOW, onShowReportWindow);
			// Choose to do this after COPY_LOADED
			//contentView.checkBoxRendererProvider = this;
			contentView.addEventListener(ContentEvent.EDIT_EXERCISE, onEditExercise);
			contentView.addEventListener(ContentEvent.DELETE_EXERCISE, onDeleteExercise);
			contentView.addEventListener(ContentEvent.RESET_CONTENT, onResetContent);
			contentView.addEventListener(ContentEvent.MOVE_CONTENT_AFTER, onMoveContent);
			contentView.addEventListener(ContentEvent.MOVE_CONTENT_BEFORE, onMoveContent);
			contentView.addEventListener(ContentEvent.INSERT_CONTENT_AFTER, onInsertContent);
			contentView.addEventListener(ContentEvent.INSERT_CONTENT_BEFORE, onInsertContent);
			contentView.addEventListener(ContentEvent.COPY_CONTENT_AFTER, onCopyContent);
			contentView.addEventListener(ContentEvent.COPY_CONTENT_BEFORE, onCopyContent);
			contentView.addEventListener(ContentEvent.CHECK_FOLDER, onCheckEditedContentFolder);
			
			// v3.4 For refreshing content
			contentView.addEventListener(ContentEvent.GET_CONTENT, onRefreshContent);

		}
		
		private function get contentView():ContentView {
			return viewComponent as ContentView;
		}

		/**
		 * Get the Mediator name.
		 * <P>
		 * Called by the framework to get the name of this
		 * mediator. If there is only one instance, we may
		 * define it in a constant and return it here. If
		 * there are multiple instances, this method must
		 * return the unique name of this instance.</P>
		 * 
		 * @return String the Mediator name
		 */
		override public function getMediatorName():String {
			return ContentMediator.NAME;
		}
        
		/**
		 * List all notifications this Mediator is interested in.
		 * <P>
		 * Automatically called by the framework when the mediator
		 * is registered with the view.</P>
		 * 
		 * @return Array the list of Nofitication names
		 */
		override public function listNotificationInterests():Array {
			return [
					CommonNotifications.LOGGED_OUT,
					RMNotifications.HIDDEN_CONTENT_LOADED,
					RMNotifications.EDITED_CONTENT_LOADED,
					RMNotifications.MANAGEABLE_SELECTED,
					CommonNotifications.COPY_LOADED,
					RMNotifications.CONTENT_LOADED,
					// v3.4 Add logged in so that you can trigger a request for content from the proxy
					CommonNotifications.LOGGED_IN,
				];
		}

		/**
		 * Handle all notifications this Mediator is interested in.
		 * <P>
		 * Called by the framework when a notification is sent that
		 * this mediator expressed an interest in when registered
		 * (see <code>listNotificationInterests</code>.</P>
		 * 
		 * @param INotification a notification 
		 */
		override public function handleNotification(note:INotification):void {
			//TraceUtils.myTrace("contentMediator:" + note.getName());
			switch (note.getName()) {
				//v3.4 Trigger getContent separately from the main proxy creation to try and asynch it a bit
				// Well, this works but it still gets bundled into the same call.
				// So trigger it on a short delay. Or could you be a little clever and delay based on the number of users
				// to give getAllManageables a chance to come back? 
				// The thing is, I don't really want to tie this directly to getAllManageables as I do that 
				// again at a later date.
				// Actually, getContent is very much quicker than getAllManageables, so perhaps that should go first
				// But then you can't do getHiddenContent until manageables have been got!				
				case CommonNotifications.LOGGED_IN:
					// v3.4 Added to let the content view know about the user type
					contentView.userType = Constants.userType;
					var data:Object = note.getBody();
					var numUsers:Number = data.manageablesCount as Number;
					TraceUtils.myTrace("contentMediator knows you have " + numUsers);
					// Is it worth doing a delay?
					// Could this be causing a session problem? yes, though no idea why
					//if (numUsers < 500 || (data.noStudents as Boolean)) {
						TraceUtils.myTrace("contentMediator no delay");
						notificationDelayContent(null);
					//} else {
					//	var littleDelay:Timer = new Timer(numUsers, 1);
					//	littleDelay.addEventListener(TimerEvent.TIMER_COMPLETE, notificationDelayContent);
					//	littleDelay.start();
					//}
					break;
				case CommonNotifications.LOGGED_OUT:
					contentView.tree.selectedItem = null;
					selectedManageable = null;
					break;
				case RMNotifications.HIDDEN_CONTENT_LOADED:
					contentView.tree.refreshItemRenderers();
					break;
				case RMNotifications.EDITED_CONTENT_LOADED:
					// This is currently just to make testing quicker.
					contentView.openTreeToLastPosition();
					// Map the edited content onto the original for the currently selected group
					var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
					contentProxy.mapEditedContentForGroup(selectedManageable as Group);
					contentView.tree.invalidateList();
					break;
				case RMNotifications.MANAGEABLE_SELECTED:
					//TraceUtils.myTrace("contentMediator handling manageable_selected");
					//MonsterDebugger.trace(this, "ContentMediator.MANAGEABLE_SELECTED");
					selectedManageables = note.getBody() as Array;
					break;
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					contentView.setCopyProvider(copyProvider);
					contentView.checkBoxRendererProvider = this as ICheckBoxRendererProvider;
					break;
				case RMNotifications.CONTENT_LOADED:
					var allTitles:Array =  note.getBody() as Array;
					var displayTitles:Array = [];
					var i:Number = 0;
					for each (var titleObj:Object in allTitles) {
					    if (titleObj.licenceType != Title.LICENCE_TYPE_AA) {
							displayTitles[i] = titleObj;
							i++
						}
				    }
					contentView.tree.dataProvider = displayTitles;
					//contentView.tree.dataProvider = note.getBody();
					// After loading content you won't need the refresh button any more
					contentView.refreshButton.visible = false;
					break;           
				default:
					break;		
			}
		}
		private function notificationDelayContent(e:TimerEvent):void {
			var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
			contentProxy.getContent();
		}
		
		private function onShowReportWindow(e:ReportEvent):void {
			sendNotification(RMNotifications.SHOW_REPORT_WINDOW, e);
		}

		// v3.4 Editing Clarity Content
		private function onEditExercise(e:ContentEvent):void {
			//MonsterDebugger.trace(this, e);
			sendNotification(RMNotifications.EDIT_EXERCISE, e);
		}
		private function onDeleteExercise(e:ContentEvent):void {
			sendNotification(RMNotifications.DELETE_EXERCISE, e);
		}
		private function onResetContent(e:ContentEvent):void {
			sendNotification(RMNotifications.RESET_CONTENT, e);
		}
		private function onMoveContent(e:ContentEvent):void {
			// If the notification has the same name as the event I can do this
			sendNotification(e.type, e);
		}
		private function onInsertContent(e:ContentEvent):void {
			// If the notification has the same name as the event I can do this
			sendNotification(e.type, e);
		}
		private function onCopyContent(e:ContentEvent):void {
			// If the notification has the same name as the event I can do this
			//MonsterDebugger.trace(this, "copyContent");
			sendNotification(e.type, e);
		}
		private function onCheckEditedContentFolder(e:ContentEvent):void {
			//MonsterDebugger.trace(this, "onCheckEditedContentFolder in content.meditator");
			sendNotification(RMNotifications.CHECK_FOLDER, e);
		}

		private function set selectedManageables(selectedManageables:Array):void {
			//MonsterDebugger.trace(this, selectedManageables);
			//MonsterDebugger.trace(this, selectedManageables);
			if (!selectedManageables || selectedManageables.length > 1) {
				selectedManageable = null;
			} else {
				selectedManageable = selectedManageables[0];
			}
			//TraceUtils.myTrace("selected manageable=" + (selectedManageable as Reportable).reportableLabel);
			// v3.4 At this point I want to see if we are dealing with editedContent. 
			// If we are, then before I redraw the content tree I want to change the enabledFlags to match editedContent.
			// Then I might also try and add extra rows in here.
			if (selectedManageable is Group) {
				var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
				
				// Before we go, reset the content tree to the original
				//contentView.tree.dataProvider = contentProxy.resetContent;
				contentProxy.mapEditedContentForGroup(selectedManageable as Group);
				// Can I force a full redraw to pick up new information from the dataProvider?
				// Or do I have to use a dataDescriptor?
				//contentView.tree.refreshItemRenderers();
				//contentView.tree.resetTree();
			}

			// Finally redraw the tree
			contentView.tree.invalidateList();
		}
		
		public function isCheckBoxEnabled(data:Object):Boolean {
			// v3.1 You don't want reporters to do any selecting with hidden content
			// though it would be nice if they could see it...
			// v3.4 This is failing even when I click a group. Due to ManageableCMManager
			return ((selectedManageable is Group) && (Constants.userType != User.USER_TYPE_REPORTER));
		}
		
		public function isCheckBoxSelected(data:Object):Boolean {
			// Disabled checkboxes are always unselected (it looks odd otherwise) 
			// v3.1 But maybe reporters can see anyway. No, this just blanks the whole item because it is keyed on selectedManageable.
			// If there is no selectedManageable we could default to the top level. If selectedManageable is a user, send parent group instead.
			if (!isCheckBoxEnabled(data)) return false;
			//if (isCheckBoxEnabled(data) || (Constants.userType == User.USER_TYPE_REPORTER)) {
			//} else {
			//	return false;
			//}
			
			// v3.4 What is this line all about?
			var reportable:Reportable = data as Reportable;
			
			var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
			return contentProxy.isContentVisible(data as Content, selectedManageable as Group);
		}
		// I don't think I will call this anymore
		/*
		public function isContentEdited(data:Object):Boolean {
			// v3.4 You can only edit exercises
			if (!data is Exercise) return false;
			
			var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
			return contentProxy.isContentEdited(data as Content, selectedManageable as Group);
		}
		*/
		public function onCheckBoxClick(data:Object, selected:Boolean):void {
			var content:Content = data as Content;
			// You only come here if the checkbox is enabled.

			sendNotification(RMNotifications.SET_CONTENT_VISIBLE, { content: content,
																	group: selectedManageable as Group,
																	visible: selected } );
			
			contentView.tree.invalidateList();
		}

		// v3.4 Refresh content
		private function onRefreshContent(e:ContentEvent):void {
			var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
			contentProxy.getContent();
		}

	}
}
