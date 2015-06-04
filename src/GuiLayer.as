package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	
	import assets.GuiAssets;
	import assets.GuiAssetsManager;

	public class GuiLayer extends Sprite
	{
		protected var isdebug:Boolean = false;
		
		public static var guiassets:GuiAssetsManager;
		public static var btnGroup:Array = [];
		
		private var currentBtn:MyButton;
		private var currentBtnName:String = "t_s_gray";
		
		public var currentTexture:String;
		
		private var _planeWardrobe:XML;
		private var _planeWardrobeDictionary:Dictionary;
		
		private var title:TextField;
		private var phanlogo:Bitmap;
		
		public function GuiLayer()
		{
			_planeWardrobeDictionary = new Dictionary();
			
			loadGUI();
		}
		
		private function loadGUI():void
		{
			guiassets = new GuiAssetsManager();
			guiassets.enqueue(GuiAssets);
			guiassets.loadQueue(function(ratio:Number):void
			{
				//trace(ratio);
			});
			guiassets.addEventListener("LoadCompleted",onGuiLoadedComplete);
		}
		
		private function onGuiLoadedComplete(event:Event):void
		{
			
			// TODO Auto-generated method stub
			initGUI();
			
			initConstansWardrobe();
			//loadWardrobe();
		}
		
		/**初始化对应表xml（程序内部）**/
		private function initConstansWardrobe():void
		{
			_planeWardrobe = Constants.icon2TextureXml;
			
			for each (var unit:XML in _planeWardrobe.dir) 
			{
				log("Creating wardrobe dictionary "+unit.@icon +"<>" + unit.@texture);
				var icon:String = unit.@icon;
				var texture:String = unit.@texture;
				_planeWardrobeDictionary[icon] = texture;
			}
			
			if (currentBtnName in _planeWardrobeDictionary) 
			{
				currentTexture = _planeWardrobeDictionary[currentBtnName];
				//log(currentTexture);
			}
			
			dispatchEvent(new Event("TextureUpdate"));
		}
		
		/**初始化对应表xml（外部加载）**/
		private function loadWardrobe():void
		{
			var xml:XML = new XML(); 
			var xml_url:String = "textureDictionary.xml"; 
			var url:URLRequest = new URLRequest(xml_url);
			var loader:URLLoader = new URLLoader(url); 
			loader.addEventListener(flash.events.Event.COMPLETE, xmlLoaded); 
			
			function xmlLoaded(event:flash.events.Event):void 
			{ 
				log("Wardrobe Load complete!");
				xml = XML(loader.data); 
				_planeWardrobe = xml;
				
				for each (var unit:XML in _planeWardrobe.dir) 
				{
					log("Creating wardrobe dictionary "+unit.@icon +"<>" + unit.@texture);
					var icon:String = unit.@icon;
					var texture:String = unit.@texture;
					_planeWardrobeDictionary[icon] = texture;
				}
				
				if (currentBtnName in _planeWardrobeDictionary) 
				{
					currentTexture = _planeWardrobeDictionary[currentBtnName];
					//log(currentTexture);
				}
				dispatchEvent(new Event("TextureUpdate"));
			}
		}
		
		
		private function initGUI():void
		{
			var dir:Array = guiassets.getBitmapDirectionary();
			var i:int = 0;
			for each (var unit:String in dir) 
			{
				if (unit == "phantomyLogo" || unit == "away3dLogo") 
				{
					dir.splice(i,1);
					//trace(dir);
				}
				i++;
			}
			for each (var btn_icon:String in dir) 
			{
				var btn:MyButton = new MyButton(guiassets.getBitmap(btn_icon));
				btn.name = btn_icon;
				btnGroup.push(btn);
			}
			var b_x0:int = 913;
			for each (var b:MyButton in btnGroup) 
			{
				if (b.name != "p_ico_engine") 
				{
					log("Adding Texture Button "+ b.name);
					b.x = b_x0;
					b.y = 595;
					this.addChild(b);
					b_x0-=70;
					if (b.name == currentBtnName) 
					{
						b.setActive();
						currentBtn = b;
						//trace(currentBtn.name);
					}
					else
					{
						b.btn.addEventListener("BUTTON_ACTIVE",onTextureCoice);
					}
				}
				else if(b.name == "p_ico_engine") 
				{
					b.x = 913;
					b.y = 535;
					this.addChild(b);
					b.btn.addEventListener("BUTTON_ACTIVE",onEngine);
					b.btn.addEventListener("BUTTON_DISACTIVE",offEngine);
					b.btn.isBilateral(true);
				}
			}
			
			//LOGO
			//var awaylogo:Bitmap = guiassets.getBitmap("away3dLogo");
			//awaylogo.x =20;
			//trace(stage.stageHeight);
			//awaylogo.y =stage.stageHeight-awaylogo.height-20;
			//this.addChild(awaylogo);
			
			phanlogo = guiassets.getBitmap("phantomyLogo");
			phanlogo.x = 20;
			phanlogo.y = stage.stageHeight-phanlogo.height-20;
			this.addChild(phanlogo);
			
			//TEXT
			title = new TextField();
			title.htmlText="<font face='Microsoft YaHei' size ='36'>BF 110 C-6</font>";
			title.antiAliasType = flash.text.AntiAliasType.ADVANCED;
			title.sharpness = 100;
			title.autoSize = TextFieldAutoSize.RIGHT;
			title.selectable = false;
			title.x = stage.stageWidth -title.width- 20;
			title.y = 20;
			this.addChild(title);
		}
		
		private function onEngine(event:Event):void
		{
			// TODO Auto-generated method stub
			log("engine ON");
			dispatchEvent(new Event("EngineUpdate"));
		}
		
		private function offEngine(event:Event):void
		{
			// TODO Auto-generated method stub
			log("engine OFF");
			dispatchEvent(new Event("EngineUpdate"));
		}
		
		private function onTextureCoice(event:Event):void
		{
			// TODO Auto-generated method stub
			event.target.removeEventListener("BUTTON_ACTIVE",onTextureCoice);
			
			currentBtn.setDisActive();
			currentBtn.btn.addEventListener("BUTTON_ACTIVE",onTextureCoice);
			
			currentBtn = event.target.parent;
			
			currentBtnName = event.target.parent.name;
			currentTexture = _planeWardrobeDictionary[currentBtnName];
			
			//log(currentTexture);
			
			dispatchEvent(new Event("TextureUpdate"));
			
			//trace(currentBtn.name);
		}
		
		public function resize():void
		{
			
		}
		
		/** LOG**/
		protected final function log(message:Object):void
		{
			if (isdebug) 
			{
				trace("[GUI]"+message);
			}
		}
	}
}