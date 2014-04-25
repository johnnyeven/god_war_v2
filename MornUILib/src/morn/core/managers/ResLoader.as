/**
 * Morn UI Version 2.5.1215 http://www.mornui.com/
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 */
package morn.core.managers {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import morn.core.handlers.Handler;
	import morn.core.utils.ObjectUtils;
	
	/**资源加载器*/
	public class ResLoader {
		/**加载swf文件，返回1*/
		public static const SWF:uint = 0;
		/**加载位图，返回Bitmapdata*/
		public static const BMD:uint = 1;
		/**加载ANF数据，返回Object*/
		public static const AMF:uint = 2;
		/**加载TXT文本，返回String*/
		public static const TXT:uint = 3;
		/**加载经过压缩的ByteArray，返回Object*/
		public static const DB:uint = 4;
		/**加载未压缩的ByteArray，返回ByteArray*/
		public static const BYTE:uint = 5;
		private static var _loadedMap:Object = {};
		private var _loader:Loader = new Loader();
		private var _urlLoader:URLLoader = new URLLoader();
		private var _urlRequest:URLRequest = new URLRequest();
		private var _loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		private var _url:String;
		private var _type:int;
		private var _complete:Handler;
		private var _progress:Handler;
		private var _isCache:Boolean;
		private var _isLoading:Boolean;
		private var _loaded:Number;
		private var _lastLoaded:Number;
		
		public function ResLoader() {
			//_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
			
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_urlLoader.addEventListener(Event.COMPLETE, onComplete);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			_loaderContext.allowCodeImport = true;
		}
		
		/**中止加载*/
		public function tryToCloseLoad():void {
			try {
				_loader.unloadAndStop();
				_urlLoader.close();
				UIManager.timer.clearTimer(checkLoad);
				_isLoading = false;
			} catch (e:Error) {
			}
		}
		
		private function doLoad():void {
			_isLoading = true;
			_urlRequest.url = UIManager.getResPath(_url);
			if (_type == BMD || _type == AMF || _type == DB || _type == BYTE || _type == SWF) {
				_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				_urlLoader.load(_urlRequest);
				return;
			}
			if (_type == TXT) {
				_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
				_urlLoader.load(_urlRequest);
				return;
			}
		}
		
		private function onStatus(e:HTTPStatusEvent):void {
		
		}
		
		private function onError(e:Event):void {
			UIManager.log.error("Load Error:", e.toString());
			endLoad(null);
		}
		
		private function onProgress(e:ProgressEvent):void {
			if (_progress != null) {
				var value:Number = e.bytesLoaded / e.bytesTotal;
				_progress.executeWith([value]);
			}
			_loaded = e.bytesLoaded;
		}
		
		private function onComplete(e:Event):void {
			var content:* = null;
			if (_type == SWF || _type == BMD) {
				if (_urlLoader.data != null) {
					_loader.loadBytes(_urlLoader.data, _loaderContext);
					_urlLoader.data = null;
					return;
				}
				if (_type == SWF) {
					_loader.unloadAndStop();
					content = 1;
				} else {
					content = Bitmap(_loader.content).bitmapData;
					_loader.unloadAndStop();
				}
			} else if (_type == AMF) {
				content = ObjectUtils.readAMF(_urlLoader.data);
			} else if (_type == DB) {
				var bytes:ByteArray = _urlLoader.data as ByteArray;
				bytes.uncompress();
				content = bytes.readObject();
			} else if (_type == BYTE) {
				content = _urlLoader.data as ByteArray;
			} else if (_type == TXT) {
				content = _urlLoader.data;
			}
			if (_isCache) {
				_loadedMap[_url] = content;
			}
			endLoad(content);
		}
		
		private function endLoad(content:*):void {
			UIManager.timer.clearTimer(checkLoad);
			_isLoading = false;
			_progress = null;
			if (_complete != null) {
				var handler:Handler = _complete;
				_complete = null;
				handler.executeWith([content]);
			}
		}
		
		/**加载资源*/
		public function load(url:String, type:int, complete:Handler, progress:Handler, isCache:Boolean = true):void {
			if (_isLoading) {
				UIManager.log.warn("Loader is try to close.", _url);
				tryToCloseLoad();
			}
			
			_url = url;
			_type = type;
			_complete = complete;
			_progress = progress;
			_isCache = isCache;
			
			var content:* = getResLoaded(url);
			if (content != null) {
				return endLoad(content);
			}
			_loaded = _lastLoaded = 0;
			UIManager.timer.doLoop(5000, checkLoad);
			doLoad();
		}
		
		/**如果5秒钟下载小于1k，则停止下载*/
		private function checkLoad():void {
			if (_loaded - _lastLoaded < 1024) {
				UIManager.log.warn("load time out:" + _url);
				tryToCloseLoad();
				endLoad(null);
			} else {
				_lastLoaded = _loaded;
			}
		}
		
		/**获取已加载的资源*/
		public static function getResLoaded(url:String):* {
			return _loadedMap[url];
		}
		
		/**设置资源*/
		public static function setResLoaded(url:String, content:*):void {
			_loadedMap[url] = content;
		}
		
		/**删除已加载的资源*/
		public static function clearResLoaded(url:String):void {
			var res:Object = _loadedMap[url];
			if (res is BitmapData) {
				BitmapData(res).dispose();
			} else if (res is Bitmap) {
				Bitmap(res).bitmapData.dispose();
			}
			delete _loadedMap[url];
		}
		
		/**加载资源的地址*/
		public function get url():String {
			return _url;
		}
	}
}