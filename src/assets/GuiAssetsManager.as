package assets
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class GuiAssetsManager extends AssetsBases
	{
		/** 位图资源目录**/private var uiBitmapContainer:Dictionary;
		private var uiBitmapIndex:Array = [];
		
		public function GuiAssetsManager()
		{
			super();
			
			isdebug = false;
			
			assetsType = "[GuiAssets]";
			uiBitmapContainer = new Dictionary();
			//uiXMLContainer = new Dictionary();
		}
		
		private function addBitmap(name:String,bitmap:Bitmap):void{
			if (name in uiBitmapContainer) 
			{
				log("覆盖"+name);
			}
			else
			{
				uiBitmapIndex.push(name);
			}
			
			log("add bitmap "+name);
			uiBitmapContainer[name] = bitmap;
		}
		
		public function getBitmap(name:String):Bitmap
		{
			if (name in uiBitmapContainer) return uiBitmapContainer[name];
			else
			{
				log("找不到"+name);
				return null;
			}
		}
		
		public function getBitmapDirectionary():Array
		{
			return uiBitmapIndex;
		}
		
		protected override function packupAsset(name:String,asset:Object,onNext:Function):void
		{
			if (asset is Bitmap) 
			{
				addBitmap(name,asset as Bitmap);
				onNext();
			}
		}
		
	}
}