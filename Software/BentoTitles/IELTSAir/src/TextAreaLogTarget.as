package {
	import mx.core.mx_internal;
	import mx.logging.targets.LineFormattedTarget;
	
	import spark.components.TextArea;

	use namespace mx_internal;

	public class TextAreaLogTarget extends LineFormattedTarget {
		
		private var textArea:TextArea;
		
		public function TextAreaLogTarget(textArea:TextArea) {
			super();
			
			this.textArea = textArea;
		}

		mx_internal override function internalLog(message:String):void {
			textArea.text += message + "\n";
		}
		
	}
}