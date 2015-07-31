package snjdck.media.video
{
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class VideoFactory
	{
		static public function createVideo():Video
		{
			var video:Video = new Video();
			video.smoothing = true;
			return video;
		}
		
		static public function createNetStream(client:Object):NetStream
		{
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			var ns:NetStream = new NetStream(nc);
			ns.client = client;
			return ns;
		}
	}
}