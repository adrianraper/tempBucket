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
		private var difficultyChanged:Boolean;
		
		public function UnitListItemRenderer() {
			super();
		}
		
		public function set difficultyExerciseFunction(value:Function):void {
			if (value == _difficultyExerciseFunctionChanged)
				return;
			
			_difficultyExerciseFunction = value;
			_difficultyExerciseFunctionChanged = true;
			difficultyChanged = true;
			
			invalidateProperties();
		}
		
		public override function set data(value:Object):void {
			super.data = value;
			
			difficultyChanged = true;
			
			invalidateProperties();
		}

		
		protected override function createChildren():void {
			super.createChildren();
			
			if (!difficultyRenderer) {
				difficultyRenderer = new DifficultyRenderer();
				difficultyRenderer.showLabel = false;
				difficultyRenderer.courseClass = "reading";
				addChild(difficultyRenderer);
			}
		}

		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_difficultyExerciseFunctionChanged) {
				_difficultyExerciseFunctionChanged = false;	
			}
			
			if (difficultyChanged) {
				difficultyChanged = false;
				
				if (_difficultyExerciseFunction != null)
					difficultyRenderer.data = _difficultyExerciseFunction(data);
			}
		}

		protected override function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			setElementSize(difficultyRenderer, 100, 10);
			setElementPosition(difficultyRenderer, messageDisplay.x + messageDisplay.textWidth + 5, messageDisplay.y - 2);
		}
		
	}
}