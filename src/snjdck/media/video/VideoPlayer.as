package snjdck.media.video
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.events.VideoEvent;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.media.VideoStatus;
	import flash.net.NetStream;
	
	public class VideoPlayer
	{
		private var ns:NetStream;
		
		private var stageVideo:StageVideo;
		private var video:Video;
		
		private var stage:Stage;
		
		private var supportGpu:Boolean;
		private var isGpuMode:Boolean;
		
		private var videoWidth:int = 320;
		private var videoHeight:int = 240;
		private var ratioHW:Number = 0.75;
		
		public function VideoPlayer(stage:Stage)
		{
			this.stage = stage;
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, __onInit);
			init();
		}
		
		private function init():void
		{
			ns = VideoFactory.createNetStream(this);
			ns.addEventListener(NetStatusEvent.NET_STATUS, __onStatus);
			
			video = VideoFactory.createVideo();
			video.addEventListener(VideoEvent.RENDER_STATE, __onVideoState);
		}
		
		private function __onInit(evt:StageVideoAvailabilityEvent):void
		{
			stage.removeEventListener(evt.type, __onInit);
			supportGpu = evt.availability == StageVideoAvailability.AVAILABLE;
			isGpuMode = supportGpu;
			if(supportGpu){
				stageVideo = stage.stageVideos[0];
				stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, __onVideoState);
				stageVideo.attachNetStream(ns);
			}else{
				stage.addChildAt(video, 0);
				video.attachNetStream(ns);
			}
		}
		
		private function toggleMode():void
		{
			if(isGpuMode){
				stageVideo.attachNetStream(null);
				stage.addChildAt(video, 0);
				video.attachNetStream(ns);
			}else{
				video.attachNetStream(null);
				stage.removeChild(video);
				stageVideo.attachNetStream(ns);
			}
			isGpuMode = !isGpuMode;
		}
		
		public function play(path:String):void
		{
			if(supportGpu && !isGpuMode){
				toggleMode();
			}
			ns.play(path);
		}
		
		private function __onStatus(evt:NetStatusEvent):void
		{
			onPlayStatus(evt.info);
		}
		
		private function __onVideoState(evt:Event):void
		{
			var isStageVideo:Boolean = evt is StageVideoEvent;
			var status:String = evt["status"];
			if(isStageVideo && status == VideoStatus.UNAVAILABLE){
				toggleMode();
				return;
			}
			if(isStageVideo){
				videoWidth = stageVideo.videoWidth;
				videoHeight = stageVideo.videoHeight;
			}else{
				videoWidth = video.videoWidth;
				videoHeight = video.videoHeight;
			}
			ratioHW = videoHeight / videoWidth;
			adjustSize();
		}
		
		private function adjustSize():void
		{
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			var stageHW:Number = sh / sw;
			
			var target:* = isGpuMode ? stageVideo.viewPort : video;
			if(ratioHW <= stageHW){
				target.width = sw;
				target.height = sw * ratioHW;
				target.x = 0;
				target.y = 0.5 * (sh - target.height);
			}else{
				target.height = sh;
				target.width = sh / ratioHW;
				target.y = 0;
				target.x = 0.5 * (sw - target.width);
			}
			if(isGpuMode){
				stageVideo.viewPort = target;
			}
		}
		
		public function onStageResize():void
		{
			adjustSize();
		}
		
		public function onMetaData(info:Object):void{}
		public function onPlayStatus(info:Object):void
		{
			trace(info.level, info.code);
			switch(info.code){
				case "NetStream.Play.Complete":
					trace("complete");
					break;
				case "NetStream.Play.StreamNotFound":
					break;
			}
		}
	}
}