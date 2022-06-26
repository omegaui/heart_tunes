

// ignore_for_file: avoid_init_to_null

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heart_tunes/io/track_manager.dart';
import 'package:heart_tunes/screens/home_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../io/app_data_manager.dart';
import '../io/track_data.dart';

List<Track> trackControlsInitializedTracks = [];

class TrackControls extends StatefulWidget{

  const TrackControls({Key? key}) : super(key: key);

  @override
  State<TrackControls> createState() => TrackControlsState();
}

class TrackControlsState extends State<TrackControls> {

  bool playing = false;
  bool shuffleOn = false;
  late Track? track = null;
  String currentPositionText = "0:0";
  double completionPercentage = 0.0;
  Duration currentPositionDuration = const Duration(seconds: 0);
  double currentPosition = 0.0;
  bool mouseInsideTimeline = false;
  int repeatType = 0; // 0 - off, 1 - repeat to and fro, 2 - repeat current

  IconData getRepeatIcon(){
    if(repeatType == 1){
      return Icons.repeat_on_outlined;
    }
    else if(repeatType == 2){
      return Icons.repeat_one_on_outlined;
    }
    return Icons.repeat;
  }

  void toggleRepeatType(){
    setState(() {
      if(repeatType != 2) {
        repeatType++;
      } else {
        repeatType = 0;
      }
      appSettingsStore.put('repeat-type', repeatType);
    });
  }

  void listen(Track track){
    if(this.track == track) {
      return;
    }
    this.track = track;
    this.track?.trackPlayerService.play();
    if(!trackControlsInitializedTracks.contains(track)) {
      this.track?.trackPlayerService.onPositionChangedList.add((event) async {
        if(this.track == track) {
          dynamic position = await track.trackPlayerService
              .getCurrentPosition();
          dynamic percentage = await track.trackPlayerService
              .getCompletionPercentage();
          if(!mouseInsideTimeline) {
            currentPositionDuration = await track.trackPlayerService.player.getCurrentPosition() as Duration;
          }
          setState(() {
            currentPositionText = position;
            completionPercentage = percentage;
            if(!mouseInsideTimeline) {
              currentPosition = currentPositionDuration.inSeconds.toDouble();
            }
          });
        }
      });
      this.track?.trackPlayerService.onPlayerStateChangedList.add((event) {
        if(this.track == track) {
          setState(() {
            playing = (event != PlayerState.paused && event != PlayerState.completed);
          });
        }
      });
      this.track?.trackPlayerService.onPlayerCompleteList.add(() {
        if(this.track == track) {
          setState(() {
            playing = false;
            if(repeatType == 2){
              track.trackPlayerService.replay();
            }
            else if(repeatType == 1){
              int index = tracks.indexOf(track);
              if(index == tracks.length - 1){
                putToView(tracks.first);
              }
              else if(index < tracks.length - 1){
                shiftTowardsNextTrack(track);
              }
            }
          });
        }
      });
      this.track?.onFavouriteToggleList.add((favourite) {
        setState(() { });
      });
      trackControlsInitializedTracks.add(track);
    }
    setState(() {
      playing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double? maxDuration = track?.trackPlayerService.duration?.abs().inSeconds.toDouble();
    maxDuration ??= 0;
    if(appSettingsStore != null){
      dynamic repeatTypeProperty = appSettingsStore.get('repeat-type');
      if(repeatTypeProperty != null){
        repeatType = repeatTypeProperty as int;
      }
    }
    if(track == null){
      return const Center(
        child: Text(
          "Pain is gone when Music is on",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return RawKeyboardListener(
      autofocus: true,
      onKey: (key) {
        if(track != null) {
          if(key.isKeyPressed(LogicalKeyboardKey.space)){
            track?.trackPlayerService.togglePlay();
          }
          else if(key.isKeyPressed(LogicalKeyboardKey.arrowLeft)){
            shiftTowardsPreviousTrack(track as Track);
          }
          else if(key.isKeyPressed(LogicalKeyboardKey.arrowRight)){
            shiftTowardsNextTrack(track as Track);
          }
        }
      },
      focusNode: FocusNode(),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: track?.trackMetaDataService.getArtworkImage(),
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            track?.trackMetaDataService.getTitle() as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if(repeatType == 2){
                        track?.trackPlayerService.replay();
                        return;
                      }
                      shiftTowardsPreviousTrack(track as Track);
                    },
                    icon: const Icon(
                      Icons.arrow_left,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                    splashRadius: 30,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        track?.trackPlayerService.togglePlay();
                      });
                    },
                    icon: Icon(
                      playing ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                    splashRadius: 30,
                  ),
                  IconButton(
                    onPressed: () {
                      if(repeatType == 2){
                        track?.trackPlayerService.replay();
                        return;
                      }
                      shiftTowardsNextTrack(track as Track);
                    },
                    icon: const Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                    splashRadius: 30,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 500,
                child: MouseRegion(
                  onEnter: (e) {
                    setState(() {
                      mouseInsideTimeline = true;
                    });
                  },
                  onExit: (e) {
                    setState(() {
                      mouseInsideTimeline = false;
                    });
                  },
                  child: Stack(
                    children: [
                      Visibility(
                        visible: !mouseInsideTimeline,
                        child: LinearPercentIndicator(
                          leading: Text(
                            currentPositionText,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            track?.trackPlayerService.getDuration() as String,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                          barRadius: const Radius.circular(10),
                          lineHeight: 6,
                          percent: completionPercentage,
                          progressColor: Colors.white,
                          backgroundColor: Colors.grey.shade900,
                        ),
                      ),
                      Visibility(
                        visible: mouseInsideTimeline,
                        child: SliderTheme(
                          data: SliderThemeData(
                            thumbColor: Colors.white,
                            activeTrackColor: Colors.white,
                            activeTickMarkColor: Colors.white,
                            overlayColor: Colors.white.withOpacity(0.2),
                            valueIndicatorColor: Colors.white,
                            valueIndicatorTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade900,
                            ),
                            trackHeight: 2,
                          ),
                          child: Slider(
                            label: currentPositionText,
                            max: maxDuration,
                            value: currentPosition,
                            onChanged: (value) {
                              setState(() {
                                currentPosition = value;
                                track?.trackPlayerService.seek(value.toInt());
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => (track?.favourite as bool ? const LinearGradient(colors: [Colors.red, Colors.amber]) : LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade700])).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: IconButton(
                      onPressed: () {
                        track?.toggleFavourite();
                      },
                      icon: Icon(track?.favourite as bool ? Icons.favorite : Icons.heart_broken),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => (shuffleOn ? const LinearGradient(colors: [Colors.green, Colors.blue]) : LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade700])).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          shuffleOn = !shuffleOn;
                          if(shuffleOn){
                            shuffle();
                            sortTrackWidgetKey.currentState?.sortOff();
                          }
                          else{
                            rebase();
                            sortTrackWidgetKey.currentState?.rebuild();
                          }
                          trackListPanelKey.currentState?.rebuild();
                        });
                      },
                      icon: Icon(shuffleOn ? Icons.shuffle_on_outlined : Icons.shuffle,
                      ),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => (repeatType != 0 ? const LinearGradient(colors: [Colors.orange, Colors.purple]) : LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade700])).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: IconButton(
                      onPressed: () {
                        toggleRepeatType();
                      },
                      icon: Icon(getRepeatIcon()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicIconButton extends StatefulWidget{

  final IconData icon;
  final IconData activeIcon;
  final Gradient gradient;
  final Gradient activeGradient;
  final bool active;
  final VoidCallback? onPressed;

  const DynamicIconButton({Key? key, required this.icon, required this.activeIcon, required this.gradient, required this.activeGradient, required this.active, this.onPressed}) : super(key: key);

  @override
  State<DynamicIconButton> createState() => _DynamicIconButtonState();
}

class _DynamicIconButtonState extends State<DynamicIconButton> {

  bool active = false;

  @protected
  @override
  @mustCallSuper
  void initState(){
    super.initState();
    active = widget.active;
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => (active ? widget.activeGradient: widget.gradient).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: IconButton(
        onPressed: () {
          widget.onPressed?.call();
          setState(() {
            active = !active;
          });
        },
        icon: Icon(active ? widget.activeIcon : widget.icon),
      ),
    );
  }
}
