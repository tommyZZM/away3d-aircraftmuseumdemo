package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import assets.AwayAssets;
	import assets.AwayAssetsManager;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.AssetType;
	import away3d.lights.DirectionalLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.Max3DSParser;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	
	import cameras.CameraController;
	import cameras.OrbitTarget;

	public class Away3DLayer
	{
		protected var isdebug:Boolean = true;
		
		/**bf110C6模型**/
		[Embed(source = "/model/bf110c6.3ds",mimeType="application/octet-stream"]
		public static const bf110c6:Class;
		
		public static var awayassets:AwayAssetsManager;
		
		private static var _isload:Boolean = false;
		
		private var _root:Sprite
		public var view:View3D
		
		private var _planeLoader:Loader3D;
		private var _planeModel:ObjectContainer3D;
		
		private var _engines:Array = [];
		private var _isenginesOn:Boolean = false;
		
		private var _normEngineSpeed:Number = 6;
		private var _currEngineSpeed:Number = 0;
		
		private var _planeMaterial:TextureMaterial;
		
		public function Away3DLayer(sprite:Sprite,stage3dproxy:Stage3DProxy =null)
		{
			_root = sprite;
			view = new View3D();//创建stage3D层
			view.rightClickMenuEnabled = false;//关闭away3d右键菜单
			view.stage3DProxy = stage3dproxy;
			view.shareContext = true;
			view.antiAlias = 6;
			_root.addChild(view);//
			
			_root.addChild(new AwayStats(view));
			
			//镜头
			var cameracontroler:CameraController= new OrbitTarget(view,null,160,30);
			cameracontroler.maxDistance = 390;
			cameracontroler.minDistance = 260;
			
			//initDebug();
			loadAssets();
			//initLight();
			
			initGround();
			initLight();
			
			stage3dproxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
		private function loadAssets():void
		{
			awayassets = new AwayAssetsManager();
			awayassets.enqueue(AwayAssets);
			awayassets.loadQueue(function(ratio:Number):void
			{
				//trace(ratio);
			});
			awayassets.addEventListener("LoadCompleted",onAssetsLoad);
			
			function onAssetsLoad(event:Event):void
			{
				// TODO Auto-generated method stub
				loadModel(onResourcesLoad);
				_isload = true;
			}
		}
		
		private function onResourcesLoad():void
		{
			_planeModel.scale(50);
			view.scene.addChild(_planeModel);
			
			newMaterial(null);
			assignMaterial();1
			
		}
		
		/**材质贴图**/
		private function newMaterial(texture:String):void
		{
			var plane_material:TextureMaterial = new TextureMaterial(awayassets.getTexture(texture));
			_planeMaterial = plane_material;
		}
		
		/**指定材质**/
		private function assignMaterial():void
		{
			for (var i:int = 0; i < _planeModel.numChildren; i++) 
			{
				( _planeModel.getChildAt(i) as Mesh).material =_planeMaterial;
			}
		}
		
		/**更新贴图**/
		public function updateTexture(texture:String):void
		{
			log("Update texture to"+texture);
			_planeMaterial.texture = awayassets.getTexture(texture);
		}
		
		public function updateEngine():void
		{
			_isenginesOn = !_isenginesOn;
		}
		
		/**地面**/
		private function initGround():void
		{
			var _groundMaterial:ColorMaterial = new ColorMaterial(0xf8f8f8);//颜色材质
			try
			{
				_groundMaterial.shadowMethod = new FilteredShadowMapMethod(_light);
				_groundMaterial.lightPicker = _lightPicker;
			} 
			catch(error:Error) {	log("灯光未初始化");}
			_groundMaterial.bothSides = true;
			_groundMaterial.specular = 0;
			var _ground:Mesh = new Mesh(new PlaneGeometry(1000, 1000), _groundMaterial);
			view.scene.addChild(_ground);
		}
		
		//light objects
		private var _light:DirectionalLight;
		private var _lightPicker:StaticLightPicker;
		private var _direction:Vector3D;
		
		/**灯光**/
		private function initLight():void
		{
			_light = new DirectionalLight(-1, -1, 1);
			_light.color = 0xf8f8f8;
			_direction = new Vector3D(-1, -1, 1);
			_lightPicker = new StaticLightPicker([_light]);
			view.scene.addChild(_light);
		}
		
		/**动画**/
		private function goAnimation():void
		{
			if (_isload) 
			{
				if (_isenginesOn) 
				{
					if (_currEngineSpeed<_normEngineSpeed) {
						_currEngineSpeed+=0.05
					}
					else{
						_currEngineSpeed = _normEngineSpeed;
					}
				}else
				{
					if (_currEngineSpeed>0) {
						_currEngineSpeed-=0.05
					}
					else{
						_currEngineSpeed = 0;
					}
				}
				
			}
			for each (var e:Mesh in _engines) 
			{
				e.roll(_currEngineSpeed);
			}
		}
		
		
		/**加载模型**/
		private function loadModel(onComplete:Function):void
		{
			var planemodel:ObjectContainer3D = new ObjectContainer3D();
			
			log("Loading Model.....");
			_planeLoader = new Loader3D(false);
			_planeLoader.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			_planeLoader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			_planeLoader.loadData(new bf110c6(), null, null, new Max3DSParser());
			
			function onAssetComplete(event:AssetEvent):void
			{
				if (event.asset.assetType == AssetType.MESH) {
					//TODO: Mesh
					var mesh:Mesh = event.asset as Mesh;
					mesh.castsShadows = true;
					planemodel.addChild(mesh);
					log("loading mesh '"+mesh.name +"'");
					if (mesh.name == "propellerL" ||mesh.name == "propellerR" ) 
					{
						_engines.push(mesh);
						//trace("engine");
					}
				} else if (event.asset.assetType == AssetType.MATERIAL) {
					//TODO: 材质
					log("find a material");
					/**var material:TextureMaterial = event.asset as TextureMaterial;
					 material.shadowMethod = new FilteredShadowMapMethod(_light);
					 material.lightPicker = _lightPicker;
					 material.gloss = 30;
					 material.specular = 1;
					 material.ambientColor = 0x303040;
					 material.ambient = 1;**/
				}else if (event.asset.assetType == AssetType.GEOMETRY) {
					//log("find a geometry");
					//TODO: 几何图形
				}
			}
			
			function onResourceComplete(event:LoaderEvent):void
			{
				event.target.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
				event.target.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
				_planeModel= planemodel;
				log("Model Load complete!");
				onComplete();
			}
			
		}
		
		/**Debug方块**/
		private function initDebug():void
		{
			var tommycube:CubeGeometry = new CubeGeometry(100, 100, 100);//定义一个方体
			var tommymaterial:ColorMaterial = new ColorMaterial(0xaeaeae);//颜色材质
			var cubeMesh:Mesh = new Mesh(tommycube, tommymaterial);//新建一个mesh
			view.scene.addChild(cubeMesh);//在view3D中添加mesh
			//cameracontroler = new OrbitControllerTmy(view.camera,view);
		}
		
		private function onEnterFrame(event:Event):void
		{
			view.render();
			
			goAnimation();
		}
		
		/** LOG**/
		protected final function log(message:Object):void
		{
			if (isdebug) 
			{
				trace("[Away3D]"+message);
			}
		}
	}
}