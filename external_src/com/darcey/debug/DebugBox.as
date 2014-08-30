package com.darcey.debug
{
	// ----------------------------------------------------------------------------------------------------
	import com.bit101.components.TextArea;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;

	// ----------------------------------------------------------------------------------------------------

	
	// ----------------------------------------------------------------------------------------------------
	public class DebugBox
	{
		private var stage:Stage;
		private var container:Sprite;
		private var grabBar:Sprite;
		public var txtArea:TextArea;
		private var ctrlKeyDown:Boolean = false;
		private var shiftKeyDown:Boolean = false;
		private var tf:TextFormat;
		private var txt:TextField;
		
		public function DebugBox(stage:Stage,container:Sprite,w:Number = 300,h:Number = 200,visibleByDefault:Boolean=true)
		{
			this.stage = stage;
			this.container = container;
			
			// Top bar
			grabBar = new Sprite();
			grabBar.graphics.beginFill(0x333333,1);
			grabBar.graphics.drawRect(0,0,w,20);
			grabBar.graphics.endFill();
			container.addChild(grabBar);
			grabBar.buttonMode = true;
			grabBar.useHandCursor = true;
			grabBar.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			grabBar.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			grabBar.addEventListener(MouseEvent.MOUSE_OUT,mouseUpHandler);
			stage.addEventListener(Event.MOUSE_LEAVE,mouseStageLeaveHandler);
			
			// Top bar title
			tf = new TextFormat();
			tf.size = 11;
			tf.color = 0xFFFFFF;
			//tf.font = "PF Ronda Seven";
			
			txt = new TextField();
			txt.embedFonts = false;
			txt.width = w - 5;
			txt.height = h - 2;
			txt.antiAliasType = AntiAliasType.ADVANCED;
			txt.selectable = false;
			txt.text = "DebugBox v1 - Click here to drag";
			txt.defaultTextFormat = tf;
			txt.setTextFormat(tf);
			txt.mouseEnabled = false;
			container.addChild(txt);
			
			
			// Debug text box
			txtArea = new TextArea();
			txtArea.y = grabBar.y + grabBar.height;
			txtArea.editable = false;
			txtArea.width = w;
			txtArea.height = h;
			container.addChild(txtArea);
			
			// Show help
			help();
			
			// Handle visibility
			container.visible = visibleByDefault;
			
			// Listen for key presses to show debug box
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
		}
		// ----------------------------------------------------------------------------------------------------
		
		
		// ----------------------------------------------------------------------------------------------------
		public function add(str:String):void
		{
			txtArea.text += str + "\n";
		}
		// ----------------------------------------------------------------------------------------------------
		
		
		// ----------------------------------------------------------------------------------------------------
		public function clear():void
		{
			txtArea.text = "";
		}
		// ----------------------------------------------------------------------------------------------------
		
		
		
		// ----------------------------------------------------------------------------------------------------
		private function mouseStageLeaveHandler(e:Event):void
		{
			mouseUpHandler(null);
		}
		// ----------------------------------------------------------------------------------------------------
		
		// ----------------------------------------------------------------------------------------------------
		private function mouseDownHandler(e:MouseEvent):void
		{
			container.startDrag();
		}
		// ----------------------------------------------------------------------------------------------------
		
		// ----------------------------------------------------------------------------------------------------
		private function mouseUpHandler(e:MouseEvent):void
		{
			container.stopDrag();
		}
		// ----------------------------------------------------------------------------------------------------
		
		
		
		// ----------------------------------------------------------------------------------------------------
		private function keyDownHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == 17)
			{
				ctrlKeyDown = true;
			}
			
			if (e.keyCode == 16)
			{
				shiftKeyDown = true;
			}
		}
		// ----------------------------------------------------------------------------------------------------
		
		
		// ----------------------------------------------------------------------------------------------------
		private function keyUpHandler(e:KeyboardEvent):void
		{
			//trace(e.keyCode);
			
			// Handle CTRL being pressed
			if (e.keyCode == 17)
			{
				ctrlKeyDown = false;
			}
			
			// Handle shift key
			if (e.keyCode == 16)
			{
				shiftKeyDown = false;
			}
			
			
			// Toggle visibility using CTRL & D key
			if (ctrlKeyDown && e.keyCode == 68)
			{
				if (container.visible)
				{
					container.visible = false;
				} else {
					container.visible = true;
				}
			}
			
			
			
			// Reset position with CTRL & R key
			if (ctrlKeyDown && e.keyCode == 82)
			{
				container.visible = true;
				container.stopDrag();
				container.x = 10;
				container.y = 10;
				trace("DebugBox(): Position reset");
			}
			
			
			
			// Show help with CTRL & H key
			if (ctrlKeyDown && e.keyCode == 72)
			{
				help();
			}
			
			
			
			// Clear with SHIFT and C
			if (shiftKeyDown && e.keyCode == 67)
			{
				this.txtArea.text = "";
			}
		}
		// ----------------------------------------------------------------------------------------------------
		
		
		
		
		// ----------------------------------------------------------------------------------------------------
		public function help():void
		{
			var msg:String = "";
			
			
			msg = "#########################################################" + "\n";
			msg += "DebugBox(): Usage:" + "\n";
			msg += "\t" + "Press CTRL & D to toggle visibility" + "\n";
			msg += "\t" + "Press CTRL & R to reset position" + "\n";
			msg += "\t" + "Press SHIFT & C to clear text" + "\n";
			msg += "\t" + "Press CTRL & H to for help" + "\n";
			msg += "#########################################################";
			add(msg);
			trace(msg);
		}
		// ----------------------------------------------------------------------------------------------------
		
		
	}
	// ----------------------------------------------------------------------------------------------------
}