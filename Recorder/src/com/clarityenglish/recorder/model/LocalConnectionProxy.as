/*
Proxy - PureMVC
*/
package com.clarityenglish.recorder.model {
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	//import nl.demonsters.debugger.MonsterDebugger;

	/**
	 * A proxy
	 */
	public class LocalConnectionProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "LocalConnectionProxy";
		
		private var receiveConn:LocalConnection;
		
		private var localConnectionClient:LocalConnectionClient;
		
		public function LocalConnectionProxy(data:Object = null) {
			super(NAME, data);
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			setupLocalConnection();
		}
		
		private function setupLocalConnection():void {
			//MonsterDebugger.trace(this, 'setting up ClarityRecorder localConnection');
			receiveConn = new LocalConnection();
			receiveConn.allowDomain('*');
			
			localConnectionClient = new LocalConnectionClient(facade, receiveConn);
			receiveConn.client = localConnectionClient;
			
			receiveConn.addEventListener(StatusEvent.STATUS, rcStatusChanged);
			
			try {
				// Set yourself up with a connection string that other people must use
				// app#com.ClarityEnglish.AIRRecorder.AC4376BDF30D9E11E723E5E1E39BF2723543AE52.1:clarityRecorder
				// maybe specifiying _ as the first characters gets round this. 
				receiveConn.connect("_clarityRecorder");
			} catch (error:ArgumentError) {
				trace("localConnection setup failure, " + error.message);
				receiveConn = undefined;
			}
			
			if (receiveConn) {
				// tell anyone listening that you are up and running
				receiveConn.send("_clarityAPO", "onLoad");
				// v4.0.1.4 Also tell the badger that might have launched you that you are now up and running
				//receiveConn.send("_trace", "myTrace", "Clarity Recorder starting up", 0);
				receiveConn.send("_clarityBadger", "onClarityRecorderLoaded");
				//trace("4.0.1.4. Clarity Recorder lc domain=" + receiveConn.domain);
			}
			
		}
		
		private function rcStatusChanged(event:StatusEvent):void {
			trace("rcStatusChanged: " + event);
			//MonsterDebugger.trace(this, event.level);
		}
		
		// Also need to add the following function to tell anyone that I am closing down
		// Called from onClosing event handler in AIRClarityRecorder.mxml
		// Is there time from this being sent before the app is shut?
		// It seems to work when I run it in debug mode, but not as a full AIR app.
		public function recorderClosing():void {
			trace("tell the world I am closing");
			if (receiveConn) {
				receiveConn.send("_clarityAPO", "recorderClosed");
				receiveConn.send("_trace", "myTrace", "recorder is closing", 0);
			}
		}
		
		// Called from the application view if the state is compare
		public function compareIsOpen():void {
			if (receiveConn) {
				receiveConn.send("_clarityAPO", "openForCompare");		
			}
		}
		
		// v3.4 Tell anyone when recording and playing are complete. This means that other apps don't need
		// a timer anymore. You would only use recordingComplete if you are controlling the Recorder directly. Still.
		public function recordingComplete():void {
			if (receiveConn) {
				receiveConn.send("_clarityAPO", "recordingComplete");
			}
		}
		public function playingComplete():void {
			if (receiveConn) {
				//trace("send playingComplete on localConn");
				receiveConn.send("_clarityAPO", "playingComplete");
			}
		}
		
	}
	
}

import com.clarityenglish.recorder.ApplicationFacade;
import com.clarityenglish.recorder.Constants;
import flash.net.LocalConnection;
import org.puremvc.as3.multicore.interfaces.IFacade;
import com.clarityenglish.recorder.model.AudioProxy;
//import nl.demonsters.debugger.MonsterDebugger;
	
class LocalConnectionClient {
	
	private var facade:IFacade;
	
	private var audioProxy:AudioProxy;
	
	private var receiveConn:LocalConnection;
	
	public function LocalConnectionClient(facade:IFacade, receiveConn:LocalConnection) {
		this.facade = facade;
		this.receiveConn = receiveConn;
		
		audioProxy = facade.retrieveProxy(ApplicationFacade.RECORD_PROXY_NAME) as AudioProxy;
	}
	
	public function getActive():void {
		trace("Someone asked if I was active");
		// I don't need to do anything as the localConnection will automatically respond with a status
		// which is all the other end needs.
	}
	
	public function getVersion():void {
		trace("Someone asked for my version");
		
		if (receiveConn) {
			receiveConn.send("_clarityAPO", "setVersion", Constants.VERSION_NUMBER);
			// The following is an obsolete method used for legacy apps
			//receiveConn.send("_clarityAPO", "recorderV2");
		}
	}
	
	public function cmdPlay(startPosition:Number = 0):void {
		trace("someone asked me to start play");
		audioProxy.play();
	}
	
	public function cmdPause():void {
		audioProxy.pause();
	}
	
	public function cmdStop():void {
		audioProxy.stop();
	}
	
	public function cmdRecord():void {
		trace("someone asked me to start recording");
		audioProxy.record(true);
	}
	
	public function cmdSave(filename:String = undefined):void {
		// This doesn't currently need to support a filename being passed in
		audioProxy.encodeSamplesToMP3();
	}
	
	public function cmdCompareTo(filename:String = undefined):void {
		trace("someone asked me to open " + filename);
		// Nothing to do if you are trying to compare to an empty file.
		// Although I suppose you could clear out the existing file if there is one...
		if (filename) {
			facade.sendNotification(ApplicationFacade.COMPARE_TO, filename);
		}
	}
	
	// If you are asked, and you are showing the compare mode, reply that you are open
	public function compareIfOpen():void {
		trace("someone asked if compare is currently open");
		//MonsterDebugger.trace(this, 'someone asked if compare is currently open');
		// If I knew how to get at the view I could do this.
		// Perhaps I have to send a notification which will then end up coming back to here??
		// No, this is completely misunderstanding proxies and facades!
		facade.sendNotification(ApplicationFacade.COMPARE_STATE, "compare");
		//if (applicationView.currentState=="compare") {
		//	receiveConn.send("_clarityAPO", "openForCompare");
		//}
	}
	public function cmdReleaseAlwaysOnTop():void {
		trace("someone asked me to release alwaysOnTop");
		facade.sendNotification(ApplicationFacade.RELEASE_ALWAYS_ON_TOP);
	}
	
}