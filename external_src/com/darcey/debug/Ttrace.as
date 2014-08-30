package com.darcey.debug
{		
	import flash.utils.describeType;
	import flash.xml.*;
	
	
	public class Ttrace
	{
		// ----------------------------------------------------------------------------------------
		public var enabled:Boolean = true;
		private var appLabel:String = "";
		// ----------------------------------------------------------------------------------------
		
		
		// ----------------------------------------------------------------------------------------
		public function Ttrace(enabled:Boolean = true,debugBox:DebugBox=null)
		{
			this.enabled = enabled;
			this.debugBox = debugBox;
		}
		// ----------------------------------------------------------------------------------------
		
		
		// ----------------------------------------------------------------------------------------
		public function ttrace(param:Object=null):void
		{			
			// Check if class specific tracing has been enabled (keeps things clean)
			if (enabled)
			{
				var inputType:String = typeof param;
				//trace("inputType = " + inputType);
				//trace("param.length = " + param.length);
				//return;
				
				
				switch (inputType)
				{
					// ------------------------------------------------------------
					default:
						trace(appLabel + param);
						addToDebugBox(appLabel + param);
						break;
					// ------------------------------------------------------------
					
					// ------------------------------------------------------------
					case "xml":
						trace(appLabel + param);
						addToDebugBox(appLabel + param);
						break;
					// ------------------------------------------------------------
					
					// ------------------------------------------------------------
					case null:
						trace(appLabel + "TTrace got a NULL input");
						addToDebugBox(appLabel + "TTrace got a NULL input");
						break;
					// ------------------------------------------------------------
					
					// ------------------------------------------------------------
					case "string":
						trace(appLabel + param);
						addToDebugBox(appLabel + param);
						break;
					// ------------------------------------------------------------
					
					// ------------------------------------------------------------
					case "object":
						if (param.length)
						{
							trace(appLabel + "Array:\t" + "Length:(" + param.length + "): [" + param + "]");
							addToDebugBox(appLabel + "Array:\t" + "Length:(" + param.length + "): [" + param + "]");
							for (var ii:String in param)
							{
								trace("\t" + appLabel + "Index[" + ii + "] = " + param[ii]);
								addToDebugBox("\t" + appLabel + "Index[" + ii + "] = " + param[ii]);
							}
						} else {
							trace(appLabel + "Object");
							addToDebugBox(appLabel + "Object");
							try {
								trace(describeType( param ).toXMLString());
								addToDebugBox(describeType( param ).toXMLString());
							} catch (e:Error) {}
							//trace( param + " =\n" + describeType( param ).toXMLString() );
						}
						break;
					// ------------------------------------------------------------
					
					
					
				} // end switch
			}// end if
		}
		// ----------------------------------------------------------------------------------------
		
		
		
		// ----------------------------------------------------------------------------------------
		private var debugBox:DebugBox;
		// ----------------------------------------------------------------------------------------
		
		// ----------------------------------------------------------------------------------------
		public function attachDebugBox(debugBox:DebugBox):void
		{
			this.debugBox = debugBox;
		}
		// ----------------------------------------------------------------------------------------
		
		
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