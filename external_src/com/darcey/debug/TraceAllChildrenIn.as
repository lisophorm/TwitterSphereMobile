package com.darcey.debug
{
	public class TraceAllChildrenIn
	{
		public function TraceAllChildrenIn(target:*)
		{
			try {
				for (var i:int = 0; i <= (target.numChildren-1); i++)
				{
					trace("target.getChildAt("+i+") = " + target.getChildAt(i) );
				}
			} catch (e:Error) {
				trace("TraceAllChildrenIn(target:*): Error - No numChildren found on target object");
			}
		}
	}
}