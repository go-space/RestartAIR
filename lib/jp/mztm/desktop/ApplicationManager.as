package jp.mztm.desktop
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	/**
	 * ...
	 * @author GO
	 * adl（デバッガ）では実行ファイルが異なる為、サポートしません。インストールして確認してください。
	 * application.xml <supportedProfiles>extendedDesktop</supportedProfiles>
	 * SetupApplication.bat -target native
	 * Packager.bat .exe
	 */
	public class ApplicationManager 
	{
		private static const CMD_EXE:File = new File('C://Windows/System32/cmd.exe');
		private static const RESTART_BAT:File = File.applicationStorageDirectory.resolvePath('restart.bat');
		private static var _instance:ApplicationManager;
		
		public function ApplicationManager (block:SingletonBlock)
		{
			init();
		}
		
		public static function getInstance ():ApplicationManager
		{
			if (_instance == null)
				_instance = new ApplicationManager(new SingletonBlock());
			return _instance;
		}
		
		public function restartApp ():void
		{
			var processArguments:Vector.<String> = new <String>[];
			processArguments.push('/c');// cmd /c 後ろに書かれたコマンドを実行して終了する。
			processArguments.push(RESTART_BAT.nativePath);
			invokeProcess(processArguments);
		}
		
		/**
		 * OSの再起動
		 * @param	limit:シャットダウンまでの秒数
		 */
		public function restartOS (limit:uint = 10):void
		{
			var processArguments:Vector.<String> = new <String>[];
			processArguments.push('/c');// cmd /c 後ろに書かれたコマンドを実行して終了する。
			processArguments.push('shutdown.exe /r /t ' + String(limit));
			invokeProcess(processArguments);
		}
		
		/**
		 * OSの再起動キャンセル
		 */
		public function cancelRestartOS ():void
		{
			var processArguments:Vector.<String> = new <String>[];
			processArguments.push('/c');// cmd /c 後ろに書かれたコマンドを実行して終了する。
			processArguments.push('shutdown.exe /a');
			invokeProcess(processArguments);
		}
		
		private function init ():void
		{
			var xml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var nameSpace:Namespace = xml.namespace();
			var application:File = File.applicationDirectory.resolvePath(String(xml.nameSpace::filename) + '.exe');
			var outputList:Array = [
				//'@echo off',
				'taskkill /IM ' + application.name + ' >NUL',
				'IF EXIST "' + application.nativePath + '" (',
				'start "" "' + application.nativePath + '" >NUL',
				')'
			]
			var output:String = outputList.join(File.lineEnding);
			var fileStream:FileStream = new FileStream();
			fileStream.open(RESTART_BAT, FileMode.WRITE);
			fileStream.writeUTFBytes(output);
			fileStream.close();
		}
		
		private function invokeProcess (processArguments:Vector.<String>):void
		{
			var nativeProcessStartupInfo:NativeProcessStartupInfo;
			var nativeProcess:NativeProcess;
			
			if (NativeProcess.isSupported && CMD_EXE.exists)
			{
				nativeProcessStartupInfo = new NativeProcessStartupInfo();
				nativeProcessStartupInfo.arguments = processArguments;
				nativeProcessStartupInfo.executable = CMD_EXE;
				
				nativeProcess = new NativeProcess();
				nativeProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onStandardErrorIOError);
				nativeProcess.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onStandardInputIOError);
				nativeProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onStandardOutputIOError);
				nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardErrorData);
				nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
				try
				{
					nativeProcess.start(nativeProcessStartupInfo);
				}
				catch (error:Error)
				{
					trace( "error.message : " + error.message );
				}
			}
		}
		
		private function onStandardErrorIOError (event:IOErrorEvent):void
		{
			trace( "onStandardErrorIOError" );
		}
		
		private function onStandardInputIOError (event:IOErrorEvent):void
		{
			trace( "onStandardInputIOError" );
		}
		
		private function onStandardOutputIOError (event:IOErrorEvent):void
		{
			trace( "onStandardOutputIOError" );
		}
		
		private function onStandardErrorData (event:ProgressEvent):void
		{
			var nativeProcess:NativeProcess = event.target as NativeProcess;
			var data:String = nativeProcess.standardError.readMultiByte(nativeProcess.standardError.bytesAvailable, 'shift-jis');
			trace( "onStandardErrorData" );
		}
		
		private function onStandardOutputData (event:ProgressEvent):void
		{
			var nativeProcess:NativeProcess = event.target as NativeProcess;
			var data:String = nativeProcess.standardOutput.readMultiByte(nativeProcess.standardOutput.bytesAvailable, 'shift-jis');
			trace( "onStandardOutputData" );
		}
	}
}
class SingletonBlock { };