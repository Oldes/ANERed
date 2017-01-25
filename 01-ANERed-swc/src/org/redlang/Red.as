package org.redlang
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	import flash.utils.setTimeout;

	import flash.events.Event;
	import flash.events.StatusEvent;
	
	import flash.ui.Keyboard;
	
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import org.redlang.events.RedPrintEvent;
	
	public class Red extends Sprite
	{
		
		private static var _instance:Red;
		private var extContext:ExtensionContext;

		public var tfOutput:TextField;
		public var tfInput:TextField;
		
		public var history:Vector.<String> = new Vector.<String>();
		public var historyPosition:int = -1;
		
		private var lastCode:String;
		public var lastResult:*;
		public var lastResultType:int;
		
		public var tFormatInput:TextFormat  = new TextFormat("Lucida Console", 12, 0x990000, false);
		public var tFormatOutput:TextFormat = new TextFormat("Lucida Console", 11, 0x000000, false);
		public var tFormatResult:TextFormat = new TextFormat("Lucida Console", 12, 0x227700, false);
		public var tFormatPrompt:TextFormat = new TextFormat("Lucida Console", 12, 0x330000, true);
		public var tFormatError:TextFormat = new TextFormat("Lucida Console", 11, 0xFF0000, false);
		
		public function Red( enforcer:SingletonEnforcer ) {
			super();
			extContext = ExtensionContext.createExtensionContext( "org.redlang.Red", "" );
			
			if ( !extContext ) {
				throw new Error( "Red extension is not supported on this platform." );
			}
			extContext.addEventListener( StatusEvent.STATUS, onStatusHandler );
			
			tfOutput = new TextField();
			tfOutput.wordWrap = true;
			tfOutput.defaultTextFormat = tFormatOutput;
			
			tfInput = new TextField();
			tfInput.border = true;
			tfInput.borderColor = 0xFF0000;
			tfInput.backgroundColor = 0xFFF0F0;
			tfInput.y = tfOutput.height;
			tfInput.type = TextFieldType.INPUT;
			tfInput.background = true; 
			tfInput.defaultTextFormat = new TextFormat("Lucida Console", 13, 0xFF0000);
			tfInput.addEventListener(KeyboardEvent.KEY_DOWN, onInputCapture);

			addChild(tfOutput);
			addChild(tfInput);
			//stage.focus = tfInput;
		}
		
		/** Extension is supported on Windows devices. */
		public static function get isSupported() : Boolean
		{
			return Capabilities.manufacturer.indexOf("Win") != -1;
		}
		
		private function init():void {
			extContext.call( "Init" );
			redRegisterCallbacks(this);
		}
		
	
		public function resize(width:Number, height:Number):void {
			tfOutput.width = tfInput.width = width;
			tfOutput.height = tfInput.y = height - 20;
		}
		
		public function print(value:Object):void {
			printFormated(""+value, tFormatOutput);
		}
		
		public function printFormated(value:String, format:TextFormat):void {
			var n:int = tfOutput.text.length - 1;
			tfOutput.appendText(value);
			tfOutput.setTextFormat(format, n, n + value.length);
			tfOutput.scrollV = tfOutput.maxScrollV;
		}
		
		public function doRed(code:String):void {
			if (lastCode != code) {
				historyPosition = history.length;
				history.push(code);
			}
			lastCode = code;
			trace(">> " + code);
			printFormated(">> ", tFormatPrompt);
			printFormated(code +"\n", tFormatInput);
			setTimeout(doRedCommand, 1, code); //using delay to be able see input command if processing of the command is blocking
		}
		private function doRedCommand(code:String):void {
			lastResultType = -1;
			var result:Object = redDo(code)
			trace("lastResultType: " + lastResultType);
			//trace("Result type: " + getQualifiedClassName(result));
			switch(lastResultType) {
				case 2: //RED_TYPE_UNSET
					break; //do nothing
				case -1: //error?
					printFormated(result + "\n", tFormatError);
					break;
				default:
					printFormated("== ", tFormatPrompt);
					printFormated(result + "\n", tFormatResult);
			}
		}

		public function onInputCapture(event:KeyboardEvent):void 
        { 
			switch(event.keyCode) {
				case Keyboard.ENTER:
					doRed(tfInput.text);
					tfInput.text = "";
					break;
				case Keyboard.DOWN:
					if (historyPosition>=0 && historyPosition < history.length-1) {
						historyPosition++;
						tfInput.text = history[historyPosition];
						tfInput.setSelection(tfInput.text.length, tfInput.text.length);
					}
					break;
				case Keyboard.UP:
					if (historyPosition > 0) {
						historyPosition--;
						tfInput.text = history[historyPosition];
						tfInput.setSelection(tfInput.text.length, tfInput.text.length);
					}
					break;	
					
			}
        } 

		private function onStatusHandler( event:StatusEvent ):void {
			//trace("onStatusHandler: " + event)
			var e:Event;
			switch(event.code) {
				case RedPrintEvent.RED_PRINT:
					tfOutput.appendText(event.level);
					tfOutput.scrollV = tfOutput.maxScrollV;
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
				trace("init done");
			}
			return _instance;
		}
		
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function redDo(code:String = "", convert:Boolean=false):Object { return extContext.call("redDo", code, convert) as Object; }
		public function redGetLastError():String { return extContext.call("redGetLastError") as String; }
		public function redDoEventLoop(e:Event = null):void { extContext.call("redDoEventLoop"); }
		public function redRegisterCallbacks(callbacks:*):int {
			return extContext.call("redRegisterCallbacks", callbacks) as int;
		}
	}
}

class SingletonEnforcer {}