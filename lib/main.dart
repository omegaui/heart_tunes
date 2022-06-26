// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heart_tunes/dialogs/show_info_dialog.dart';
import 'package:heart_tunes/io/track_manager.dart';
import 'package:heart_tunes/screens/home_screen.dart';

import 'io/app_data_manager.dart';
import 'io/track_data.dart';

final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey();

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Heart Tunes',
      debugShowCheckedModeBanner: false,
      home: ContentPane(),
    );
  }
}

class ContentPane extends StatefulWidget{
  const ContentPane({Key? key}) : super(key: key);

  @override
  State<ContentPane> createState() => _ContentPaneState();
}

class _ContentPaneState extends State<ContentPane> {

  @override
  @protected
  @mustCallSuper
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await initAppStore();
      if(isFirstStartup()) {
        await showInfoDialog(context);
        registerFirstStartup();
      }

      trackListPanelKey.currentState?.rebuild();
      sortTrackWidgetKey.currentState?.rebuild();

      dynamic autoplayOnProperty = appSettingsStore.get('autoplay');
      if(autoplayOnProperty != null){
        if(autoplayOnProperty as bool){
          dynamic trackData = appSettingsStore.get('last-active-track');
          if(trackData != null){
            String path = trackData['path'];
            Track? track = getTrack(path);
            if(track != null){
              putToView(track);
              dynamic autoPlayFromLastPositionOn = appSettingsStore.get('autoplayFromLastPositionOn');
              if(autoPlayFromLastPositionOn != null && autoPlayFromLastPositionOn as bool) {
                dynamic lastTrackPositionData = appSettingsStore.get(
                    'last-active-track-position');
                if (lastTrackPositionData != null) {
                  double lastTrackPosition = lastTrackPositionData as double;
                  Timer(const Duration(seconds: 1), () {
                    track.trackPlayerService.replayFrom(
                        lastTrackPosition.toInt());
                  });
                }
              }
              else {
                Timer(const Duration(seconds: 1), () {
                  track.trackPlayerService.replay();
                });
              }
            }
          }
        }
        homeScreenKey.currentState?.rebuild();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: HomeScreen(key: homeScreenKey),
    );
  }
}
