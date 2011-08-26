package eu.orangeflash.managers
{
	import flash.display.InteractiveObject;
	import flash.events.*;
	import flash.errors.IllegalOperationError;
	import flash.ui.*;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Class manages ContextMenu item, has methods such as add, remove, insert.
	 * 
	 * @author		Nirth
	 * @url			http://blog.orangeflash.eu
	 * @see			ContextMenu, ContextMenuItem, ContextMenuEvent, EventDispatcher, InteractiveObject
	 */	
	public class CMManager 
	extends EventDispatcher
	{
		protected var menu:ContextMenu;
		protected var target:InteractiveObject;
		/**
		 * Constructor, creates new CMManager isntance
		 * 
		 * @param	target		Reference to InteractiveObject which menu will be managed
		 */
		public function CMManager(target:InteractiveObject, hideBuiltInItems:Boolean = true)
		{
			this.target = target;
			
			menu = new ContextMenu();
			
			if(hideBuiltInItems)
			{
				menu.hideBuiltInItems();
			}
			
			this.target.contextMenu = menu;
			
			menu.addEventListener(ContextMenuEvent.MENU_SELECT,passEvent);		
		}
		/**
		 * Method, adds new ContextMenuItem.
		 * 
		 * @param	caption				Specifies the menu item caption (text) displayed in the context menu.
		 * @param	handler				Event handler for menu item.
		 * @param	separatorBefore		Indicates whether a separator bar should appear above the specified menu item.
		 * @param	enabled				Indicates whether the specified menu item is enabled or disabled.
		 * @param	visible				Indicates whether the specified menu item is visible when the Flash Player context menu is displayed.
		 * 
		 * @return						Reference to newly created ContextMenuItem
		 */
		public function add(caption:String, 
							handler:Function, 
							separatorBefore:Boolean = false, 
							enabled:Boolean = true, 
							visible:Boolean = true):ContextMenuItem
		{
			var result:ContextMenuItem = createItem(caption, handler, separatorBefore, enabled, visible);
				
			menu.customItems.push(result);
			
			return result;
		}
		/**
		 * Method, inserts new ContextMenuItem.
		 * 
		 * @param	id					String or Number(int,uint). If id is string, ContextMenuManager will add before ContextMenuItem with captions which matches id, otherwise will be added item with index.
		 * @param	caption				Specifies the menu item caption (text) displayed in the context menu.
		 * @param	handler				Event handler for menu item.
		 * @param	separatorBefore		Indicates whether a separator bar should appear above the specified menu item.
		 * @param	enabled				Indicates whether the specified menu item is enabled or disabled.
		 * @param	visible				Indicates whether the specified menu item is visible when the Flash Player context menu is displayed.
		 * 
		 * @return						Reference to newly created ContextMenuItem
		 */
		public function insert(	id:*,
								caption:String, 
								handler:Function, 
								separatorBefore:Boolean = false, 
								enabled:Boolean = true, 
								visible:Boolean = true):ContextMenuItem
		{
			var result:ContextMenuItem 	= createItem(caption, handler, separatorBefore, enabled, visible);			
			var index:int 				= id is String ? getIndexByCaption(id) : id as int;
			
			(menu.customItems as Array).splice(index,0,result);
			
			return result;			
		}
		/**
		 * Method, removes item from customItems array
		 * 
		 * @param	id		String or Number(int,uint). If id is string, ContextMenuManager will remove ContextMenuItem with captions which matches id, otherwise will remove item with index.
		 */
		public function remove(id:*):void
		{
			if(id is String)
			{
				id = getIndexByCaption(id);
			}
			customItems.splice(id as Number,1);
		}
		
		/**
		 * Method. Hides all built-in menu items (except Settings) in the specified ContextMenu object. If the debugger version of Flash Player is running, the Debugging menu item appears, although it is dimmed for SWF files that do not have remote debugging enabled. 
		 * 
		 */
		public function hideBuiltInItems():void
		{
			menu.hideBuiltInItems();
		}
		/**
		 * Method, returns reference to ContextMenuItem by it's id.
		 * 
		 * @param	id		String or Number(int,uint). If id is string, ContextMenuManager will return ContextMenuItem with captions which matches id, otherwise will return item with index.
		 * 
		 * @return			reference to the ContextMenuItem instance.
		 */
		public function getItem(id:*):ContextMenuItem
		{
			if(id is String)
			{
				id = getIndexByCaption(id);
			}
			return menu.customItems[id];
		}
		
		/**
		 * Property[read-only] An array of ContextMenuItem objects.
		 * 
		 * @return			An array of ContextMenuItem objects.
		 */
		public function get customItems():Array
		{
			return menu.customItems;
		}
		
		/**
		 * Property[read-only] An object that has the following properties of the ContextMenuBuiltInItems class: forwardAndBack, loop, play, print, quality, rewind, save, and zoom.
		 * 
		 * @return			An object that has the following properties of the ContextMenuBuiltInItems class.
		 */
		public function get builtInItems():ContextMenuBuiltInItems
		{
			return menu.builtInItems;
		}
		
		/**
		 *	Property[read-only], returns reference to context menu.
		 * 
		 * @return		ContextMenu
		 */
		public function get contextMenu():ContextMenu
		{
			return menu;
		}
		
		
		/**
		 *@private
		 */
		protected function createItem(caption:String, handler:Function, separatorBefore:Boolean = false, enabled:Boolean = true, visible:Boolean = true):ContextMenuItem
		{
			var result:ContextMenuItem = new ContextMenuItem(caption,separatorBefore,enabled,visible);
				result.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,handler);
				result.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,passEvent);
				
			return result;
		}
		/**
		 *@private
		 */
		protected function getIndexByCaption(caption:String):int
		{
			for ( var i:uint = 0 ; i < menu.customItems.length ; i ++ )
			{
				if(menu.customItems[i].caption == caption)
				{
					return i;
				}
			}
			return -1;
		}
		/**
		 * @private
		 */
		protected function passEvent(event:ContextMenuEvent):void
		{
			dispatchEvent(new ContextMenuEvent(	event.type,
												event.bubbles,
												event.cancelable,
												event.mouseTarget,
												event.contextMenuOwner));
		}
	}
}