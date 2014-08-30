package com.wmgllc.twittersphere.controller.event
{
	import flash.events.Event;
	
	public class WindowSpacerEvent extends Event
	{
		public static var SPACER_EXPANSION_COMPLETE : String = "windowExpansionComplete";
		
		public function WindowSpacerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}