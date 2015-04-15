/*
 Mediator - PureMVC
 */
package com.clarityenglish.resultsmanager.view.management {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.controller.ImportManageablesCommand;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.resultsmanager.model.ManageableProxy;
	import com.clarityenglish.resultsmanager.model.ReportProxy;
	import com.clarityenglish.resultsmanager.model.UploadProxy;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.view.management.events.ExtraGroupsEvent;
	import com.clarityenglish.resultsmanager.view.management.events.ManageableEvent;
	import com.clarityenglish.resultsmanager.view.management.events.ReportEvent;
	import com.clarityenglish.resultsmanager.view.management.events.ContentEvent;
	import com.clarityenglish.common.events.SearchEvent;
	import com.clarityenglish.resultsmanager.view.shared.events.LogEvent;
	import com.clarityenglish.resultsmanager.view.shared.events.SelectEvent;
	import com.clarityenglish.resultsmanager.vo.manageable.Group;
	import com.clarityenglish.resultsmanager.vo.manageable.Manageable;
	import com.clarityenglish.resultsmanager.vo.manageable.User;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.net.FileReference;
	import mx.collections.ICollectionView;
	import mx.controls.Alert;
	import mx.events.PropertyChangeEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.clarityenglish.resultsmanager.view.management.components.*;
	import com.clarityenglish.resultsmanager.view.management.*;
	import com.clarityenglish.utils.TraceUtils;
	//import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * A Mediator
	 */
	public class ManageablesMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "ManageablesMediator";
		
		private var filterDataDescriptor:FilterDataDescriptor;
		
		private var beforeSearchOpenItems:Object;
		
		public function ManageablesMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
			
			filterDataDescriptor = new FilterDataDescriptor();
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			manageablesView.addEventListener(ManageableEvent.ADD_GROUP, onAddGroup);
			manageablesView.addEventListener(ManageableEvent.ADD_USER, onAddUser);
			manageablesView.addEventListener(ManageableEvent.UPDATE_GROUPS, onUpdateGroups);
			manageablesView.addEventListener(ManageableEvent.UPDATE_USERS, onUpdateUsers);
			manageablesView.addEventListener(ManageableEvent.DELETE, onDelete);
			manageablesView.addEventListener(ManageableEvent.MOVE_MANAGEABLES, onMoveManageables);
			manageablesView.addEventListener(ManageableEvent.EXPORT, onExport);
			manageablesView.addEventListener(ManageableEvent.ARCHIVE, onArchive);
			manageablesView.addEventListener(ManageableEvent.IMPORT, onImport);
			// v3.6.1 Allow moving as well as importing
			// gh#653
			manageablesView.addEventListener(ManageableEvent.IMPORT_FROM_EXCEL, onImportFromExcel);
			manageablesView.addEventListener(ManageableEvent.IMPORT_FROM_EXCEL_WITH_MOVE, onImportFromExcel);
			manageablesView.addEventListener(ManageableEvent.IMPORT_FROM_EXCEL_WITH_COPY, onImportFromExcel);
			manageablesView.addEventListener(ManageableEvent.GET_EXTRA_GROUPS, onGetExtraGroups);
			manageablesView.addEventListener(ExtraGroupsEvent.SET_EXTRA_GROUPS, onSetExtraGroups);
			manageablesView.addEventListener(SearchEvent.SEARCH, onSearch);
			manageablesView.addEventListener(SearchEvent.CLEAR_SEARCH, onClearSearch);
			manageablesView.addEventListener(ReportEvent.SHOW_REPORT_WINDOW, onShowReportWindow);
			manageablesView.addEventListener(SelectEvent.EXPIRED_USERS, onSelectExpiredUsers);
			manageablesView.addEventListener(ContentEvent.CHECK_FOLDER, onCheckEditingContentFolder);
			manageablesView.addEventListener(ContentEvent.RESET_CONTENT, onResetEditingContentFolder);
			
			manageablesView.addEventListener(LogEvent.ERROR, onLog);
			
			manageablesView.addEventListener(Event.CHANGE, onChange);
		}
		
		private function get manageablesView():ManageablesView {
			return viewComponent as ManageablesView;
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
			return ManageablesMediator.NAME;
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
					RMNotifications.EXTRA_GROUPS_LOADED,
					RMNotifications.XML_IMPORTED,
					CommonNotifications.LOGGED_IN,
					CommonNotifications.COPY_LOADED,
					RMNotifications.MANAGEABLES_LOADED,
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
			//MonsterDebugger.trace(this, "man:" + note.getName());
			switch (note.getName()) {
				case CommonNotifications.LOGGED_OUT:
					manageablesView.tree.resetTree();
					
					// Fake a click on 'Clear Search' when logging out
					manageablesView.onClearSearchSelect(null);
					onClearSearch(null);
					break;
				case RMNotifications.EXTRA_GROUPS_LOADED:
					manageablesView.setExtraGroupsResults(note.getBody() as Array);
					break;
				case RMNotifications.XML_IMPORTED:
					//// TraceUtils.myTrace("manageablesMediator.setImportResults");
					manageablesView.setImportResults(note.getBody() as Array);
					break;
				case CommonNotifications.LOGGED_IN:
					var uploadProxy:UploadProxy = facade.retrieveProxy(UploadProxy.NAME) as UploadProxy;
					manageablesView.setFileReference(uploadProxy.fileReference);
					//v3.4 Trigger getAllManageables separately from the main proxy creation to try and asynch it a bit
					// This adds the complication that you can't do getHiddenContent until manageables AND content are in.
					//var littleDelay:Timer = new Timer(1000, 1);
					//littleDelay.addEventListener(TimerEvent.TIMER_COMPLETE, notificationDelayGetAllManageables);
					//littleDelay.start();
					break;
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					manageablesView.setCopyProvider(copyProvider);
					break;
				case RMNotifications.MANAGEABLES_LOADED:
					//MonsterDebugger.trace(this, note.getBody());
					manageablesView.setTreeDataProvider(note.getBody());
					manageablesView.setTreeDataDescriptor(filterDataDescriptor);
					// v3.4 Can I also select the top level group to kick things off?
					// Not like this. And I wouldn't want to here because I quite often want to reload manageables.
					//manageablesView.tree.selectedItem = 0;
					// How about basing it on the currently selected item?
					// If you do it here, you end up screwing the tree, I guess because you don't have editedContent, or something
					//if (manageablesView.tree.selectedIndex<0)
					//	manageablesView.selectTopGroup();
					break;
				case RMNotifications.HIDDEN_CONTENT_LOADED:
					// When the hidden content has loaded invalidate the tree so that the icons are updated
					manageablesView.invalidateTree();
					// For some bizarre reason I can't pick up this notification. For now use hidden content, but edited would be better.
					//break;
				//case RMNotifications.EDITED_CONTENT_LOADED:
					// see above for initial selection of the top group - this notification seems safer
					if (manageablesView.tree.selectedIndex<0)
						manageablesView.selectTopGroup();
					break;
				default:
					break;
			}
		}
		private function notificationDelayGetAllManageables(e:TimerEvent):void {
			var manageablesProxy:ManageableProxy = facade.retrieveProxy(ManageableProxy.NAME) as ManageableProxy;
			manageablesProxy.getAllManageables();
		}
				
		private function onAddGroup(e:ManageableEvent):void {
			sendNotification(RMNotifications.ADD_GROUP, e);
		}
		
		private function onAddUser(e:ManageableEvent):void {
			sendNotification(RMNotifications.ADD_USER, e);
		}
		
		private function onDelete(e:ManageableEvent):void {
			sendNotification(RMNotifications.DELETE_MANAGEABLES, e);
		}
		
		private function onUpdateGroups(e:ManageableEvent):void {
			sendNotification(RMNotifications.UPDATE_GROUPS, e);
		}
		
		private function onUpdateUsers(e:ManageableEvent):void {
			sendNotification(RMNotifications.UPDATE_USERS, e);
		}
		
		private function onMoveManageables(e:ManageableEvent):void {
			//// TraceUtils.myTrace("manageablesMediator onMoveManageables");
			sendNotification(RMNotifications.MOVE_MANAGEABLES, e);
		}
		
		private function onExport(e:ManageableEvent):void {
			sendNotification(RMNotifications.EXPORT_MANAGEABLES, e);
		}
		
		private function onArchive(e:ManageableEvent):void {
			sendNotification(RMNotifications.ARCHIVE_MANAGEABLES, e);
		}
		
		private function onImport(e:ManageableEvent):void {
			sendNotification(RMNotifications.UPLOAD_XML, { completeNotification: RMNotifications.IMPORT_MANAGEABLES, completeBody: e.parentGroup, completeType: ImportManageablesCommand.XML_IMPORT } );
		}
		
		// gh#653 Different options for import when duplicates found
		private function onImportFromExcel(e:ManageableEvent):void {
			var body:Object = e.manageables;
			body.parentGroup = e.parentGroup;
			
			sendNotification(RMNotifications.IMPORT_MANAGEABLES, body, e.type);
		}
		
		private function onGetExtraGroups(e:ManageableEvent):void {
			// Since this has no side-effects we can access the proxy directly instead of going through a command
			var manageablesProxy:ManageableProxy = facade.retrieveProxy(ManageableProxy.NAME) as ManageableProxy;
			manageablesProxy.getExtraGroups(e.manageable as User);
		}
		
		private function onSetExtraGroups(e:ExtraGroupsEvent):void {
			sendNotification(RMNotifications.SET_EXTRA_GROUPS, e);
		}
		
		private function onSearch(e:SearchEvent):void {
			filterDataDescriptor.setSearch(e);
			beforeSearchOpenItems = manageablesView.tree.openItems;
			
			// Expand all (from the selected item?)
			manageablesView.tree.expandAllFrom(manageablesView.tree.selectedItem);
			//manageablesView.tree.expandAll();
		}
		
		public function onClearSearch(e:SearchEvent):void {
			filterDataDescriptor.setSearch(null);
			manageablesView.tree.openItems = beforeSearchOpenItems;
		}
		
		private function onCheckEditingContentFolder(e:ContentEvent):void {
			//MonsterDebugger.trace(this, "onCheckEditingContentFolder in Man.mediator");
			// You do this through a command rather than direct to the proxy as it changes stuff outside the program
			sendNotification(RMNotifications.CHECK_FOLDER, e);
		}
		private function onResetEditingContentFolder(e:ContentEvent):void {
			//MonsterDebugger.trace(this, "onCheckEditingContentFolder in Man.mediator");
			// You do this through a command rather than direct to the proxy as it changes stuff outside the program
			sendNotification(RMNotifications.RESET_CONTENT, e);
		}
		
		private function onSelectExpiredUsers(e:SelectEvent):void {
			//MonsterDebugger.trace(this, "onSelectExpiredUsers in Man.mediator");
			var manageablesProxy:ManageableProxy = facade.retrieveProxy(ManageableProxy.NAME) as ManageableProxy;
			
			var expiredUsers:Array = manageablesProxy.getExpiredUsers(e.manageables);
			
			if (expiredUsers.length > 0) {
				// Make the tree open to show the selected items
				var openItems:Array = new Array();
				for each (var manageable:Manageable in expiredUsers) {
					do {
						openItems.push(manageable.parent);
						manageable = manageable.parent as Manageable;
					} while (manageable);
				}
				
				manageablesView.tree.openItems = openItems;
				
				manageablesView.tree.callLater(function():void { manageablesView.setSelectedItems(expiredUsers); } );
			} else {
				manageablesView.showNoExpiredUsersAlert();
			}
		}
		
		private function onShowReportWindow(e:ReportEvent):void {
			sendNotification(RMNotifications.SHOW_REPORT_WINDOW, e);
		}
		
		private function onLog(e:LogEvent):void {
			switch (e.type) {
				case LogEvent.NOTICE:
					sendNotification(CommonNotifications.TRACE_NOTICE, e.message);
					break;
				case LogEvent.WARNING:
					sendNotification(CommonNotifications.TRACE_WARNING, e.message);
					break;
				case LogEvent.ERROR:
					sendNotification(CommonNotifications.TRACE_ERROR, e.message);
					break;
			}
		}
		
		private function onChange(e:Event):void {
			//// TraceUtils.myTrace("manageablesMediator send MANAGEABLE_SELECTED");
			//MonsterDebugger.trace(this, "mediator.onChange");
			//MonsterDebugger.trace(this, manageablesView.tree.selectedIndex);
			sendNotification(RMNotifications.MANAGEABLE_SELECTED, manageablesView.getSelectedManageables());
		}

	}
}

import com.clarityenglish.common.events.SearchEvent;
import com.clarityenglish.resultsmanager.vo.manageable.Group;
import com.clarityenglish.resultsmanager.vo.manageable.Manageable;
import com.clarityenglish.resultsmanager.vo.manageable.User;
import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.ListCollectionView;
import mx.controls.treeClasses.DefaultDataDescriptor;
import com.clarityenglish.utils.TraceUtils;

class FilterDataDescriptor extends DefaultDataDescriptor {
	
	private var searchEvent:SearchEvent;
	
	public function FilterDataDescriptor() {
		super();
	}
	
	public function setSearch(searchEvent:SearchEvent):void {
		this.searchEvent = searchEvent;
	}
	
	/**
	 * Filter the tree dataprovider to only show nodes that don't have @visible=false
	 * 
	 * @param	node
	 * @param	model
	 * @return
	 */
	override public function getChildren(node:Object, model:Object = null):ICollectionView {
		//// TraceUtils.myTrace("getChildren for " + node.name);
		if (node is User) {
			// A user never has any children
			return null;
		} else {
			if (!searchEvent) {
				// If we are not filtering then just return all children
				return new ArrayCollection(node.children);
			} else {
				// If we are filtering then we need to test each child against the conditions in the search event and only add it if
				// it satisfies all the conditions
				var arrayCollection:ArrayCollection = new ArrayCollection();
				
				for each (var child:Manageable in node.children) {
					if (child is Group) {
						// Groups are never filtered
						// v3.4 Except that I would like to hide groups that have no children
						// This works but takes far too long for a school like Scipo
						//// TraceUtils.myTrace("group is " + child.name);
						//if (hasChildren(child)) {
						// These don't work
						//if ((child as Group).manageables.length>0) {
						//if ((child as Group).userCount>0) {
							arrayCollection.addItem(child);
						//}
					} else {
						// Actually do the search validation
						var user:User = child as User;
						if (searchEvent.validateObject(user)) {
							arrayCollection.addItem(user);
							//// TraceUtils.myTrace("found user=" + user.name);
						}
					}
				}
				// Putting this in seems to give an infinite loop
				//if (arrayCollection.length==0 ) {
				//	// I want to remove this node from the tree
				//	// TraceUtils.myTrace("empty node=" + node.name);
				//	//removeChildAt(getParent(node);
				//}
			}
			
			return arrayCollection;
		}
	}
	
	/**
	 * Branches are determined on the basis of whether there are any children.
	 * 
	 * @param	node
	 * @param	model
	 * @return
	 */
	override public function isBranch(node:Object, model:Object = null):Boolean {
		return (node is Group);
	}
	
}