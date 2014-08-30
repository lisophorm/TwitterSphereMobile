package com.darcey.debug
{
	import flash.text.Font;

	public class TraceAvailableFonts
	{
		private var debugBox:DebugBox;
		private var msg:String;
		
		// ---------------------------------------------------------------------------------------------------------------------
		public function TraceAvailableFonts(appName:String,debugBox:DebugBox=null)
		{
			this.debugBox = debugBox;
			
			msg = "---------------------------------------------------------------------------";
			trace(msg);
			addToDebugBox(msg);
			msg = "AVAILABLE FONTS to [" + appName + "]:";
			trace(msg);
			addToDebugBox(msg);
			
			addToDebugBox(msg);
			var fonts:Array = Font.enumerateFonts().sortOn("fontName");
			for (var i:int = 0; i < fonts.length; i++)
			{
				var font:Font = fonts[i];
				msg = "\t" + i + ") fontName: [" + font.fontName + "]   fontStyle: [" + font.fontStyle + "]   fontType: [" + font.fontType + "]";
				trace(msg);
				addToDebugBox(msg);
			}
			msg = "---------------------------------------------------------------------------";
			trace(msg);
			addToDebugBox(msg);
		}
		// ---------------------------------------------------------------------------------------------------------------------
		
		
		// ----------------------------------------------------------------------------------------
		private function addToDebugBox(str:String):void
		{
			if (debugBox)
			{
				debugBox.add(str);				
			}
		}
		// ----------------------------------------------------------------------------------------
		
	}
}