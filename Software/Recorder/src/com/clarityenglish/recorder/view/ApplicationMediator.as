/*
 Mediator - PureMVC
 */
package com.clarityenglish.recorder.view {
	import com.clarityenglish.recorder.ApplicationFacade;
	import com.clarityenglish.recorder.events.PartEvent;
	import com.clarityenglish.recorder.events.ResizeWindowEvent;
	import com.clarityenglish.recorder.events.AIRWindowEvent;
	import com.clarityenglish.recorder.model.AudioProxy;
	import com.clarityenglish.recorder.model.LocalConnectionProxy;
	import com.clarityenglish.recorder.view.*;
	import com.clarityenglish.recorder.view.waveform.events.RecorderEvent;
	import com.clarityenglish.recorder.view.waveform.events.WaveformEvent;
	import com.clarityenglish.recorder.view.waveform.WaveformMediator;
	import flash.system.ApplicationDomain;
	import mx.core.Application;
	//import flash.display.NativeWindow;
	//import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import gs.util.PlayerUtils;
	import mx.controls.Alert;
	import mx.controls.ProgressBarMode;
	import mx.events.CloseEvent;
	import mx.events.StateChangeEvent;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
	import mx.core.FlexGlobals;
	//import flash.system.ApplicationDomain;
	import org.davekeen.utils.ClassUtils;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	import com.clarityenglish.recorder.view.*;
	//import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * A Mediator
	 */
	public class ApplicationMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "ApplicationMediator";
		
		// NOTE:
		// I currently have this mediator performing several AIR specific duties. Which means that it won't compile
		// in the WebClarityRecorder project. So I need to push those up into the adaptor.
		
		private var stateBeforeProgress:String;
		
		private var recorderState:String;
		
		public function ApplicationMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			//MonsterDebugger.trace(this, "here I am");
			super(NAME, viewComponent);
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			applicationView.addEventListener(PartEvent.PART_ADDED, onPartAdded);
			applicationView.addEventListener(RecorderEvent.CHANGE_STATE, onChangeState);
			applicationView.addEventListener(RecorderEvent.HELP, onHelp);
			applicationView.addEventListener(RecorderEvent.WEBLINK, onWebLink);
			applicationView.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onCurrentStateChange);
			//applicationView.addEventListener(AIRWindowEvent.RELEASE_ALWAYS_IN_FRONT, onReleaseAlwaysInFront);
			
			// If this is an AIR application add closing and close listeners to the windowed application
			// No. You can't do this here as Event.Closing doesn't exist for non AIR compilation.
			//if (PlayerUtils.isAirApplication()) {
				//applicationView.parentApplication.addEventListener(Event.CLOSING, onClosing);
			//	applicationView.parentApplication.addEventListener(Event.CLOSE, onClose);
			//}
			
			applicationView.setCurrentState("record");
			
			// For testing
			//sendNotification(ApplicationFacade.COMPARE_TO, "U1_02ex_02.mp3");
		}
		
		private function onPartAdded(e:PartEvent):void {
			switch (e.instance) {
				case applicationView.recordWaveformView:
					facade.registerMediator(new WaveformMediator(applicationView.recordWaveformView, ApplicationFacade.RECORD_PROXY_NAME));
					break;
				case applicationView.modelWaveformView:
					facade.registerMediator(new WaveformMediator(applicationView.modelWaveformView, ApplicationFacade.MODEL_PROXY_NAME));
					break;
			}
		}
		
		private function get applicationView():ApplicationView {
			return viewComponent as ApplicationView;
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
			return ApplicationMediator.NAME;
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
					ApplicationFacade.WAV_ENCODE_START,
					ApplicationFacade.WAV_ENCODE_COMPLETE,
					ApplicationFacade.MP3_ENCODE_START,
					ApplicationFacade.MP3_ENCODE_PROGRESS,
					ApplicationFacade.MP3_ENCODE_COMPLETE,
					ApplicationFacade.MP3_LOAD_START,
					ApplicationFacade.MP3_LOAD_PROGRESS,
					ApplicationFacade.MP3_LOAD_COMPLETE,
					ApplicationFacade.COMPARE_TO,
					ApplicationFacade.COMPARE_STATE,
					ApplicationFacade.MP3_SAVE_COMPLETE,
					ApplicationFacade.PLAYING_COMPLETE,
					ApplicationFacade.RECORDING_STOPPED,
					ApplicationFacade.RELEASE_ALWAYS_ON_TOP,
					ApplicationFacade.NO_MICROPHONE,
					ApplicationFacade.GOT_MICROPHONE,
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
			//trace("appMediator." + note.getName());
			switch (note.getName()) {
				case ApplicationFacade.MP3_LOAD_START:
					stateBeforeProgress = applicationView.currentState;
					
					applicationView.setCurrentState("progress");
					
					applicationView.progressLabel.text = "Loading MP3...";
					applicationView.progressBar.indeterminate = false;
					applicationView.progressBar.setProgress(0, 100);
					break;
				case ApplicationFacade.MP3_LOAD_COMPLETE:
					applicationView.setCurrentState(stateBeforeProgress);
					break;
				case ApplicationFacade.WAV_ENCODE_START:
					stateBeforeProgress = applicationView.currentState;
					
					// If this is AIR bring the window to the front.
					// See Compare for note about how this is done.
					// Since this is pure AIR, ask the application to do it (through the adaptor)
					if (PlayerUtils.isAirApplication()) {
						//trace("mediator knows it is AIR");
						applicationView.parentApplication.setAlwaysInFront();
						//window = applicationView.stage.nativeWindow;
						//window.alwaysInFront = true; 
						//window.restore();
						//window.activate();
						// You can't switch this off until the save dialog is up.
						// So that is done through listening for Event.Select and Event.Cancel
						//window.alwaysInFront = false;
					}
					
					applicationView.setCurrentState("progress");
					
					applicationView.progressLabel.text = "Processing data...";
					applicationView.progressBar.indeterminate = true;
					break;
				case ApplicationFacade.WAV_ENCODE_COMPLETE:
					break;
				case ApplicationFacade.MP3_ENCODE_START:
					applicationView.progressLabel.text = "Preparing MP3...";
					applicationView.progressBar.indeterminate = false;
					applicationView.progressBar.setProgress(0, 100);
					break;
				case ApplicationFacade.MP3_LOAD_PROGRESS:
				case ApplicationFacade.MP3_ENCODE_PROGRESS:
					applicationView.progressBar.setProgress(note.getBody().bytesLoaded, note.getBody().bytesTotal);
					break;
				case ApplicationFacade.MP3_ENCODE_COMPLETE:
					applicationView.setCurrentState(stateBeforeProgress);
					
					if (!PlayerUtils.isAirApplication()) {
						Alert.show("Click OK to save your MP3 file", "Save", Alert.OK, applicationView, function(e:CloseEvent):void {
							if (e.detail == Alert.OK) {
								var audioProxy:AudioProxy = facade.retrieveProxy(note.getType()) as AudioProxy;
								audioProxy.saveMP3Data(note.getBody() as ByteArray);
							}
						} );
					}
					break;
				case ApplicationFacade.MP3_SAVE_COMPLETE:
					break;
				case ApplicationFacade.COMPARE_TO:
					// At the point the COMPARE_TO notification is received, the application is in 'progress' state, so instead of changing the state itself
					// change the state it returns to after the load is complete.
					stateBeforeProgress = "compare";
					
					// If this is AIR bring the window to the front.  Note that in AIR 2 RC 1 this has no effect, even though it returns true (which apparently
					// means it has suceeded). alwaysInFront does work.
					//trace("I am AIR=" + PlayerUtils.isAirApplication());
					if (PlayerUtils.isAirApplication()) {
						//applicationView.parentApplication.bringToFront();
						applicationView.parentApplication.setAlwaysInFront();
						/*
						var window:NativeWindow = applicationView.stage.nativeWindow;
						//var bringToBackSuccess:Boolean = window.orderToBack(); // this works
						//window.alwaysInFront = true; // this works
						// How about if you delay these in case the mouse click on the browser is still forcing that window to stay on top?
						// No, because it doesn't even bring it in front of windows that aren't active
						// Messy but seems to work, set alwaysInFront to true, then activate then alwaysInFront back to false.
						var alwaysInFrontSuccess:Boolean = window.alwaysInFront = true; // this works
						window.restore(); // this doesn't work
						window.activate(); // this doesn't work
						//var bringToFrontSuccess:Boolean = window.orderToFront(); // this doesn't work
						window.alwaysInFront = false;
						//window.maximize(); // this works
						//trace("bring to front=" + bringToFrontSuccess);
						//trace("always in front=" + alwaysInFrontSuccess);
						//applicationView.stage["nativeWindow"].orderToFront();
						*/
					}
					
					break;
				case ApplicationFacade.COMPARE_STATE:
					// This notification is asking us if the view is currently in a particular state
					// I think this is all wrong. But DK given it the once over.
					if (applicationView.currentState == note.getBody() as String) {
						var localConnectionProxy:LocalConnectionProxy = facade.retrieveProxy(LocalConnectionProxy.NAME) as LocalConnectionProxy;
						localConnectionProxy.compareIsOpen();
					}
					break;
				case ApplicationFacade.PLAYING_COMPLETE:
					// Tell the world that the playing is over.
					localConnectionProxy = facade.retrieveProxy(LocalConnectionProxy.NAME) as LocalConnectionProxy;
					localConnectionProxy.playingComplete();
					break;
				case ApplicationFacade.RECORDING_STOPPED:
					// Tell the world that the recording is over.
					localConnectionProxy = facade.retrieveProxy(LocalConnectionProxy.NAME) as LocalConnectionProxy;
					localConnectionProxy.recordingComplete();
					break;

				case ApplicationFacade.RELEASE_ALWAYS_ON_TOP:
					if (PlayerUtils.isAirApplication()) {
						applicationView.parentApplication.releaseAlwaysInFront();
						// I also want to turn compare mode off. But this is not too neat as you are mixing up two actions here.
						// It currently works as this notification is only sent when Orchid leaves an exericse that comparison was done on.
						applicationView.setCurrentState("record");
					}
					break;
					
				case ApplicationFacade.NO_MICROPHONE:
					applicationView.setCurrentState("normal");
					break;
				
				case ApplicationFacade.GOT_MICROPHONE:
					applicationView.setCurrentState("record");				
					break;
					
				default:
					break;		
			}
		}
		
		private function onChangeState(e:RecorderEvent):void {
			applicationView.currentState = e.data as String;
		}
		
		//private function onReleaseAlwaysInFront(e:AIRWindowEvent):void {
		//	// It is also nice to stop the recorder being always on top if you are closing the compare function - I think!
		//	applicationView.dispatchEvent(new AIRWindowEvent(AIRWindowEvent.RELEASE_ALWAYS_IN_FRONT, true));
		//}
		
		private function onCurrentStateChange(e:StateChangeEvent):void {
			// Dispatch an event that will bubble up to the top level component - in the web app this will be ignored, in the AIR app this will be caught and
			// acted on.
			switch (e.newState) {
				case "record":
					if (recorderState != "record") {
						applicationView.dispatchEvent(new ResizeWindowEvent(ResizeWindowEvent.RESIZE_HEIGHT_BY_RATIO, 0.5, true));
					}
					recorderState = e.newState;
					break;
				case "compare":
					if (recorderState != "compare")
						applicationView.dispatchEvent(new ResizeWindowEvent(ResizeWindowEvent.RESIZE_HEIGHT_BY_RATIO, 2, true));
						
					recorderState = e.newState;
					break;
			}
		}
		/*
		 * Mediator can't do AIR specific things (like Event.Closing)
		private function onClosing(e:Event):void {
			trace("app closing");
			sendNotification(ApplicationFacade.CLOSE_RECORDER);
		}
		*/
		private function onClose(e:Event):void {
			trace("mediator app onClose");		
			// It might be too late to do this as the object might be killed already.
			//sendNotification(ApplicationFacade.CLOSE_RECORDER);
		}
		
		private function onHelp(e:RecorderEvent):void {
			// display the help file
			//var applicationDomain:ApplicationDomain = new ApplicationDomain();
			//trace("help me from " + FlexGlobals.topLevelApplication);
			/*
				var url:String = browserManager.url;
				baseURL = browserManager.base;
				fragment = browserManager.fragment;                
				previousURL = e.lastURL;                

				fullURL = mx.utils.URLUtil.getFullURL(url, url);
				port = mx.utils.URLUtil.getPort(url);
				protocol = mx.utils.URLUtil.getProtocol(url);
				serverName = mx.utils.URLUtil.getServerName(url);
				isSecure = mx.utils.URLUtil.isHttpsURL(url);  
			*/
			trace("help me from " + applicationView.parentApplication.helpFolder);
			var url:String = applicationView.parentApplication.helpFolder + "RecorderHelp.html";
			var request:URLRequest = new URLRequest(url);
			try {
				navigateToURL(request, '_blank'); // second argument is target
			} catch (e:Error) {
				trace("Error occurred!");
			}
		}
		private function onWebLink(e:RecorderEvent):void {
			var url:String = "http://www.ClarityEnglish.com";
			var request:URLRequest = new URLRequest(url);
			try {
				navigateToURL(request, '_blank'); // second argument is target
			} catch (e:Error) {
				trace("Error occurred!");
			}
		}
		
	}
}
