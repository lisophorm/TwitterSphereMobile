package com.wmgllc.twittersphere.view.component.messagewindow
{
	import com.greensock.TweenMax;
	import com.wmgllc.twittersphere.controller.event.WindowSpacerEvent;
	
	import mx.controls.Spacer;
	import mx.core.UIComponent;
	
	import spark.components.VGroup;
	
	public class WindowSpacer extends Spacer
	{
		protected var window : MessageWindow;
		
		public function WindowSpacer()
		{
			super();
		}
		
		public function expand(window_ : MessageWindow):void
		{
			window = window_;
			height = 0;
			TweenMax.to(this, .3, {height:window.height, onComplete:expandCompleteHandler});
		}
		
		protected function expandCompleteHandler():void
		{
			(parent as VGroup).addElementAt(window, depth);
			(parent as VGroup).removeElement(this);
			
			dispatchEvent(new WindowSpacerEvent(WindowSpacerEvent.SPACER_EXPANSION_COMPLETE));
			
		}
		
		public function contract():void
		{
			TweenMax.to(this, .3, {height:0, onComplete:contractCompleteHandler});
		}
		
		protected function contractCompleteHandler():void
		{
			(parent as VGroup).removeElement(this);
		}
	}
}