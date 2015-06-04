package assets
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	import utils.DebugError;

	public class AwayAssetsManager extends AssetsBases
	{
		/** 纹理**/private var textureContainer:Dictionary;
		///** 纹理**/private var modelContainer:Dictionary;
		
		public function AwayAssetsManager()
		{
			super();
			
			assetsType = "[Away3DAssets]";
			
			isdebug = false;
			
			textureContainer = new Dictionary();
			//modelContainer = new Dictionary();
		}
		
		private function addTexture(name:String , texture:BitmapTexture):void
		{
			if (name in textureContainer) 
			{
				log("覆盖"+name);
			}
			
			textureContainer[name] = texture;
		}
		
		public function getTexture(name:String):BitmapTexture
		{
			if (name in textureContainer) return textureContainer[name];
			else
			{
				log("找不到"+name);
				return null;
			}
		}
		
		protected override function packupAsset(name:String, asset:Object, onNext:Function):void
		{
			if (asset is Bitmap)
			{
				var texture:BitmapTexture = Cast.bitmapTexture(asset);
				addTexture(name, texture);
				onNext();
			}
		}
		
	}
}