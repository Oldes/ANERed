package org.redlang
{
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	import flash.events.Event;
	import flash.events.StatusEvent;
	
	import org.redlang.events.RedPrintEvent;
	
	public class Red extends EventDispatcher
	{
		
		private static var _instance:Red;
		private var extContext:ExtensionContext;
		
		
		public function Red( enforcer:SingletonEnforcer ) {
			super();
			
			extContext = ExtensionContext.createExtensionContext( "org.redlang.Red", "" );
			
			if ( !extContext ) {
				throw new Error( "Red extension is not supported on this platform." );
			}
			extContext.addEventListener( StatusEvent.STATUS, onStatusHandler );
		}
		
		/** Extension is supported on Android devices. */
		public static function get isSupported() : Boolean
		{
			return Capabilities.manufacturer.indexOf("Win") != -1;
		}
		
		
		private function init():void {
			extContext.call( "Init" );
		}

		private function onStatusHandler( event:StatusEvent ):void {
			//trace("onStatusHandler: " + event)
			var e:Event;
			switch(event.code) {
				case RedPrintEvent.RED_PRINT:
					e = new RedPrintEvent(event.code, event.level);
					break;
			}
			if(e) {
				this.dispatchEvent(e);
			}
		}

		
		/**
		 * Cleans up the instance of the native extension. 
		 */		
		public function dispose():void { 
			extContext.dispose(); 
		}
		
		
		public static function get instance():Red {
			if ( !_instance ) {
				_instance = new Red( new SingletonEnforcer() );
				_instance.init();
			}
			return _instance;
		}
		
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function redDo(code:String = ""):Object { return extContext.call("redDo", code); }
		public function redGetLastError():String { return extContext.call("redGetLastError") as String; }
	}
}

class SingletonEnforcer {}