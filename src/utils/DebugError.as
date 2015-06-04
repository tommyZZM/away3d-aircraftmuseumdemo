package utils
{
	public class DebugError extends Error
	{
		public function DebugError(message:*="", id:*=0)
		{
			super(message);
		}
	}
}