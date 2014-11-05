package com.clarityenglish.bento.view.base {
	import com.clarityenglish.bento.view.base.events.BentoEvent;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.TabbedViewNavigator;
	import spark.components.View;
	import spark.components.ViewNavigator;
	
	/**
	 * This is the parent class of all views in Bento.
	 * 
	 * @author Dave
	 */
	[Event(name="hrefChanged", type="com.clarityenglish.bento.view.base.events.BentoEvent")]
	[Event(name="xhtmlReady", type="com.clarityenglish.bento.view.base.events.BentoEvent")]
	public class BentoView extends View {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * The Href that this view is running off 
		 */
		private var _href:Href;
		private var _hrefChanged:Boolean = false;
		
		/**
		 * The XHTML file loaded from the Href 
		 */
		protected var _xhtml:XHTML;
		private var _xhtmlChanged:Boolean;
		
		/**
		 * This is used to allow view navigators to be linked to view states gh#241
		 */
		private var _navStateMapInstances:Dictionary = new Dictionary(true);
		
		// #234
		protected var _productVersion:String;
		
		// gh#39
		protected var _productCode:String;
		protected var _licenceType:uint;
		
		public var media:String = "screen";
		
		// Used to drive onViewCreationComplete in the mediator
		private var _isCreationComplete:Boolean;
		
		/**
		 * Configuration properties commonly used in views
		 * #333
		 */
		public var config:Config;
		
		[Bindable]
		public var copyProvider:CopyProvider;
		
		public function BentoView() {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			addEventListener(FlexEvent.PREINITIALIZE, onPreinitialize, false, 0, true);
		}
		
		internal function get isCreationComplete():Boolean {
			return _isCreationComplete;
		}

		internal function set isCreationComplete(value:Boolean):void {
			_isCreationComplete = value;
			if (value) onViewCreationComplete();
		}

		public function setCopyProvider(copyProvider:CopyProvider):void {
			this.copyProvider = copyProvider;
		}
		
		/**
		 * We may need to change the skin based on the media type
		 * 
		 * @param event
		 */
		protected function onPreinitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
			
			switch (media) {
				case "print":
					setStyle("skinClass", getStyle("printingSkinClass"));
					break;
			}
			
		}
		
		protected override function createChildren():void {
			super.createChildren();
			
			// A rather neat way to allow action and navigation content to be defined in skins
			if (skin) {
				if (skin.hasOwnProperty("actionContent"))
					actionContent = skin["actionContent"];
				
				if (skin.hasOwnProperty("navigationContent"))
					navigationContent = skin["navigationContent"];
			}
		}
		
		protected function onAddedToStage(event:Event):void {
			
		}
		
		protected function onRemovedFromStage(event:Event):void {
			_href = null;
			_xhtml = null;
			_navStateMapInstances = null;
		}
		
		/**
		 * This is fired when all skin parts are available, each time the view is added to the screen.  It can be used to assign copy.
		 */
		protected function onViewCreationComplete():void {
			
		}
		
		[Bindable]
		public function get href():Href {
			return _href;
		}
		
		public function set href(value:Href):void {
			_href = value;
			_hrefChanged = true;
			
			invalidateProperties();
		}
		
		public function set xhtml(value:XHTML):void {
			_xhtml = value;
			_xhtmlChanged = true;
			
			invalidateProperties();
		}
		
		[Bindable(event="productVersionChanged")]
		public function get productVersion():String {
			return _productVersion;
		}
		
		public function set productVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		
		[Bindable(event="productCodeChanged")]
		public function get productCode():String {
			return _productCode;
		}
		
		public function set productCode(value:String):void {
			if (_productCode != value) {
				_productCode = value;
				dispatchEvent(new Event("productCodeChanged"));
			}
		}
		
		[Bindable(event="licenceTypeChanged")]
		public function get licenceType():uint {
			return _licenceType;
		}
		
		public function set licenceType(value:uint):void {
			if (_licenceType != value) {
				_licenceType = value;
				dispatchEvent(new Event("licenceTypeChanged"));
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_hrefChanged)
				dispatchEvent(new BentoEvent(BentoEvent.HREF_CHANGED));
			
			if (_xhtmlChanged) {
				updateViewFromXHTML(_xhtml);
				dispatchEvent(new BentoEvent(BentoEvent.XHTML_READY));
			}
			
			_hrefChanged = _xhtmlChanged = false;
		}
		
		protected function updateViewFromXHTML(xhtml:XHTML):void {
			
		}
		
		/**
		 * Shorthand to access the menu node within the model
		 * 
		 * @return 
		 */
		protected function get menu():XML {
			// #338 The model no longer holds head and script for the menu
			return (_xhtml) ? _xhtml.head.script.(@id == "model" && @type == "application/xml").menu[0] : null;
		}
		
		/**
		 * Link a tabbed view navigator to view states so that clicking on the navigator changes the view state automatically based on the selected tab and
		 * active view.  The stateMap parameter is an object where the keys are the states and the values are the view classes.
		 * 
		 * @param tabbedViewNavigator
		 * @param stateMap
		 */
		public function setNavStateMap(tabbedViewNavigator:TabbedViewNavigator, stateMap:Object):void {
			if (!_navStateMapInstances[tabbedViewNavigator]) _navStateMapInstances[tabbedViewNavigator] = new NavStateMap(this, tabbedViewNavigator);
			var navStateMap:NavStateMap = _navStateMapInstances[tabbedViewNavigator];
			
			navStateMap.setStateMap(stateMap);
		}
		
	}
	
}

import com.clarityenglish.bento.view.base.BentoView;

import flash.events.Event;
import flash.utils.Dictionary;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.StateChangeEvent;

import spark.components.TabbedViewNavigator;
import spark.components.ViewNavigator;
import spark.components.supportClasses.NavigationStack;
import spark.transitions.ViewTransitionDirection;

import caurina.transitions.Tweener;

import org.davekeen.transitions.PatchedSlideViewTransition;
import org.davekeen.util.ClassUtil;

class NavStateMap {
	
	private var view:BentoView;
	private var tabbedViewNavigator:TabbedViewNavigator;
	private var stateMap:Object;
	
	private var isTabbedViewNavigatorChange:Boolean;
	
	private var pushTransition:PatchedSlideViewTransition;
	private var popTransition:PatchedSlideViewTransition;
	
	public function NavStateMap(view:BentoView, tabbedViewNavigator:TabbedViewNavigator) {
		this.view = view;
		this.tabbedViewNavigator = tabbedViewNavigator;
		
		// Replace the default transition with our patched version (the built-in Flex one has a bug)
		pushTransition = new PatchedSlideViewTransition();
		pushTransition.direction = ViewTransitionDirection.LEFT;
		pushTransition.addEventListener(FlexEvent.TRANSITION_START, onTransitionStarted);
		pushTransition.addEventListener(FlexEvent.TRANSITION_END, onTransitionFinished);
		
		popTransition = new PatchedSlideViewTransition();
		popTransition.direction = ViewTransitionDirection.RIGHT;
		popTransition.addEventListener(FlexEvent.TRANSITION_START, onTransitionStarted);
		popTransition.addEventListener(FlexEvent.TRANSITION_END, onTransitionFinished);
		
		for each (var viewNavigator:ViewNavigator in tabbedViewNavigator.navigators) {
			viewNavigator.defaultPushTransition = pushTransition;
			viewNavigator.defaultPopTransition = popTransition;
		}
		
		// We update the state when the user clicks a tab.
		tabbedViewNavigator.addEventListener(Event.CHANGE, onNavigatorChange, false, 0, true);
		
		// We also need to listen for state changes on the view itself
		view.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onCurrentStateChange, false, 0, true);
		
		// And for added to stage in order to implement #584
		view.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
	}
	
	public function setStateMap(stateMap:Object):void {
		this.stateMap = stateMap;
	}
	
	private function onAddedToStage(event:Event):void {
		// gh#584 - the added to stage event is called every time (apart from the first time) that the navigator is shown.  In this case we forceably return the current navigator
		// to its initial state, as well as setting the state on the view.
		if (ClassUtil.getClass(tabbedViewNavigator.activeView) !== tabbedViewNavigator.activeView.navigator.firstView) {
			tabbedViewNavigator.activeView.navigator.popToFirstView();
			isTabbedViewNavigatorChange = true;
			view.currentState = findStateByViewClass(tabbedViewNavigator.activeView.navigator.firstView);
			isTabbedViewNavigatorChange = false;
		}
	}
	
	private function onNavigatorChange(event:Event):void {
		isTabbedViewNavigatorChange = true;
		
		var selectedView:Class = ClassUtil.getClass(tabbedViewNavigator.selectedNavigator.activeView);
		var state:String = findStateByViewClass(selectedView);
		if (state) view.currentState = state;
		
		isTabbedViewNavigatorChange = false;
	}
	
	private function onCurrentStateChange(event:StateChangeEvent):void {
		if (!isTabbedViewNavigatorChange) {
			var oldMap:Object = findMapByState(event.oldState), newMap:Object = findMapByState(event.newState);
			
			var navigationStack:NavigationStack = (tabbedViewNavigator.selectedNavigator) ? tabbedViewNavigator.selectedNavigator.mx_internal::navigationStack : null;
			if (oldMap && oldMap.stack && navigationStack && navigationStack.length > 1 && navigationStack.mx_internal::source[navigationStack.length - 2].viewClass === newMap.viewClass) {
				(tabbedViewNavigator.selectedNavigator as ViewNavigator).popView();
			} else if (newMap.stack) {
				(tabbedViewNavigator.selectedNavigator as ViewNavigator).pushView(newMap.viewClass);
			} else {
				// TODO: change tab
			}
		}
	}
	
	protected function onTransitionStarted(event:FlexEvent):void {
		Tweener.pauseAllTweens(); // #390
	}
	
	protected function onTransitionFinished(event:FlexEvent):void {
		view.callLater(Tweener.resumeAllTweens); // #390
		
		var selectedView:Class = ClassUtil.getClass(tabbedViewNavigator.selectedNavigator.activeView);
		var state:String = findStateByViewClass(selectedView);
		var map:Object = findMapByState(state);
		
		if (state) {
			// Set the state if it isn't already correct (if this transition was initiated by the view calling popView it won't be set yet)
			if (view.currentState != state) view.currentState = state;
		}
	}
	
	private function findStateByViewClass(viewClass:Class):String {
		for (var state:String in stateMap)
			if (viewClass === stateMap[state].viewClass)
				return state;
		
		return null;
	}
	
	private function findMapByState(state:String):Object {
		return stateMap[state];
	}
	
}