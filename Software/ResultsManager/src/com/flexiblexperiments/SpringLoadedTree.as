/**
 * All computational source code, intellectual property or other works 
 * contained herein are deemed Public Domain as per the Creative 
 * Commons Public Domain license.
 * 
 * http://creativecommons.org/licenses/publicdomain/
 * 
 * Author : Jason Hawyluk
 * Date: 26/02/2007
 * Reference : http://flexibleexperiments.wordpress.com
 * 
 * Jason Hawryluk disclaims all warranties with regard to this software, 
 * including all implied warranties of merchantability and fitness, in 
 * no event shall Jason Hawryluk be liable for any special, indirect or 
 * consequential damages or any damages whatsoever resulting from loss of 
 * use, data or profits, whether in an action of contract, negligence or 
 * other tortuous action, arising out of or in connection with the use or 
 * performance of this software.
 **/
package com.flexiblexperiments
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import org.davekeen.controls.DKTree;
	
	import mx.collections.ICollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.Tree;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.ClassFactory;
	import mx.core.DragSource;
	
	import mx.core.mx_internal;
	import mx.effects.Fade;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.events.ListEvent;
	import mx.events.TreeEvent;
	
	import mx.managers.DragManager;
	
	//Update:
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.managers.CursorManager;
	import flash.geom.Point;
	import mx.managers.dragClasses.*
	import mx.core.IUIComponent;
	//Update:
					
	use namespace mx_internal;
		
	public class SpringLoadedTree extends DKTree
	{
	
		//Extended timer class for the open delay.
		private var _delayedTimer:DelayedTimer = new DelayedTimer();
		
		//Used to close nodes on delay.
		private var _cleanUpDelayedTimer:DelayedTimer = new DelayedTimer();
						
		//Store last folder that the user was over.
		private var _lastNodeOver:TreeItemRenderer;
		
		//Fade effect instance for the icon TreeItemRenderer.
		private var _treeItemRendererFadeEffect:Fade = new Fade();
		
		//refference to node being animated
		private var tweeningNode:Object
				
		/**
		* Keep a list of folders that were open prior to the drag operation so that
		* we can know not to close them in the restore and close nodes methods.
		**/
		private var openedFolderHierarchy:Object;
		        
	        
		public function SpringLoadedTree()
		{
			super();
						
			//Drag events
			addEventListener(DragEvent.DRAG_COMPLETE,handleDragComplete);
			addEventListener(DragEvent.DRAG_OVER,handleDragOver);
			addEventListener(DragEvent.DRAG_EXIT,handleDragExit);
			addEventListener(DragEvent.DRAG_START,handleDragStart);
			
			addEventListener(TreeEvent.ITEM_OPEN,handleItemOpened);
			addEventListener(TreeEvent.ITEM_CLOSE,handleItemClosed);
			
			
			//Update:
			addEventListener(DragEvent.DRAG_DROP,handleDragDrop);
			addEventListener("click", handleOpenClick);
			
			
			//key events
			addEventListener(KeyboardEvent.KEY_UP, handleKeyEvents);
			
			_delayedTimer.addEventListener(TimerEvent.TIMER_COMPLETE,handleTimerComplete);
			
			//setup for effect
			_treeItemRendererFadeEffect.alphaFrom = 1;
			_treeItemRendererFadeEffect.alphaTo = .2;
			_treeItemRendererFadeEffect.duration = 200;
			_treeItemRendererFadeEffect.startDelay = 400;
			_treeItemRendererFadeEffect.repeatDelay = 200;
								
			
		}
		
		/**
		* When true the node will be closed on drag exit if it was not already 
		* open before the drag operation started.
		**/
		private var _showOpeningIndication:Boolean=true;
		[Bindable]
		public function set showOpeningIndication(value:Boolean):void{
			_showOpeningIndication=value;
		}
		public function get showOpeningIndication():Boolean{
			return _showOpeningIndication;	
		}

		/**
		* When true the node dropped into will be closed on drop complete.
		**/
		private var _autoCloseOnDrop:Boolean=true;
		[Bindable]
		public function set autoCloseOnDrop(value:Boolean):void{
			_autoCloseOnDrop=value;
		}
		public function get autoCloseOnDrop():Boolean{
			return _autoCloseOnDrop;	
		}
		
		/**
		* When true when the user drags outside the control the state is restored 
	 	* as it was before the drag operation.
		**/
		private var _autoCloseOnExit:Boolean=true;
		[Bindable]
		public function set autoCloseOnExit(value:Boolean):void{
			_autoCloseOnExit=value;
		}
		public function get autoCloseOnExit():Boolean{
			return _autoCloseOnExit;	
		}
				
		/**
		* When true the node will be closed on dragging out of the current node if; 
		* it was not already open before the drag operation started.
		**/
		private var _autoCloseOpenNodes:Boolean=true;
		[Bindable]
		public function set autoCloseOpenNodes(value:Boolean):void{
			_autoCloseOpenNodes=value;
		}
		public function get autoCloseOpenNodes():Boolean{
			return _autoCloseOpenNodes;	
		}
		/**
		* Used to set the timer delay in MS for the closing of the folders.
		**/
		private var _autoCloseTimerMS:Number = 100;
		[Bindable]
		public function set autoCloseTimerMS(value:Number):void{
			_autoCloseTimerMS;
		}
		public function get autoCloseTimerMS():Number{
			return _autoCloseTimerMS;	
		}
		
		/**
		* Used to set the timer delay in MS for opening folders.
		**/
		private var _autoOpenTimerMS:Number = 1000;
		[Bindable]
		public function set autoOpenTimerMS(value:Number):void{
			_autoOpenTimerMS=value;
		}
		public function get autoOpenTimerMS():Number{
			return _autoOpenTimerMS;	
		}
		
		/**
		* Update: Get a handle to the indernal drop data structure.
		**/
		public function get dropData():Object{
			return super.mx_internal::_dropData;
		}
				
		/**
		* Update: Open/close on click anywhere in the item render
		* see handleClick()
		**/
		private var _openOnClick:Boolean = true;
		[Bindable]
		public function set openOnClick(value:Boolean):void{
			_openOnClick=value;
		}
		public function get openOnClick():Boolean{
			return _openOnClick;	
		}
		
		/**
		* Update:When set to true children will inherit their parents restrictions
		* for a drag operation. For example the control will not allow dragging of 
		* children of a parent that has a acceptDrag attribute = false. 
		**/
		private var _inheritRestrictionsDrag:Boolean = true;
		[Bindable]
		public function set inheritRestrictionsDrag(value:Boolean):void{
			_inheritRestrictionsDrag=value;
		}
		public function get inheritRestrictionsDrag():Boolean{
			return _inheritRestrictionsDrag;	
		}

		/**
		* Update:When set to true children will inherit their parents restrictions
		* for a drop operation. For example the control will not allow dropping into 
		* children of a parent that has a acceptDrop attribute = false. 
		**/
		private var _inheritRestrictionsDrop:Boolean = true;
		[Bindable]
		public function set inheritRestrictionsDrop(value:Boolean):void{
			_inheritRestrictionsDrop=value;
		}
		public function get inheritRestrictionsDrop():Boolean{
			return _inheritRestrictionsDrop;	
		}

		/**
		* Update: When set to true and multiple items are selected for a 
		* drag operation, the drag proxy image will show a group of items
		* for example "Group (#)" where #is the number of items being 
		* dragged.
		**/
		private var _groupDragProxy:Boolean = true;
		[Bindable]
		public function set groupDragProxy(value:Boolean):void{
			_groupDragProxy=value;
		}
		public function get groupDragProxy():Boolean{
			return _groupDragProxy;	
		}
	
		/**
		* Update: specify the text to use in the group drag proxy image
		* a value of {#} will be replaced with the number of items being 
		* dragged 
		**/
		private var _groupDragProxyLabel:String = "";
		[Bindable]
		public function set groupDragProxyLabel(value:String):void{
			_groupDragProxyLabel=value;
		}
		public function get groupDragProxyLabel():String{
			return _groupDragProxyLabel;	
		}
		
					
		/**
		* The returned dispatched call if delay triggered.
		**/
		private function dispatchDelayedOpen(event:TimerEvent):void{
			
			if(autoCloseOpenNodes==true){
				
				//Stop the indicator if required.
				if (_treeItemRendererFadeEffect.isPlaying){
					_treeItemRendererFadeEffect.end();
					
					//Update:
					if(itemToItemRenderer(event.currentTarget.item)){
						TreeItemRenderer(itemToItemRenderer(event.currentTarget.item)).alpha = 1;
					}
				}
				
				if (event.currentTarget.item.children.length !=0){
					try{
						expandItem(event.currentTarget.item,true,true,true,event);
					}
					catch (err:Error){
						return;
					}
				}
				else{
					try{
						expandItem(event.currentTarget.item,true,false,true,event);
					}
					catch (err:Error){
						return;
					}
				}
			}
		}
		
		/**
		* Initialize the drop indication fade effect.
		**/
		private function initOpeningIndication(value:Object):void{
						
			//Grab the TreeItemRenderer.
			var currNodeOver:TreeItemRenderer = TreeItemRenderer(itemToItemRenderer(value));
			
			stopAnimation();
			
			_treeItemRendererFadeEffect.target = currNodeOver;
			_treeItemRendererFadeEffect.repeatCount = (((autoOpenTimerMS-200)-_treeItemRendererFadeEffect.startDelay)/200)
			
			callLater(_treeItemRendererFadeEffect.play);
			
						
		}
				
		
		/**
		* stop the currently playing animation
		**/
		private function stopAnimation():void{
			//Stop the indicator if required.
			if (_treeItemRendererFadeEffect.isPlaying){
				_treeItemRendererFadeEffect.end();
				_treeItemRendererFadeEffect.target.alpha = 1;
			}
		}
		
		/**
		* Start closing the opened nodes.
		**/
		private function handleTimerComplete(event:TimerEvent):void{
			closeNodes(event.currentTarget.item);
		}
		
		/**
		* For each item closed re-curse until all items are closed.
		**/
		private function handleItemClosed(event:TreeEvent):void{
									
			if (DragManager.isDragging){
				if (_lastNodeOver !=null){
					closeNodes(_lastNodeOver.data);
				}
				else{
					closeNodes(null);
				}
			}
		}
		
		/**
		* Once the animation for opening a node is complete, make the 
		* call to close un wanted open nodes. This will re-curse until all
		* items are closed.
		**/		
		private function handleItemOpened(event:TreeEvent):void{
			if (DragManager.isDragging){
				if (_lastNodeOver !=null){
					closeNodes(_lastNodeOver.data);
				}
				else{
					closeNodes(null);
				}
			}
		}
		
		/**
		* Update: On the click of an item renderer open/close it if 
		* openOnClick property is true.
		**/
		private function handleOpenClick(event:MouseEvent):void{
			
			//Exit as well if the selected item is null, if the tree
			//supports multi selection then this is the case when one 
			//or more nodes are selected.
			if (!openOnClick || !selectedItem){return;}
			
			//test that we are in fact over top of the item.
			//(see method description)
			if (!isMouseOverNode(selectedItem)){return;}
			
			
			//if control key is pressed then return as perhaps multi 
			//select in progress
			if (event.ctrlKey==true || event.altKey==true){
				event.preventDefault(); 
				return;
			}
									
			if (dataDescriptor.isBranch(selectedItem)){
				
				//on the below expanditem calls dispatch the event so that 
				//subsequent actions can take place
				if (isItemOpen(selectedItem)==true){
					expandItem(selectedItem,false,true,true);
				}
				else{
					expandItem(selectedItem,true,true,true);				
				}
							
				return;
			}
		}
		
		/**
		* Handle the delayed call to close any un wanted nodes.  
	 	* This is called in a few areas to properly handle the closing.
		**/
		private function closeNodes(item:Object=null):void{
			
			if(autoCloseOpenNodes==true){
				
				tweeningNode = item;
				
				if (item==null && _lastNodeOver==null){
					_cleanUpDelayedTimer.startDelayedTimer(restoreState,null,null,autoCloseTimerMS,1,null);
				}
				else{
					_cleanUpDelayedTimer.startDelayedTimer(closeOpenNodes,null,null,autoCloseTimerMS,1,item);
				}
			}
		}
		
		/**
		* Listen for the spacebar key and open folder if not 
		* already open, then cancel the timer.
		**/
		private function handleKeyEvents(event:KeyboardEvent):void{
			switch(event.keyCode){
				case 32:
				
					if (_lastNodeOver !=null){
		
						_delayedTimer.cancelDelayedTimer();
						stopAnimation();
						
						if (dataDescriptor.isBranch(_lastNodeOver.data)){
							if (_lastNodeOver.data.children().length()==0){
								try{
									expandItem(_lastNodeOver.data,true,false);
								}
								catch (err:Error){
									break;	
								}
							}
							else{
								try{
									expandItem(_lastNodeOver.data,true,true);
								}
								catch (err:Error){
									break;	
								}
							}
							
						}
					}
					
			}
		}
		
		/**
		* Handle the drag over trying to make sure we don't do unnecessary calls.
		* Store the node that the user is currently over for proper close testing.
		* Dispatch the delayed open call if over a new node.
		* 
		* Note: Updated to stop from dragging into self and test for a drop rejection 
		* AR: Remember that this is called before the dragOver event in the view, so if you change
		* any showRejectDropCursor in that, you will lose the draggingOverSelf setting.
		**/
		private function handleDragOver(event:DragEvent):void{
			
			//Update: make sure the node is not being dragged over/into itself
			if (draggingOverSelf(event)){
				showRejectDropCursor(true);
				//kill any straggling delayed timer events
				_delayedTimer.cancelDelayedTimer();
				stopAnimation();
				return;
			}
			else{
				showRejectDropCursor(false);
			}
			
			//Get the node currently dragging over.
			var currNodeOver:TreeItemRenderer = TreeItemRenderer(indexToItemRenderer(calculateDropIndex(event)));
			
			//Update: If the current node does not allow drop then show the restricted cursor
			//but continue to open anyway
			if (currNodeOver){
				if (!itemAcceptDrop(currNodeOver.data)){
					showRejectDropCursor(true)
				}
				else{
					showRejectDropCursor(false);
				}
			}
			
			
			if(autoCloseOpenNodes==false){return;}
					
			
			//Update: kill any straggling delayed timer events
			//if the current node is not the last node 
			//over even if the current node is null
			if (currNodeOver !=_lastNodeOver){
				_delayedTimer.cancelDelayedTimer();
				stopAnimation();
			}
			
			if (currNodeOver !=null){
				
				//If not a branch node exit.
				if (!dataDescriptor.isBranch(currNodeOver.data)){
					_delayedTimer.cancelDelayedTimer();
					stopAnimation();
					return;
				}
				
				//Cleanup opened nodes.
				closeNodes(currNodeOver.data);
						
				//If the current node is not open then dispatch timer.
				if (isItemOpen(currNodeOver.data)==false){
				
					//If it's already running on the current item avoid a timer reset.
					if (_delayedTimer.running ==true && _delayedTimer.item ==currNodeOver.data){
						return;
					}
					else if (_delayedTimer.running ==true) {
						//Clear the current delayed timer.
						_delayedTimer.cancelDelayedTimer();
						stopAnimation();
					} 
										
					//Set the local new folder over.
					_lastNodeOver = currNodeOver;
				
					//Start the indication if required "showOpeningIndication".
					if (_showOpeningIndication){
						initOpeningIndication(currNodeOver.data);
					}
														
					//Create callback.
					_delayedTimer.startDelayedTimer(dispatchDelayedOpen,null,null,autoOpenTimerMS,1,currNodeOver.data);
					
					
					
				}
			}
			
			else{
				//If not over any node cleanup and return.
				if (_lastNodeOver != null){
					_delayedTimer.cancelDelayedTimer();
					stopAnimation();
					_lastNodeOver = null;
				}
			}
		}
		
		/**
		* Init the start of the drag and grab a open folder stack so we can 
		* compare later when closing, opening, exiting etc..
		**/		
		private function handleDragStart(event:DragEvent):void{
			if(autoCloseOpenNodes==true){
				stopAnimation();
				_delayedTimer.cancelDelayedTimer();
				openedFolderHierarchy = openItems;
			}
			
			//Update: if any of the nodes being dragged have a canDrag=false
			//then don't allow it
			for (var i:int = 0;i<event.currentTarget.selectedItems.length;i++){
				if (!itemAcceptDrag(event.currentTarget.selectedItems[i])){
					event.currentTarget.hideDropFeedback(event);	
					event.preventDefault();
					return;
				}
			}
		
			
		}
		
		/**
		* Cleanup the drag operation and call restore to set the nodes as 
		* before the drag operation started.
		**/
		private function handleDragComplete(event:DragEvent):void{
			
			if(autoCloseOpenNodes==true){
				
				_delayedTimer.cancelDelayedTimer();
				_lastNodeOver = null;
				
				stopAnimation();
				
				if(_autoCloseOnDrop==true){
					closeNodes(null);
				}
			}
			
			//Update: clear any reject cursor
			showRejectDropCursor(false);
			
			//Display bug when dropping into a node without children duplicates a 
			//bunch of nodes in the display and only seems to happen when it's an empty 
			//folder not sure what it's related to (there must be a better way???)
			if (dropData){
				if (dropData.emptyFolder==true){
					selectedItem = dropData.parent;
				}
			}				
			
		}
		
		/**
		* Same as above in a different handler due to it being an optional process. 
		**/ 
		private function handleDragExit(event:DragEvent):void{
			_delayedTimer.cancelDelayedTimer();
			_lastNodeOver = null;
			stopAnimation();
			if(_autoCloseOnExit==true){
				closeNodes(null);
			}
			
			//Update:clear any reject cursor
			showRejectDropCursor(false);
			
		}
		
		/**
		* Control the drop process
		**/
		private function handleDragDrop(event:DragEvent):void{

			//Update: Don't allow dropping into folders that are flagged 
			//as canDropInto = false
			if (CursorManager.currentCursorID == rejectCursorID){
				event.preventDefault();				
				hideDropFeedback(event);
				return;
			}
						
			
		}
				
		/**
		* Restore tree structure to original state based on the open items 
		* before the drag operation. Called from drag exit and drop complete 
		* to reset original state.
		**/
		private function restoreState(event:TimerEvent):void{
			
			//Back out if state has changed since timer delay setting.
			if (_lastNodeOver != null){return;}
			
			// from akmeful (re:nasty tween bug fix)
			if(openedFolderHierarchy.length > 0){
				openItems = openedFolderHierarchy;
			}


			//Get a current state of hierarchy.
			var currentOpenFolders:Object=openItems;
			
			for (var i:int = 0; i < currentOpenFolders.length; i++){
				if (openedFolderHierarchy.indexOf(currentOpenFolders[i])==-1){
													
					if (dataDescriptor.isBranch(currentOpenFolders[i])){
						if (!currentOpenFolders[i].children().length()==0){
							
							try{
								expandItem(currentOpenFolders[i],false,true,true);
							}
							catch (err:Error){
								break;	
							}
							break;
						}
						else{
							try{
								expandItem(currentOpenFolders[i],false,false,true);
							}
							catch (err:Error){
								break;
							}
							
						}
						
					}
					
				}
			}
			
			
		}
		
		
		/**
		* Close all nodes as required, except the current node the user is 
		* dragging over, and only if the node to be closed is not part of the 
		* original open node stack.
		**/
		private function closeOpenNodes(event:TimerEvent):void{
			
			var parentItems:Object = getParentStack(event.currentTarget.item);
			
			//Get a current state of hierarchy.
			var currentOpenFolders:Object=openItems;
			
			for (var i:int = 0; i < currentOpenFolders.length; i++){
				//Make sure it was not opened before the drag start
				//and the current node that we are dragging over
				//is not going to be closed.
				if (openedFolderHierarchy.indexOf(currentOpenFolders[i])==-1){
					if (currentOpenFolders[i]!=event.currentTarget.item && parentItems.indexOf(currentOpenFolders[i])==-1){
						//Otherwise close the node.
						if (dataDescriptor.isBranch(currentOpenFolders[i])){
							if (!currentOpenFolders[i].children.length==0){
								try{
									expandItem(currentOpenFolders[i],false,true,true);	
								}
								catch (err:Error){
									break;	
								}
								break;
							}
							else{
								try{
									expandItem(currentOpenFolders[i],false,false,true);
								}
								catch (err:Error){
									break;
								}
							}
							
							
						}
					}
				}
			}
		}
		
		//override the tween end to avoid nasty error on the close of 
		//a node with no children when calling expandItem. without this
		//sometimes when closeing a node with no children generates an
		//Error #1009 in the tree.as error is unhandled so it explodes
		//the app. 
		override mx_internal function onTweenEnd(value:Object):void{
			
			try{
				super.mx_internal::onTweenEnd(value);
			}
			catch(err:Error){
				//Tween failure a nasty flex bug.
				//trace(err.message); 
			}
		}
		
		/**
	    * Returns the stack of parents from a child item. 
	    * Note: Stolen from tree code in framwork handy :)!!
	    */
	    private function getParentStack(item:Object):Array{
	        var stack:Array = [];
	        if (item == null)
	            return stack;
	        
	        	var parent:* = getParentItem(item);
	    	    while (parent){
	        	    stack.push(parent);
	    	        parent = getParentItem(parent);
		        }
	        	return stack;       
	    }
		
		/**
		* Update: Test to see if the node being dragged is dragging over/into
		* itself.
		**/
		private function draggingOverSelf(event:DragEvent):Boolean{
		
			//Get the node currently dragging over.
			var currNodeOver:TreeItemRenderer = TreeItemRenderer(indexToItemRenderer(calculateDropIndex(event)));
			if (currNodeOver==null){
				return false;
			}
			
			//get the node we are currently dragging
			var draggingNode:TreeItemRenderer = TreeItemRenderer(itemToItemRenderer(event.dragSource.dataForFormat("treeItems")[0]));
			if(currNodeOver != draggingNode){
				return false;
			}
			return true;
		}
		
		/**
		* Update: Show a reject drop cursor or clear it. Depending on the 
		* situation one might want to walk up to the parent node to 
		* get it's status in order to show a reject for all child nodes
		* of a node that has the rejection.
		**/
		/*
		 * AR: Seems this would be a useful function to be able to call publicly
		 * since my own onDragOver works out some stuff about when you are not allowed to drop.
		 * I'll also make a public getter that lets me see if the tree is currently 'rejecting' so I can stop the drop reacting.
		 */
		private var rejectCursorID:int;
		//private function showRejectDropCursor(value:Boolean):void{
		public function showRejectDropCursor(value:Boolean):void{
			
			if (value==true && CursorManager.currentCursorID != rejectCursorID){
				var newCursorClass:Class;
				
				//grab the reject cursor from the dragmanager style declaration
				var styleSheet:CSSStyleDeclaration = StyleManager.getStyleDeclaration("DragManager");
				newCursorClass = styleSheet.getStyle("rejectCursor");
				
				//assign it as top level
				rejectCursorID = CursorManager.setCursor(newCursorClass,0); 
				
		 	}
		 	else if (value==false){
		 		//remove our rejectCursorID from the list	
		 		CursorManager.removeCursor(rejectCursorID);
		 		rejectCursorID = -1;
		 		
			}
		 	
		}
		public function get rejectDropCursor():Boolean {
			return CursorManager.currentCursorID == rejectCursorID;
		}
		 
		/**
		* Update: Test whether or not the passed node is the node 
		* the mouse is over, by getting the itemrenderer 
		* and compareing x and y corrdinates. This is for the 
		* clickOpen. In Flex if an item is selected and you 
		* click in the parent white space it'll open. This test 
		* helps us correct that.
		**/
		private function isMouseOverNode(item:Object):Boolean{
			
			//convert the mouse x and y
			var currentPoint:Point = new Point(mouseX,mouseY);
			currentPoint = localToGlobal(currentPoint);
			
			//grab the selected item renderer
			var selectedItemrenderer:TreeItemRenderer = TreeItemRenderer(itemToItemRenderer(item));
			
			//get the point structure for comparision
			var selectedItemPoint:Point = new Point(selectedItemrenderer.x,selectedItemrenderer.y);
			selectedItemPoint = localToGlobal(selectedItemPoint);
			
			
			if (currentPoint.y > selectedItemPoint.y && 
			currentPoint.y < (selectedItemPoint.y + selectedItemrenderer.height)){
				return true;
			}
			
			return false;
			
		}
		
		/**
		* Update:Tests for the acceptDrop value on the data source for 
		* both obejct and xml.
		**/
		private function itemAcceptDrop(item:Object):Boolean{
			
			if (item is XML){
                try{
                    if (item.@acceptDrop.length() != 0){
                    	if (item.@acceptDrop == "false"){
                    		return false;
                    	}
                    }
                }
                catch(e:Error){
                }
            }
            else if (item is Object){
                try{
                    if (item.acceptDrop){
                    	if (item.acceptDrop == "false"){
	                    	return false;	
                    	}
                    }
                }
                catch (e:Error){
                }
            }
            
            //recurse if required
            if (inheritRestrictionsDrop){
            	//if (item.parent()){
            		//if (!itemAcceptDrop(item.parent())){
            			//return false
            		//}
            	//}
            }
            
            return true;
            
		}
		
		/**
		* Update:Tests for the acceptDrag value on the data source for 
		* both obejct and xml.
		**/
		private function itemAcceptDrag(item:Object):Boolean{
			
			if (item is XML){
                try{
                    if (item.@acceptDrag.length() != 0){
                    	if (item.@acceptDrag == "false"){
                    		return false;
                    	}
                    }
                }
                catch(e:Error){
                }
            }
            else if (item is Object){
                try{
                    if (item.acceptDrag){
                    	if (item.acceptDrag == "false"){
	                    	return false;	
                    	}
                    }
                }
                catch (e:Error){
                }
            }
            
            //recurse if required
            if (inheritRestrictionsDrag){
            	//if (item.parent()){
            		//if (!itemAcceptDrag(item.parent())){
            			//return false
            		//}
            	//}
            }
            
            return true;
		}
		
		/**
		* Show a grouped drag proxy image instead of the default all items 
		* stacked type image.
		**/
		override protected function get dragImage():IUIComponent
    	{
    		
        	if (groupDragProxy){
	        	var image:ListItemGroupedDragProxy = new ListItemGroupedDragProxy();
    	    	image.owner = this;
        		return image;
        	}
        	else{
        		return super.dragImage;	
        	}
        	
    	}
			 	
	 	
	}
}