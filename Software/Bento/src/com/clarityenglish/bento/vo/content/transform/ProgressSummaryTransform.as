package com.clarityenglish.bento.vo.content.transform {
	import mx.states.State;
	
	[RemoteClass(alias="com.clarityenglish.bento.vo.content.transform.ProgressSummaryTransform")]
	public class ProgressSummaryTransform extends XmlTransform {
		private var progressWidgetArray:Array = ["group", "video", "audio", "exercise", "pdf"];
		
		private var exerciseID:Number;
		
		public function ProgressSummaryTransform(value:Number = -1) {
			exerciseID = value;
		}
		
		override public function transform(xml:XML):void {
			namespace xhtml = "http://www.w3.org/1999/xhtml";
			use namespace xhtml;
			
			if (exerciseID > -1) {
				var thisExercise:XML = xml..script.(@id == "model")..exercise.(@id == String(exerciseID))[0];
				var exerciseParent:XML = thisExercise.parent();
				partialChangeStats(thisExercise, exerciseParent);
			} else {
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
		}
		
		private function partialChangeStats(thisXML:XML, parentXML:XML):void {
			var thisXML:XML = thisXML;
			var thisLastScore:XML = thisXML.children()[thisXML.children().length() - 1];
			var isFirstScore:Boolean = (thisXML.score.length() == 1)? true : false;
			var parentXML:XML = parentXML;
			var traceParentXML:XML = parentXML;
			while(traceParentXML.name() != "menu") {
				traceParentXML = traceParentXML.parent();
			}
			
			while(parentXML.name() != "menu") {
				if (isFirstScore) {
					parentXML.@count = Number(parentXML.@count) + 1;
					parentXML.@coverage = Math.floor(Number(parentXML.@count) / Number(parentXML.@of) * 100)
				}
				parentXML.@totalDone = Number(parentXML.@totalDone) + 1;
				if (thisLastScore.hasOwnProperty("@score") && Number(thisLastScore.@score) >= 0) {
					parentXML.@totalScore = Number(parentXML.@totalScore) + Number(thisLastScore.@score);
					parentXML.@scoredCount = Number(parentXML.@scoredCount) + 1;
				}
				if (thisLastScore.hasOwnProperty("@duration") && Number(thisLastScore.@duration) >= 0) {
					parentXML.@durationCount = Number(parentXML.@durationCount) + 1;
					parentXML.@duration = Number(parentXML.@duration) + Number(thisLastScore.@duration);
				}
				parentXML.@averageScore = (Number(parentXML.@scoredCount) > 0) ? Math.floor(Number(parentXML.@totalScore) / Number(parentXML.@scoredCount)) : 0;
				parentXML.@averageDuration = (Number(parentXML.@durationCount) > 0) ? Math.floor(Number(parentXML.@duration) / Number(parentXML.@durationCount)) : 0;
				
				parentXML = parentXML.parent();
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

			// #1544 for exercise that is disabled we should not count it in the total number of exercises.
            if (!(exercise.attribute("enabledFlag").length() > 0 && exercise.@enabledFlag & 8)) {
                stats.of += 1;
            }

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