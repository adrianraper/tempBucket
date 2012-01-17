package {
	import flash.events.Event;
	import mx.flash.UIMovieClip;
	import flash.events.MouseEvent;
	
	[Event(name="writingSelected", type="flash.events.Event")]
	[Event(name="listeningSelected", type="flash.events.Event")]
	[Event(name="speakingSelected", type="flash.events.Event")]
	[Event(name="readingSelected", type="flash.events.Event")]
	public class CourseSelectorWidget extends UIMovieClip {
		
		public function CourseSelectorWidget() {
			
		}
		
		public function setCourse(course:String):void {
			switch (course) {
				case "writing":
					gotoAndStop(11);
					break;
				case "listening":
					gotoAndStop(2);
					break;
				case "speaking":
					gotoAndStop(6);
					break;
				case "reading":
					gotoAndStop(10);
					break;
			}
		}
		
		protected function gotoWriting(e:Event):void {
			dispatchEvent(new Event("writingSelected", true));
		}
		
		protected function gotoListening(e:Event):void {
			dispatchEvent(new Event("listeningSelected", true));
		}
		
		protected function gotoSpeaking(e:Event):void {
			dispatchEvent(new Event("speakingSelected", true));
		}
		
		protected function gotoReading(e:Event):void {
			dispatchEvent(new Event("readingSelected", true));
		}
		
	}
	
}