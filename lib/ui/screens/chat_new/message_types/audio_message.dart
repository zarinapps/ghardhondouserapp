import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:ebroker/ui/screens/widgets/custom_inkWell.dart';
import 'package:ebroker/utils/convert.dart';
import 'package:flutter/material.dart';

class AudioMessage extends Message {
  AudioMessage() {
    id = DateTime.now().toString();
  }
  @override
  String type = 'audio';
  late AudioPlayer audioPlayer;
  ValueNotifier<bool> isPlaying = ValueNotifier(false);
  int position = 0;
  int durationChanged = 0;
  ValueNotifier<Duration?> duration = ValueNotifier(Duration.zero);
  ValueNotifier<double?> progressValue = ValueNotifier(0);
  @override
  Future<void> init() async {
    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((Duration event) {
      durationChanged = event.inSeconds;
      duration.value = event;
    });

    audioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      isPlaying.value = event == PlayerState.playing;
    });
    audioPlayer.onPositionChanged.listen((Duration event) {
      position = event.inSeconds;
      duration.value = event;
      final progressIndicatorValue = ConvertNumber.inRange(
        currentValue: event.inSeconds.toDouble(),
        minValue: 0,
        maxValue: durationChanged.toDouble(),
        newMaxValue: 1,
        newMinValue: 0,
      );
      progressValue.value = progressIndicatorValue;
    });
    // New listener for player completion

    // audioPlayer.onPlayerComplete.listen((_) {
    //   // Completely reset the audio player
    //   audioPlayer.stop();
    //   audioPlayer.seek(Duration.zero);
    //   isPlaying.value = false;
    //   progressValue.value = 0;
    //   duration.value = Duration.zero;
    //   position = 0;
    //   durationChanged = 0;
    // });
    await audioPlayer.setSourceUrl(message!.audio!);
    // Modify the play/pause logic in the render method

    if (isSentNow && isSentByMe && isSent == false) {
      try {
        await context!.read<SendMessageCubit>().send(
              senderId: HiveUtils.getUserId().toString(),
              recieverId: message!.receiverId!,
              attachment: message?.file,
              message: message!.message!,
              proeprtyId: message!.propertyId!,
              audio: message?.audio,
            );
      } catch (e) {
        rethrow;
      }
    }

    ///if this message is not sent now so it will set id from server
    if (isSentNow == false) {
      id = message!.id!;
    }
    super.init();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await audioPlayer.pause();
    } else {
      // If the audio is at the end, reset it before playing
      if (position > durationChanged) {
        await audioPlayer.seek(Duration.zero);
      }
      if (audioPlayer.state == PlayerState.completed) {
        position = 0;
        durationChanged = 0;
        await audioPlayer.seek(Duration.zero);
        duration.value = Duration.zero;
        progressValue.value = 0;
        await audioPlayer.setSourceUrl(message!.audio!);
        await audioPlayer.resume();
        isPlaying.value = true;
      }
      await audioPlayer.resume();
    }
  }

  @override
  void onRemove() {
    context!.read<DeleteMessageCubit>().delete(
          messageId: id,
          receiverId: message!.receiverId!,
          senderId: '',
          propertyId: '',
        );
    super.onRemove();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await audioPlayer.stop();
  }

  @override
  Widget render(context) {
    return ValueListenableBuilder(
      valueListenable: duration,
      builder: (context, duration, child) {
        return Align(
          alignment: isSentByMe
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment:
                isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                height: 67,
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: context.screenWidth * 0.74,
                decoration: isSentByMe
                    ? getSentByMeDecoration(context)
                    : getOtherUserDecoration(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.5),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CustomInkWell(
                              onTap: togglePlayPause,
                              color: isSentByMe
                                  ? getSentByMeDecoration(context)
                                      .color!
                                      .darken(20)
                                  : getOtherUserDecoration(context)
                                      .color!
                                      .darken(20),
                              shape: BoxShape.circle,
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                width: 50 / 1.4,
                                height: 50 / 1.4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ValueListenableBuilder(
                                  valueListenable: isPlaying,
                                  builder: (context, isPlaying, child) {
                                    return Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow_outlined,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: ValueListenableBuilder(
                                valueListenable: progressValue,
                                builder: (context, progressValue, child) {
                                  return GradientProgressIndicator(
                                    key: Key(message!.id!),
                                    onProgressDrag: (progress) {
                                      final progressIndicatorValue =
                                          ConvertNumber.inRange(
                                        currentValue: progress,
                                        minValue: 0,
                                        maxValue: 1,
                                        newMaxValue: durationChanged.toDouble(),
                                        newMinValue: 0,
                                      );

                                      audioPlayer.seek(
                                        Duration(
                                          seconds:
                                              progressIndicatorValue.toInt(),
                                        ),
                                      );
                                    },
                                    value: progressValue,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.zero,
                              child: CustomText(
                                '${duration!.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<SendMessageCubit, SendMessageState>(
                        builder: (context, state) {
                          if (state is SendMessageInProgress) {
                            return const Icon(Icons.watch_later_outlined);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration getSentByMeDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.color.secondaryColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context.color.borderColor, width: 1.5),
    );
  }

  BoxDecoration getOtherUserDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.color.secondaryColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context.color.borderColor, width: 1.5),
    );
  }
}

Map<Key, List<double>> preserveHeightMap = {};

class GradientProgressIndicator extends ProgressIndicator {
  const GradientProgressIndicator({
    super.key,
    super.value,
    super.backgroundColor,
    this.width,
    super.color,
    super.valueColor,
    super.semanticsLabel,
    super.semanticsValue,
    this.minHeight,
    this.onProgressDrag,
    this.borderRadius = BorderRadius.zero,
  });

  final Function(double progress)? onProgressDrag;
  final double? minHeight;
  final BorderRadiusGeometry borderRadius;
  final double? width;

  @override
  State<GradientProgressIndicator> createState() =>
      _GradientLinearProgressIndicatorState();
}

class _GradientLinearProgressIndicatorState
    extends State<GradientProgressIndicator>
    with AutomaticKeepAliveClientMixin {
  List<double> heightMap = [];
  ValueNotifier<double> progress = ValueNotifier(0);
  final GlobalKey _globalKey = GlobalKey();
  double maxDragOffset = 0;
  int numberOfContainers = 0;

  @override
  void initState() {
    super.initState();
    if (!preserveHeightMap.containsKey(widget.key)) {
      Future.delayed(
        const Duration(milliseconds: 10),
        () {
          final widgetInfo = UiUtils.getWidgetInfo(context, _globalKey);
          maxDragOffset = widgetInfo['width']!;
          numberOfContainers = (maxDragOffset / 3).floor();
          heightMap = getRandomHeight(numberOfContainers);

          ///This is to solve pattern change issue ... this will store pattern.
          preserveHeightMap[widget.key!] = heightMap;
          setState(() {});
        },
      );

      progress.value = widget.value ?? 0.0;
    } else {
      heightMap = preserveHeightMap[widget.key!]!;
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant GradientProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      progress.value = widget.value ?? 0.0;
    }
    final widgetInfo = UiUtils.getWidgetInfo(context, _globalKey);
    if (widgetInfo['width'] != maxDragOffset) {
      final widgetInfo = UiUtils.getWidgetInfo(context, _globalKey);
      maxDragOffset = widgetInfo['width']!;
      numberOfContainers = (maxDragOffset / 3).floor();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTapDown: (details) {
        final inRange = ConvertNumber.inRange(
          currentValue: details.localPosition.dx.clamp(0, maxDragOffset),
          minValue: 0,
          maxValue: maxDragOffset,
          newMaxValue: 1,
          newMinValue: 0,
        );
        widget.onProgressDrag?.call(inRange);
        progress.value = inRange;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        final inRange = ConvertNumber.inRange(
          currentValue: details.localPosition.dx.clamp(0, maxDragOffset),
          minValue: 0,
          maxValue: maxDragOffset,
          newMaxValue: 1,
          newMinValue: 0,
        );
        progress.value = inRange;
        widget.onProgressDrag?.call(inRange);
      },
      child: ValueListenableBuilder(
        valueListenable: progress,
        builder: (context, progressValue, child) {
          return SizedBox(
            key: _globalKey,
            height: widget.minHeight,
            child: Row(
              children: [
                ...List.generate(heightMap.length, (index) {
                  final inRange = ConvertNumber.inRange(
                    currentValue: progressValue,
                    minValue: 0,
                    maxValue: 1,
                    newMaxValue: heightMap.length.toDouble(),
                    newMinValue: 0,
                  );
                  return Expanded(
                    child: Container(
                      height: heightMap[index],
                      width: 3,
                      decoration: BoxDecoration(
                        color: inRange < index
                            ? Colors.grey
                            : context.color.tertiaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  List<double> getRandomHeight(int count) {
    final heightMap = <double>[];

    for (var index = 0; index < count; index++) {
      final height = Random().nextDouble() * (widget.minHeight ?? 30.0);
      heightMap.add(height);
    }
    return heightMap;
  }

  @override
  // TODO(R): implement wantKeepAlive
  bool get wantKeepAlive => true;
}
