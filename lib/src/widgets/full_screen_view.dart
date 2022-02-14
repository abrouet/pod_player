part of 'package:fl_video_player/src/fl_video_player.dart';

class FullScreenView extends StatefulWidget {
  final String tag;
  const FullScreenView({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView>
    with TickerProviderStateMixin {
  late FlGetXVideoController _flCtr;
  @override
  void initState() {
    _flCtr = Get.find<FlGetXVideoController>(tag: widget.tag);
    _flCtr.keyboardFocusWeb?.removeListener(_flCtr.keyboadListner);

    super.initState();
  }

  @override
  void dispose() {
    _flCtr.keyboardFocusWeb?.requestFocus();
    _flCtr.keyboardFocusWeb?.addListener(_flCtr.keyboadListner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const circularProgressIndicator = CircularProgressIndicator(
      backgroundColor: Colors.black87,
      color: Colors.white,
      strokeWidth: 2,
    );
    return WillPopScope(
      onWillPop: () async {
        if (kIsWeb) {
          await _flCtr.disableFullScreen(
            context,
            widget.tag,
            enablePop: false,
          );
        }
        if (!kIsWeb) await _flCtr.disableFullScreen(context, widget.tag);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GetBuilder<FlGetXVideoController>(
          tag: widget.tag,
          builder: (_flCtr) => Center(
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: _flCtr.videoCtr == null
                      ? circularProgressIndicator
                      : _flCtr.videoCtr!.value.isInitialized
                          ? FlCorePlayer(
                              tag: widget.tag,
                              videoPlayerCtr: _flCtr.videoCtr!,
                              videoAspectRatio:
                                  _flCtr.videoCtr?.value.aspectRatio ?? 16 / 9,
                            )
                          : circularProgressIndicator,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
