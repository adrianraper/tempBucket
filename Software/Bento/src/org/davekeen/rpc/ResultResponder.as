package org.davekeen.rpc {
	import mx.rpc.IResponder;

	/**
	 * An alternative implementation of AsyncResponder that allows the fault handler to be null
	 * 
	 * @author Dave Keen
	 */
	public class ResultResponder implements IResponder {

		private var _resultHandler:Function;
		private var _faultHandler:Function;
		private var _token:Object;

		public function ResultResponder(result:Function, fault:Function = null, token:Object = null) {
			super();

			_resultHandler = result;
			_faultHandler = fault;
			_token = token;
		}

		public function result(data:Object):void {
			_resultHandler(data, _token);
		}

		public function fault(info:Object):void {
			if (_faultHandler != null) _faultHandler(info, _token);
		}

	}

}
