package org.davekeen.util {
	/**
	 * @private 
	 * @author Dave Keen
	 */
	public class Closure extends Object {
		
		public static function create(context:Object, func:Function, ... pms):Function {
			var f:Function = function():* {
				var target:* = arguments.callee.target;
				var func:* = arguments.callee.func;
				var params:* = arguments.callee.params;
				var len:Number = arguments.length;
				var args:Array = new Array(len);
				for (var i:uint=0; i < len; i++)
					   args[i] = arguments[i];

				args["push"].apply(args, params);
				
				return func.apply(target, args);
			};
	   
			var _f:Object = f;
			
			_f.target = context;
			_f.func = func;
			_f.params = pms;
			
			return f;
		}
	}
	
}
