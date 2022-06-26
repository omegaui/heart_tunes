
// ignore_for_file: depend_on_referenced_packages, avoid_init_to_null

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:heart_tunes/io/app_data_manager.dart';
import 'package:heart_tunes/io/resource_provider.dart';
import 'package:heart_tunes/io/track_manager.dart';
import 'package:id3/id3.dart';

import 'package:path/path.dart';

final List<Track> currentlyPlayingTracks = [];

class Track {
  String path;
  bool favourite;
  late TrackMetaDataService trackMetaDataService;
  late TrackPlayerService trackPlayerService;
  final List<Function(bool value)> onFavouriteToggleList = [];
  Track({required this.path, required this.favourite});

  void init(){
    trackMetaDataService = TrackMetaDataService(track: this);
    trackMetaDataService.load();

    trackPlayerService = TrackPlayerService(track: this);
    trackPlayerService.load();
  }

  void toggleFavourite(){
    favourite = !favourite;
    saveTracksData();
    for (var onFavouriteToggle in onFavouriteToggleList) {
      onFavouriteToggle.call(favourite);
    }
  }
  
  @override
  String toString(){
    return "{\"path\": \"$path\", \"favourite\": $favourite}";
  }
}

class TrackMetaDataService{
  final Track track;
  late MP3Instance mp3instance;
  Map<String, dynamic>? dataMap;
  Uint8List? artworkBytes;
  TrackMetaDataService({required this.track});

  void load(){
    mp3instance = MP3Instance(File(track.path).readAsBytesSync());
    if(mp3instance.parseTagsSync()){
      dataMap = mp3instance.getMetaTags();
      if(dataMap != null) {
        dynamic apicMap = dataMap?['APIC'];
        if(apicMap != null) {
          artworkBytes = base64Decode(apicMap['base64']);
        }
      }
    }
  }

  String getTitle(){
    if (dataMap == null) {
      return basename(track.path);
    } else {
      dynamic title = dataMap?['Title'];
      return title ?? basename(track.path);
    }
  }

  String getArtist(){
    if (dataMap == null) {
      return "Unknown";
    } else {
      dynamic artist = dataMap?['Artist'];
      return artist ?? "Unknown";
    }
  }

  dynamic getArtworkImage(){
    return artworkBytes == null ? trackIcon40 : MemoryImage(getArtwork());
  }

  Uint8List getArtwork(){
    return artworkBytes as Uint8List;
  }
}

class TrackPlayerService{

  final Track track;
  late AudioPlayer player;
  late DeviceFileSource source;
  String durationString = "0:0";
  late Duration? duration = null;
  List<Function(dynamic value)?> onPositionChangedList = [];
  List<Function(dynamic value)?> onPlayerStateChangedList = [];
  List<Function?> onPlayerCompleteList = [];
  bool playing = false;
  bool completed = false;
  TrackPlayerService({required this.track});

  void load(){
    source = DeviceFileSource(track.path);

    player = AudioPlayer(playerId: track.path);
    player.setSource(source);
    player.setVolume(1.0);
    player.onPlayerComplete.listen((event) {
      playing = false;
      completed = true;
      for(var onPlayerComplete in onPlayerCompleteList){
        if(onPlayerComplete != null){
          onPlayerComplete.call();
        }
      }
    });
    player.onPositionChanged.listen((event) {
      for (var onPositionChanged in onPositionChangedList) {
        if(onPositionChanged != null) {
          onPositionChanged.call(event);
        }
      }
    });
    player.onPlayerStateChanged.listen((event) {
      playing = event == PlayerState.playing;
      completed = event == PlayerState.completed;
      for (var onPlayerStateChanged in onPlayerStateChangedList) {
        if(onPlayerStateChanged != null) {
          onPlayerStateChanged.call(event);
        }
      }
    });

    Function asyncCallback = () {};
    asyncCallback = () async {
      duration = await player.getDuration();
      if(duration != null){
        duration = duration?.abs();
        durationString = "${duration?.inMinutes}:${duration?.inSeconds.remainder(60)}";
      }
    };
    Timer(const Duration(seconds: 1), () {
      asyncCallback.call();
    });
  }

  void seekTo(double percent){
    player.seek(Duration(seconds: (percent * (duration?.inSeconds as int)).toInt()));
  }

  void seek(int seconds){
    player.seek(Duration(seconds: seconds));
  }

  void play(){
    playing = true;
    player.resume();
    if(!currentlyPlayingTracks.contains(track)) {
      currentlyPlayingTracks.add(track);
    }
  }

  void pause(){
    playing = false;
    player.pause();
    if(currentlyPlayingTracks.contains(track)) {
      currentlyPlayingTracks.remove(track);
    }
    if(currentlyPlayingTracks.isNotEmpty){
      Iterable<Track> reversedList = currentlyPlayingTracks.reversed;
      for(var track in reversedList) {
        if(track.trackPlayerService.playing) {
          putToView(track);
          break;
        }
      }
    }
  }

  void togglePlay(){
    if(playing){
      pause();
    }
    else{
      play();
    }
  }

  void stop(){
    playing = false;
    player.stop();
  }

  void replay(){
    player.seek(const Duration(seconds: 0));
    player.play(source);
  }

  void replayFrom(int seconds){
    player.seek(Duration(seconds: seconds));
    player.play(source);
  }

  Future<double> getCompletionPercentage() async {
    Duration? currentPosition = await player.getCurrentPosition();
    if(duration == null){
      return 0;
    }
    return (currentPosition?.inSeconds as int) / (duration?.inSeconds as int);
  }

  Future<String> getCurrentPosition() async {
    Duration? d = await player.getCurrentPosition();
    if(d != null){
      d = d.abs();
      return "${d.inMinutes}:${d.inSeconds.remainder(60)}";
    }
    return "";
  }

  String getDuration() {
    return durationString;
  }
}


