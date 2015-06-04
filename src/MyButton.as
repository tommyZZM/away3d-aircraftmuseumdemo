package
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class MyButton extends Sprite
	{
		private var btn_frame:MovieClip;
		
		public function MyButton(pic:Bitmap = null)
		{
			//btn_frame = new btn();
			btn_frame = new btn_mSelector();
			pic.x = btn_frame.x = -btn_frame.width/2; 
			pic.y = btn_frame.y = -btn_frame.height/2; 
			this.addChild(pic);
			this.addChild(btn_frame);
		}
		
		public function setActive():void
		{
			(btn_frame as btn_mSelector).setActive(true);
		}
		
		public function setDisActive():void
		{
			(btn_frame as btn_mSelector).setActive(false);
		}
		
		public function get btn():btn_mSelector
		{
			return btn_frame as btn_mSelector;
		}
	}
}