package com.clarityenglish.bento.vo.content.transform {
	
	[RemoteClass(alias="com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform")]
	public class ProgressSummaryTransform extends XmlTransform {
		private var progressWidgetArray:Array = ["group", "video", "audio", "exercise", "pdf"];
		
		override public function transform(xml:XML):void {
			namespace xhtml = "http://www.w3.org/1999/xhtml";
			use namespace xhtml;
			
			for each (var course:XML in xml..script.(@id == "model")..course) {
				var courseStats:Stats = new Stats();
				
				for each (var unit:XML in course..unit) {
					var unitStats:Stats = new Stats();
					
					// change from unit..exercise to unit.exercise for nested exercise node in cp
					for each (var exercise:XML in unit.exercise) {
						if (exercise.hasOwnProperty("@type") && exercise.@type == "group") {
							unitStats.add(getNestedExerciseStats(exercise));
						} else {
							unitStats.add(getExerciseStats(exercise));
						}
					}
					
					unitStats.writeToNode(unit);
					courseStats.add(unitStats);
				}
				
				courseStats.writeToNode(course);
			}
		}
		
		private function getNestedExerciseStats(nestedExercise:XML):Stats {
			if (nestedExercise.children().(localName() == "exercise").length() != 0) {
				if (hasProgress(nestedExercise)) {
					var nestedExericseStats:Stats = new Stats();
					for each (var exercise:XML in nestedExercise.children().(localName() == "exercise") ) {
						nestedExericseStats.add(getNestedExerciseStats(exercise));
					}
					
					nestedExericseStats.writeToNode(nestedExercise);
					return nestedExericseStats;
				} else if (!hasProgress(nestedExercise)) {
					return new Stats();
				}
			}
			
			return getExerciseStats(nestedExercise);
		}
		
		private function hasProgress(exercise:XML):Boolean {
			if (progressWidgetArray.indexOf(String(exercise.@type)) >= 0) {
				return true;
			} else if (exercise.@type == "selector") {
				if (exercise.@src == "video") {
					return false;
				} else {
					return true;
				}
			}
			
			return false;
		}
		
		private function getExerciseStats(exercise:XML):Stats {
			namespace xhtml = "http://www.w3.org/1999/xhtml";
			use namespace xhtml;
			
			var stats:Stats = new Stats();
			
			stats.of += 1;
			if (exercise.hasOwnProperty("@done") && Number(exercise.@done) > 0) {
				stats.count += 1;
				stats.totalDone += Number(exercise.@done);
			}
			
			for each (var score:XML in exercise.score) {
				// #232. #161. Don't let non-marked exercise scores impact the average
				if (score.hasOwnProperty("@score") && Number(score.@score) >= 0) {
					stats.totalScore += Number(score.@score);
					stats.scoredCount += 1;
				}
				
				// #318. 0 duration is for offline exercises (downloading a pdf for instance) so ignore it.
				if (score.hasOwnProperty("@duration") && Number(score.@duration) > 0) {
					stats.durationCount += 1;
					stats.duration += Number(score.@duration);
				}
			}
			
			return stats;
		}
		
	}
}

class Stats {
	
	public var of:Number = 0;
	public var count:Number = 0;
	public var totalDone:Number = 0;
	public var totalScore:Number = 0;
	public var scoredCount:Number = 0;
	public var durationCount:Number = 0;
	public var duration:Number = 0;
	
	public function add(stats:Stats):void {
		of += stats.of;
		count += stats.count;
		totalDone += stats.totalDone;
		totalScore += stats.totalScore;
		scoredCount += stats.scoredCount;
		durationCount += stats.durationCount;
		duration += stats.duration;
	}
	
	public function get averageScore():Number {
		return (scoredCount > 0) ? Math.floor(totalScore / scoredCount) : 0;
	}
	
	public function get averageDuration():Number {
		return (durationCount > 0) ? Math.floor(duration / durationCount) : 0;
	}
	
	public function get coverage():Number {
		return (of > 0) ? Math.floor(count / of * 100) : 0;
	}
	
	public function writeToNode(node:XML):void {
		node.@of = of;
		node.@count = count;
		node.@totalDone = totalDone;
		node.@totalScore = totalScore;
		node.@scoredCount = scoredCount;
		node.@durationCount = durationCount;
		node.@duration = duration;
		node.@averageScore = averageScore;
		node.@averageDuration = averageDuration;
		node.@coverage = coverage;
	}
	
}