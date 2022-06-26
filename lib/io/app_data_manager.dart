
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:heart_tunes/dyno_json/dyno_json.dart';
import 'package:heart_tunes/io/track_manager.dart';
import 'package:heart_tunes/io/track_data.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

dynamic appSettingsStore;

Future<void> initAppStore() async {
  var dir = await getApplicationDocumentsDirectory();
  appSettingsStore = DynoJsonStore(storePath: join(dir.path, ".heart_tunes", "app-store.json"));
  await appSettingsStore.load();
  List<dynamic> trackList = appSettingsStore.get('tracks') ?? [];
  for(var trackData in trackList){
    addTrack(Track(path: trackData['path'], favourite: trackData['favourite'] as bool));
  }
}

bool isFirstStartup(){
  dynamic firstStartup = appSettingsStore.get('first-startup');
  return firstStartup == null || (firstStartup as bool);
}

void registerFirstStartup(){
  appSettingsStore.put('first-startup', false);
}

void saveTracksData(){
  appSettingsStore.put('tracks', jsonDecode(originallyOrderedTrackList.toString()));
}

void addAllTracksFromMusicDirectory(){

}

void addTrack(Track t){
  if(hasTrack(t)) {
    return;
  }
  tracks.add(t);
  originallyOrderedTrackList.add(t);
  saveTracksData();
  t.init();
}

bool hasTrack(Track t){
  for(Track tx in tracks){
    if(tx.toString() == t.toString()) {
      return true;
    }
  }
  return false;
}

Track? getTrack(String path){
  for(Track tx in tracks){
    if(tx.path == path) {
      return tx;
    }
  }
  return null;
}

void removeTrack(Track t){
  tracks.remove(t);
  originallyOrderedTrackList.remove(t);
  saveTracksData();
}

