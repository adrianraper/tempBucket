package skins.ieltsair.zone.ui {
	import com.clarityenglish.ielts.view.zone.ui.DifficultyRenderer;
	
	import spark.components.IconItemRenderer;
	
	/**
	 * An extension of IconItemRenderer that also displays the difficulty chillies after the message
	 */
	public class UnitListItemRenderer extends IconItemRenderer {
		
		private var difficultyRenderer:DifficultyRenderer;

		private var _difficultyExerciseFunction:Function;
		private var _difficultyExerciseFunctionChanged:Boolean;
		private var _difficultyChanged:Boolean;
		
		private var _courseClass:String;
		private var _courseClassChanged:Boolean;
		
		public function UnitListItemRenderer() {
			super();
		}
		
		public function set difficultyExerciseFunction(value:Function):void {
			if (value == _difficultyExerciseFunctionChanged)
				return;
			
			_difficultyExerciseFunction = value;
			_difficultyExerciseFunctionChanged = true;
			_difficultyChanged = true;
			
			invalidateProperties();
		}
		
		public function set courseClass(value:String):void {
			_courseClass = value;
			_courseClassChanged = true;
			
			invalidateProperties();
		}
		
		public override function set data(value:Object):void {
			super.data = value;
			
			_difficultyChanged = true;
			
			invalidateProperties();
		}
		
		protected override function createChildren():void {
			super.createChildren();
			
			if (!difficultyRenderer) {
				difficultyRenderer = new DifficultyRenderer();
				difficultyRenderer.showLabel = false;
				difficultyRenderer.courseClass = _courseClass;
				addChild(difficultyRenderer);
			}
		}

		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_difficultyExerciseFunctionChanged) {
				_difficultyExerciseFunctionChanged = false;	
			}
			
			if (_difficultyChanged) {
				_difficultyChanged = false;
				
				if (_difficultyExerciseFunction != null)
					difficultyRenderer.data = _difficultyExerciseFunction(data);
			}
			
			if (_courseClassChanged) {
				_courseClassChanged = false;
				
				difficultyRenderer.courseClass = _courseClass;
			}
		}

		protected override function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			setElementSize(difficultyRenderer, 100, 10);
			setElementPosition(difficultyRenderer, messageDisplay.x + messageDisplay.textWidth + 5, messageDisplay.y - 2);
		}
		
	}
}