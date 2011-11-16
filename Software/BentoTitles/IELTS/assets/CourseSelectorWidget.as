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
					gotoAndPlay(11);
					break;
				case "listening":
					gotoAndPlay(2);
					break;
				case "speaking":
					gotoAndPlay(6);
					break;
				case "reading":
					gotoAndPlay(10);
					break;
			}
		}
		
		protected function gotoWriting(e:Event):void {
			gotoAndPlay(11);
			dispatchEvent(new Event("writingSelected", true));
		}
		
		protected function gotoListening(e:Event):void {
			gotoAndPlay(2);
			dispatchEvent(new Event("listeningSelected", true));
		}
		
		protected function gotoSpeaking(e:Event):void {
			gotoAndPlay(6);
			dispatchEvent(new Event("speakingSelected", true));
		}
		
		protected function gotoReading(e:Event):void {
			gotoAndPlay(10);
			dispatchEvent(new Event("readingSelected", true));
		}
		
	}
	
}