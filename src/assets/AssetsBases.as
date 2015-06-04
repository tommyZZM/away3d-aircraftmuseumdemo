package assets
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	public class AssetsBases extends EventDispatcher
	{
		protected var assetsType:String = "[Assets]";
		
		protected var isdebug:Boolean = true;
		
		/** 储存资源的数组**/protected var mQueue:Array;
		/** 正在加载？**/protected var mIsLoading:Boolean;
		
		private var mTimeoutID:uint;
		
		public function AssetsBases()
		{
			mIsLoading = false;
			mQueue=[];
		}
		
		/** 加载资源**/
		public function loadQueue(onProgress:Function = null):void
		{
			if (mIsLoading)
				throw new Error("The queue is already being processed");
			
			var numElements:int = mQueue.length;
			var currentRatio:Number = 0.0;
			
			mIsLoading = true;
			resume();
			
			function resume():void
			{
				if (!mIsLoading)
					return;
				
				//currentRatio = (mQueue.length ? 1.0 - (mQueue.length / numElements) : 1.0);
				
				if (mQueue.length){
					mTimeoutID = setTimeout(processNext, 1);//如果长度不为零
					currentRatio = 1.0 - (mQueue.length / numElements);
				}
				else
				{
					mIsLoading=false;
					log("Load Completed ∩_∩");//完成加载
					currentRatio = 1.0;
					dispatchEvent(new Event("LoadCompleted"));//派发完成事件
				}
				
				if (onProgress != null)
					onProgress(currentRatio);
			}
			
			function processNext():void
			{
				var assetInfo:Object = mQueue.pop();//循环遍历mQueue里面的文件
				clearTimeout(mTimeoutID);
				processRawAsset(assetInfo.name, assetInfo.asset, progress, resume);
			}
			
			function progress(ratio:Number):void
			{
				onProgress(currentRatio + (1.0 / numElements) * Math.min(1.0, ratio) * 0.99);
			}
		}
		
		
		private function processRawAsset(name:String, rawAsset:Object,
										 onProgress:Function, onComplete:Function):void
		{
			loadRawAsset(name, rawAsset, onProgress, packupAsset, onComplete); 
			log("processing");
		}
		/**分类打包资源**/
		protected function packupAsset(name:String,asset:Object,onNext:Function):void{}
		
		
		/**载入单个资源**/
		private function loadRawAsset(name:String, rawAsset:Object,
									  onProgress:Function, onProcess:Function,onNext:Function):void
		{
			var extension:String = null;
			var urlLoader:URLLoader = null;
			
			if (rawAsset is Class)
			{
				setTimeout(onProcess, 1, name,new rawAsset(),onNext);
			}
			else if (rawAsset is String)//由路径载入
			{
				var url:String = rawAsset as String;
				extension = url.split(".").pop().toLowerCase().split("?")[0];
				log("Loading from ‘"+url+"‘");
				
				urlLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
				urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
				urlLoader.load(new URLRequest(url));
			}
			
			function onIoError(event:IOErrorEvent):void
			{
				log("IO error: " + event.text);
				onProcess(null);
			}
			
			function onLoadProgress(event:ProgressEvent):void
			{
				if (onProgress != null)
					onProgress(event.bytesLoaded / event.bytesTotal);
			}
			
			function onUrlLoaderComplete(event:Object):void
			{
				var bytes:ByteArray = urlLoader.data as ByteArray;
				
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				urlLoader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
				
				classifyAsset(name,extension,bytes,onProcess);
			}
		}
		/**分类处理资源**/
		protected function classifyAsset(name:String,extension:String,bytes:ByteArray,onComplete:Function):void{}
		
		/** 定位一个或者多个资源如队列，支持Filesystem::File类型的输入**/
		public function enqueue(...rawAssets):void
		{
			log("enqueuing");
			for each (var asset:Object in rawAssets) 
			{
				if (asset is Array) 
				{
					enqueue.apply(this,asset);
					//enqueue(asset);
				}
				else if (asset is Class)
				{
					var typeXml:XML = describeType(asset);
					var childNode:XML;
					
					log("Looking for static embedded assets in '" +  (typeXml.@name).split("::").pop() + "'"); 
					
					for each (childNode in typeXml.constant.(@type == "Class"))
					enqueueWithName(asset[childNode.@name], childNode.@name);
					
					for each (childNode in typeXml.variable.(@type == "Class"))
					enqueueWithName(asset[childNode.@name], childNode.@name);
				}
				else if (asset is String) 
				{
					enqueueWithName(asset);
				}
			}
		}
		
		/** 获得名称和资源并且加入“加载序列”**/
		private function enqueueWithName(asset:Object, name:String=null):String{
			 
			if (name == null) name = getName(asset);
			log("Enqueuing '" + name + "'");
			
			mQueue.push({
				name: name,
				asset: asset
			});
			
			return name;
		}
		
		/** 获得文件名**/
		private function getName(rawAsset:Object):String
		{
			var matches:Array;
			var name:String;
			
			if (rawAsset is String || rawAsset is FileReference)
			{
				name = rawAsset is String ? rawAsset as String : (rawAsset as FileReference).name;
				name = name.replace(/%20/g, " "); 
				matches = /(.*[\\\/])?(.+)(\.[\w]{1,4})/.exec(name);
				
				if (matches && matches.length == 4) return matches[2];
				else throw new ArgumentError("Could not extract name from String '" + rawAsset + "'");
			}
			else
			{
				name = getQualifiedClassName(rawAsset);
				throw new ArgumentError("Cannot extract names for objects of type '" + name + "'");
			}
		}
		
		/** LOG**/
		protected final function log(message:Object):void
		{
			if (isdebug) 
			{
				trace(assetsType, message);
			}
		}
	}
}