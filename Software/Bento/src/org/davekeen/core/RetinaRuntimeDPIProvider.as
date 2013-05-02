package org.davekeen.core {
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.RuntimeDPIProvider;
	
	public class RetinaRuntimeDPIProvider extends RuntimeDPIProvider {
		
		public function RetinaRuntimeDPIProvider() {
			super();
		}
		
		override public function get runtimeDPI():Number {
			if (Capabilities.os.indexOf("iPad") > -1) {
				if (Capabilities.screenResolutionX > 1500) {
					return DPIClassification.DPI_320;
				}
			}
			return DPIClassification.DPI_160;
		}
	}
}
