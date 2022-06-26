
import 'package:flutter/material.dart';
import 'package:heart_tunes/components/track_tile.dart';

import '../io/track_data.dart';
import '../io/track_manager.dart';

class TrackListPanel extends StatefulWidget{

  final BoxConstraints constraints;

  const TrackListPanel({Key? key, required this.constraints}) : super(key: key);

  @override
  State<TrackListPanel> createState() => TrackListPanelState();
}

class TrackListPanelState extends State<TrackListPanel> {

  List<Track> trackList = tracks;

  void rebuild(){
    setState(() {
      // Nothing Here ...
    });
  }

  void setTrackList(List<Track> tracks){
    setState(() {
      trackList = tracks;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        color: Colors.grey.shade900,
        child: SingleChildScrollView(
          primary: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tracks.map((track) {
              return TrackTile(track: track);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
