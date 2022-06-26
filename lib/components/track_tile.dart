


import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:heart_tunes/components/track_controls.dart';
import 'package:heart_tunes/io/app_data_manager.dart';
import 'package:heart_tunes/io/track_manager.dart';
import 'package:heart_tunes/screens/home_screen.dart';

import '../io/track_data.dart';

final List<Track> trackTileInitializedTracks = [];

class TrackTile extends StatefulWidget{

  final Track track;

  const TrackTile({Key? key, required this.track}) : super(key: key);

  @override
  State<TrackTile> createState() => TrackTileState();
}

class TrackTileState extends State<TrackTile> {
  bool playing = false;
  bool favourite = false;
  bool mouseInsideTrackTile = false;
  double volume = 1;

  void rebuild(){
    setState(() {

    });
  }

  @override
  @protected
  @mustCallSuper
  void initState(){
    super.initState();
    favourite = widget.track.favourite;
    playing = widget.track.trackPlayerService.playing;
    if(!trackTileInitializedTracks.contains(widget.track)){
      widget.track.trackPlayerService.onPlayerStateChangedList.add((event) {
        if(mounted) {
          setState(() {
            playing =
            (event != PlayerState.paused && event != PlayerState.completed);
          });
        }
      });
      widget.track.onFavouriteToggleList.add((favourite) {
        if(mounted) {
          if(sortTrackWidgetKey.currentState?.index == 3){
            sortTrackWidgetKey.currentState?.rebuild();
          }
          setState(() {

          });
        }
      });
      widget.track.trackPlayerService.onPlayerCompleteList.add(() {
        if(mounted) {
          setState(() {
            playing = false;
          });
        }
      });
      trackTileInitializedTracks.add(widget.track);
    }
  }

  @override
  Widget build(BuildContext context) {
    favourite = widget.track.favourite;
    playing = widget.track.trackPlayerService.playing;
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          putToView(widget.track);
        },
        child: MouseRegion(
          onEnter: (e) {
            setState(() {
              mouseInsideTrackTile = true;
            });
          },
          onExit: (e) {
            setState(() {
              mouseInsideTrackTile = false;
            });
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: mouseInsideTrackTile ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                  blurRadius: 2,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  PlayButton(track: widget.track),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.track.trackMetaDataService.getTitle(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: mouseInsideTrackTile ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.track.trackMetaDataService.getArtist(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Visibility(
                          visible: mouseInsideTrackTile,
                          child: SliderTheme(
                            data: SliderThemeData(
                              thumbColor: Colors.blue,
                              activeTrackColor: Colors.blue,
                              activeTickMarkColor: Colors.blue,
                              overlayColor: Colors.blue.withOpacity(0.2),
                              valueIndicatorColor: Colors.blue,
                              valueIndicatorTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                              trackHeight: 2,
                            ),
                            child: Slider(
                              label: "Volume: ${100 * volume}",
                              value: volume,
                              max: 1,
                              min: 0,
                              onChanged: (value) {
                                setState(() {
                                  volume = value;
                                  widget.track.trackPlayerService.player.setVolume(volume);
                                });
                              },
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: ShaderMask(
                            shaderCallback: (bounds) => (playing ? LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade600]) : LinearGradient(colors: [Colors.white, Colors.grey.shade200])).createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: IconButton(
                              onPressed: () {
                                setState(() {});
                                if(!playing) {
                                  putToView(widget.track);
                                }
                                else{
                                  widget.track.trackPlayerService.pause();
                                }
                              },
                              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: ShaderMask(
                            shaderCallback: (bounds) => (favourite ? const LinearGradient(colors: [Colors.red, Colors.amber]) : LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade700])).createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: IconButton(
                              onPressed: () {
                                widget.track.toggleFavourite();
                              },
                              icon: Icon(favourite ? Icons.favorite : Icons.heart_broken),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: DynamicIconButton(
                            icon: Icons.remove,
                            activeIcon: Icons.remove_circle_outline,
                            gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade200]),
                            activeGradient: LinearGradient(colors: [Colors.red.shade200, Colors.red.shade600]),
                            active: true,
                            onPressed: () {
                              removeTrack(widget.track);
                              trackListPanelKey.currentState?.rebuild();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayButton extends StatefulWidget{

  final Track track;

  const PlayButton({Key? key, required this.track}) : super(key: key);

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {

  bool buttonVisible = false;

  void mouseEntered(e){
    setState(() {
      buttonVisible = true;
    });
  }

  void mouseExited(e){
    setState(() {
      buttonVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: mouseEntered,
      onExit: mouseExited,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            Visibility(
              visible: !buttonVisible,
              child: Image(
                image: widget.track.trackMetaDataService.getArtworkImage(),
                width: 40,
                height: 40,
              ),
            ),
            Visibility(
              visible: buttonVisible,
              child: Material(
                color: Colors.transparent,
                child: DynamicIconButton(
                  icon: Icons.play_arrow,
                  activeIcon: Icons.pause,
                  gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.amber.shade200]),
                  activeGradient: LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade600]),
                  active: false,
                  onPressed: () {
                    onlyPlay(widget.track);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
