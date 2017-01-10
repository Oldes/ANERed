package org.redlang.events
{
	import flash.events.Event;
	
	public class RedPrintEvent extends Event
	{
		public static const RED_PRINT:String = "RED_PRINT";
		private var mData:String;
		
		public function RedPrintEvent(type:String, value:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			mData = value;
			super(type, bubbles, cancelable);
		}
		
		public final function get data():String {
			return mData;
		}
	}
}