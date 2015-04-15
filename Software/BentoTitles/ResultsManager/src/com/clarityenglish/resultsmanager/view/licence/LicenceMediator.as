/*
 Mediator - PureMVC
 */
package com.clarityenglish.resultsmanager.view.licence {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.resultsmanager.model.LicenceProxy;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.view.licence.events.LicenceEvent;
	import com.clarityenglish.resultsmanager.view.licence.events.LicenceShowTypeEvent;
	import com.clarityenglish.resultsmanager.view.shared.events.TitleEvent;
	import com.clarityenglish.resultsmanager.view.shared.interfaces.ICheckBoxRendererProvider;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.resultsmanager.vo.manageable.Group;
	import com.clarityenglish.resultsmanager.vo.manageable.Manageable;
	import com.clarityenglish.resultsmanager.vo.manageable.User;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.clarityenglish.resultsmanager.view.licence.components.*;
	import com.clarityenglish.resultsmanager.view.licence.*;
	
	/**
	 * A Mediator
	 */
	public class LicenceMediator extends Mediator implements IMediator, ICheckBoxRendererProvider {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "LicenceMediator";
		
		private var licenceDataDescriptor:LicenceDataDescriptor;
		
		public static var selectedTitle:Title;
		
		public function LicenceMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
			
			licenceDataDescriptor = new LicenceDataDescriptor();
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			licenceView.addEventListener(LicenceShowTypeEvent.SHOW_ALL, onShowTypeChange);
			licenceView.addEventListener(LicenceShowTypeEvent.SHOW_SELECTED, onShowTypeChange);
			licenceView.addEventListener(LicenceShowTypeEvent.SHOW_UNASSIGNED, onShowTypeChange);
			licenceView.addEventListener(LicenceEvent.ALLOCATE, onLicenceChange);
			licenceView.addEventListener(LicenceEvent.UNALLOCATE, onLicenceChange);
			licenceView.addEventListener(TitleEvent.TITLE_CHANGE, onTitleChange);
			
			licenceView.checkBoxRendererProvider = this;
		}
		
		private function get licenceView():LicenceView {
			return viewComponent as LicenceView;
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
			return LicenceMediator.NAME;
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
					CommonNotifications.LOGGED_IN,
					RMNotifications.LICENCES_LOADED,
					CommonNotifications.COPY_LOADED,
					RMNotifications.CONTENT_LOADED,
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
			trace("note.getBody()"+note.getBody());
			switch (note.getName()) {
				case CommonNotifications.LOGGED_IN:
					licenceView.licencesTree.resetTree();
					break;
				case CommonNotifications.LOGGED_OUT:
					licenceView.licencesTree.resetTree();
					break;
				// v3.2 Should be depracted
				case RMNotifications.LICENCES_LOADED:
					var licenceProxy:LicenceProxy = facade.retrieveProxy(LicenceProxy.NAME) as LicenceProxy;
					licenceDataDescriptor.setLicenceProxy(licenceProxy);
					
					licenceView.licencesTree.dataDescriptor = licenceDataDescriptor;
					licenceView.licencesTree.refreshItemRenderers();
					
					onTitleChange(new TitleEvent(TitleEvent.TITLE_CHANGE, licenceView.titleList.selectedItem as Title));
					break;
				case RMNotifications.MANAGEABLES_LOADED:
					licenceView.setTreeDataProvider(note.getBody() as Array);
					break;
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					licenceView.setCopyProvider(copyProvider);
					break;
				case RMNotifications.CONTENT_LOADED:
					licenceView.titleList.dataProvider = note.getBody();
					break;           
				default:
					break;		
			}
		}
		
		/**
		 * The user has clicked on a title in the left hand tree
		 * 
		 * @param	e
		 */
		private function onTitleChange(e:TitleEvent):void {
			if (!e.title) return;
			
			selectedTitle = e.title;
			
			// Retrieve the allocation figures for this title
			// v3.2 Should be deprecated
			var licenceProxy:LicenceProxy = facade.retrieveProxy(LicenceProxy.NAME) as LicenceProxy;
			
			var assigned:uint = licenceProxy.getUsersInTitle(e.title).length;
			var unassigned:uint = e.title.maxStudents - assigned;
			
			licenceView.setLicenceFigures(assigned, unassigned);
		}
		
		/**
		 * The user has selected a different show type so update the data descriptor
		 * 
		 * @param	e
		 */
		private function onShowTypeChange(e:LicenceShowTypeEvent):void {
			licenceDataDescriptor.setShowType(e.type);
		}
		
		/**
		 * A licence has been allocated/unallocated
		 * 
		 * @param	e
		 */
		private function onLicenceChange(e:LicenceEvent):void {
			switch (e.type) {
				case LicenceEvent.ALLOCATE:
					sendNotification(RMNotifications.ALLOCATE_LICENCES, e);
					break;
				case LicenceEvent.UNALLOCATE:
					sendNotification(RMNotifications.UNALLOCATE_LICENCES, e);
					break;
				default:
					throw new Error("Unknown licence event type '" + e.type + "'");
			}
		}
		
		/* INTERFACE com.clarityenglish.resultsmanager.view.shared.interfaces.ICheckBoxRendererProvider */
		
		public function isCheckBoxEnabled(data:Object):Boolean{
			return (selectedTitle != null);
		}
		
		public function isCheckBoxSelected(data:Object):Boolean{
			if (selectedTitle)
				return (data as Manageable).isLicencedForTitle(selectedTitle);
			else
				return false;
		}
		
		public function onCheckBoxClick(data:Object, selected:Boolean):void {
			// If data is a group convert it to users (we only care about students here as they are the only ones that can be allocated)
			var users:Array;
			
			if (data is Group) {
				users = (data as Group).getSubUsers(User.USER_TYPE_STUDENT);
			} else {
				users = [ data ];
			}
			
			// Dispatch an allocate/unallocate event for this manageable
			var licenceEvent:LicenceEvent = new LicenceEvent((selected) ? LicenceEvent.ALLOCATE : LicenceEvent.UNALLOCATE, users, selectedTitle);
			
			//dispatchEvent(event);
			onLicenceChange(licenceEvent);
		}

	}
}

import com.clarityenglish.resultsmanager.model.LicenceProxy;
import com.clarityenglish.resultsmanager.view.licence.events.LicenceShowTypeEvent;
import com.clarityenglish.resultsmanager.view.management.ManageablesMediator;
import com.clarityenglish.common.vo.content.Title;
import com.clarityenglish.resultsmanager.vo.manageable.Group;
import com.clarityenglish.resultsmanager.vo.manageable.Manageable;
import com.clarityenglish.resultsmanager.vo.manageable.User;
import com.clarityenglish.resultsmanager.vo.manageable.User;
import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.ListCollectionView;
import mx.controls.treeClasses.DefaultDataDescriptor;
import com.clarityenglish.resultsmanager.view.licence.LicenceMediator;

class LicenceDataDescriptor extends DefaultDataDescriptor {
	
	private var showType:String = LicenceShowTypeEvent.SHOW_ALL;
	
	private var licenceProxy:LicenceProxy;
	
	public function LicenceDataDescriptor() {
		super();
	}
	
	public function setLicenceProxy(licenceProxy:LicenceProxy):void {
		this.licenceProxy = licenceProxy;
	}
	
	public function setShowType(showType:String):void {
		this.showType = showType;
	}
	
	/**
	 * Filter the licence tree to show everything, things licenced to the selection in the title tree, or things which are not assigned
	 * to anything.  Note that only users of type 'USER_TYPE_STUDENT' are displayed as they are the only users that can be explicitly
	 * allocated.
	 * 
	 * @param	node
	 * @param	model
	 * @return
	 */
	override public function getChildren(node:Object, model:Object = null):ICollectionView {
		var arrayCollection:ArrayCollection;
		
		var selectedTitle:Title = LicenceMediator.selectedTitle;
		
		switch (showType) {
			case LicenceShowTypeEvent.SHOW_ALL:
				arrayCollection = new ArrayCollection();
				
				for each (var child:Manageable in node.children) {
					// Only show groups and users of type USER_TYPE_STUDENT
					if (child is User && (child as User).userType != User.USER_TYPE_STUDENT)
						continue;
						
					arrayCollection.addItem(child);
				}
				
				break;
			case LicenceShowTypeEvent.SHOW_SELECTED:
				if (!selectedTitle) return null;
				
				arrayCollection = new ArrayCollection();
				
				// Only show groups and users of type USER_TYPE_STUDENT who are allocated to the selected title
				for each (child in node.children) {
					if (child is Group)
						arrayCollection.addItem(child);
					else
						if (licenceProxy.isUserInTitle(child as User, selectedTitle) && (child as User).userType == User.USER_TYPE_STUDENT)
							arrayCollection.addItem(child);
				}
				break;
			case LicenceShowTypeEvent.SHOW_UNASSIGNED:
				if (!selectedTitle) return new ArrayCollection(node.children);
				
				arrayCollection = new ArrayCollection();
				
				// Only show groups and users of type USER_TYPE_STUDENT who are not allocated to the selected title
				for each (child in node.children) {
					if (child is Group)
						arrayCollection.addItem(child);
					else
						if (!licenceProxy.isUserInTitle(child as User, selectedTitle) && (child as User).userType == User.USER_TYPE_STUDENT)
							arrayCollection.addItem(child);
				}
				break;
		}
		
		return arrayCollection;
	}
	
	/**
	 * Branches are deermined on the basis of whether there are any children.
	 * 
	 * @param	node
	 * @param	model
	 * @return
	 */
	override public function isBranch(node:Object, model:Object = null):Boolean {
		return (node is Group);
	}
	
}
