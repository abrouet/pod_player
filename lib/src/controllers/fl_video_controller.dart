import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../fl_video_player.dart';
import 'fl_getx_video_controller.dart';

bool enableDevLogs = false;

class FlVideoController {
  ///
  late FlGetXVideoController _ctr;
  late String getTag;
  bool _isInitialised = false;

  final FlVideoPlayerType playerType;
  final String? fromNetworkUrl;
  final String? fromVimeoVideoId;
  final List<VimeoVideoQalityUrls>? fromVimeoUrls;
  final String? fromAssets;
  final File? fromFile;
  final FlVideoPlayerConfig playerConfig;
  bool enableLogs = false;

  FlVideoController({
    this.playerType = FlVideoPlayerType.auto,
    this.fromNetworkUrl,
    this.fromVimeoVideoId,
    this.fromVimeoUrls,
    this.fromAssets,
    this.fromFile,
    this.playerConfig = const FlVideoPlayerConfig(),
    this.enableLogs = false,
  }) {
    getTag = UniqueKey().toString();
    enableDevLogs = enableLogs;
    Get.config(enableLog: enableLogs);
    _ctr = Get.put(FlGetXVideoController(), permanent: true, tag: getTag)
      ..config(
        playerType: playerType,
        fromNetworkUrl: fromNetworkUrl,
        fromVimeoVideoId: fromVimeoVideoId,
        fromVimeoUrls: fromVimeoUrls,
        fromAssets: fromAssets,
        fromFile: fromFile,
        autoPlay: playerConfig.autoPlay,
        isLooping: playerConfig.isLooping,
      );
  }
  //!init
  Future<void> initialise() async {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      await _ctr.videoInit();
    });
    await _checkAndWaitTillInitialized();
  }

  Future<void> _checkAndWaitTillInitialized() async {
    if (_ctr.controllerInitialized) {
      _isInitialised = true;
      return;
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      await _checkAndWaitTillInitialized();
    }
  }

  bool get isInitialised => _ctr.videoCtr?.value.isInitialized ?? false;
  bool get isVideoPlaying => _ctr.videoCtr?.value.isPlaying ?? false;
  bool get isVideoBuffering => _ctr.videoCtr?.value.isBuffering ?? false;
  bool get isVideoLooping => _ctr.videoCtr?.value.isLooping ?? false;

  VideoPlayerValue? get videoPlayerValue => _ctr.videoCtr?.value;

  FlVideoPlayerType get videoPlayerType => _ctr.videoPlayerType;

  // Future<void> initialize() async => _ctr.videoCtr?.initialize;

  //! video positions

  ///return total length of the video
  Duration get totalVideoLength => _ctr.videoDuration;

  ///return current position/duration of the video
  Duration get currentVideoPosition => _ctr.videoPosition;

  //! video play/pause

  void play() => _ctr.flVideoStateChanger(FlVideoState.playing);

  void pause() => _ctr.flVideoStateChanger(FlVideoState.paused);

  void togglePlayPause() {
    isVideoPlaying ? pause() : play();
  }

  ///Listen to changes in video
  void addListener(void Function() listner) {
    _checkAndWaitTillInitialized().then(
      (value) => _ctr.videoCtr?.addListener(listner),
    );
  }

  ///remove registred listners
  void removeListener(void Function() listner) {
    _checkAndWaitTillInitialized().then(
      (value) => _ctr.videoCtr?.removeListener(listner),
    );
  }
  //! volume Controllers

  Future<void> mute() async => _ctr.mute();

  Future<void> unMute() async => _ctr.unMute();

  ///Dispose controller
  void dispose() {
    _ctr.videoCtr?.removeListener(_ctr.videoListner);
    _ctr.videoCtr?.dispose();
    _ctr.removeListenerId('flVideoState', _ctr.flStateListner);
    Get.delete<FlGetXVideoController>(
      force: true,
      tag: getTag,
    );
  }

  Future<void> changeVideo({
    FlVideoPlayerType playerType = FlVideoPlayerType.auto,
    String? fromNetworkUrl,
    String? fromVimeoVideoId,
    List<VimeoVideoQalityUrls>? fromVimeoUrls,
    String? fromAssets,
    File? fromFile,
    FlVideoPlayerConfig playerConfig = const FlVideoPlayerConfig(),
  }) =>
      _ctr.changeVideo(
        playerType,
        fromNetworkUrl,
        fromVimeoVideoId,
        fromVimeoUrls,
        fromAssets,
        fromFile,
        playerConfig,
      );

  ///Jumps to specific position of the video
  Future<void> videoStartsFrom(Duration moment) async {
    await _checkAndWaitTillInitialized();
    if (!_isInitialised) return;
    return _ctr.seekTo(moment);
  }

  ///Movies video forward from current duration to `_duration`
  Future<void> videoSeekForward(Duration _duration) async {
    await _checkAndWaitTillInitialized();
    if (!_isInitialised) return;
    return _ctr.seekForward(_duration);
  }

  ///Movies video backward from current duration to `_duration`
  Future<void> videoSeekBackward(Duration _duration) async {
    await _checkAndWaitTillInitialized();
    if (!_isInitialised) return;
    return _ctr.seekBackward(_duration);
  }
//TODO: support for playlist
}
