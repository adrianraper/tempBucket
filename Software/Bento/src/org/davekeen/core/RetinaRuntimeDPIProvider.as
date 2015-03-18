package org.davekeen.core {
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.RuntimeDPIProvider;
	
	public class RetinaRuntimeDPIProvider extends RuntimeDPIProvider {
		
		public function RetinaRuntimeDPIProvider() {
			super();
		}
		
		override public function get runtimeDPI():Number {
			if (Capabilities.os.indexOf("Windows") != -1) {
				return DPIClassification.DPI_160;
			}
			if (Capabilities.screenResolutionX > 1500) {
				return DPIClassification.DPI_320;
			} else {
				return DPIClassification.DPI_160;
			}
		}
	}
}
