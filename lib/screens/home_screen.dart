import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heart_tunes/components/track_list_panel.dart';
import 'package:heart_tunes/dialogs/show_info_dialog.dart';
import 'package:heart_tunes/io/app_data_manager.dart';
import 'package:heart_tunes/io/resource_provider.dart';
import 'package:heart_tunes/io/track_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../components/track_controls.dart';

final GlobalKey<TrackListPanelState> trackListPanelKey = GlobalKey();
final GlobalKey<TrackControlsState> trackControlsKey = GlobalKey();
final GlobalKey<SortTrackWidgetState> sortTrackWidgetKey = GlobalKey();

final TextEditingController searchFieldController = TextEditingController();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WindowListener {
  bool autoplayOn = false;
  bool autoplayFromLastPositionOn = false;

  void rebuild() {
    setState(() {
      // just trigger a widget rebuild ...
    });
  }

  @override
  @protected
  @mustCallSuper
  void initState() {
    windowManager.addListener(this);
    windowManager.setPreventClose(false).whenComplete(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  @protected
  void onWindowClose() async {
    if (trackControlsKey.currentState?.track != null) {
      debugPrint('saving data');
      appSettingsStore.put(
          'last-active-track',
          jsonDecode(
              trackControlsKey.currentState?.track.toString() as String));
      appSettingsStore.put('last-active-track-position',
          trackControlsKey.currentState?.currentPosition);
    }
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    if (appSettingsStore != null) {
      dynamic autoplayOnProperty = appSettingsStore.get('autoplay');
      if (autoplayOnProperty != null) {
        autoplayOn = autoplayOnProperty as bool;
      }
      dynamic autoplayFromLastPositionOnProperty =
          appSettingsStore.get('autoplayFromLastPositionOn');
      if (autoplayFromLastPositionOnProperty != null) {
        autoplayFromLastPositionOn = autoplayFromLastPositionOnProperty as bool;
      }
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: SizedBox(
                        width: 240,
                        height: 240,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Image(image: appIcon240),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Image(image: micIcon120),
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                      colors: [Colors.white, Colors.grey.shade200])
                                  .createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: const Text(
                                "Heart Tunes",
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showInfoDialog(context);
                              },
                              icon: const Icon(
                                Icons.info_outline_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Multi-Track Music Player",
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () async {
                                await showTrackPickerDialog();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  "Add Tracks",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: searchFieldController,
                                focusNode: FocusNode(onKey: (node, key) {
                                  searchFor(searchFieldController.text);
                                  trackListPanelKey.currentState?.rebuild();
                                  if (key
                                      .isKeyPressed(LogicalKeyboardKey.space)) {
                                    return KeyEventResult.handled;
                                  }
                                  return KeyEventResult.ignored;
                                }),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent)),
                                  enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent)),
                                  disabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent)),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent)),
                                  hintText: "Search Tracks",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  icon: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                        colors: [
                                          Colors.red.shade700,
                                          Colors.green
                                        ]).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: const Icon(
                                      Icons.search_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SortTrackWidget(key: sortTrackWidgetKey),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Autoplay last Track on startup",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: autoplayOn,
                                    onChanged: (value) {
                                      setState(() {
                                        autoplayOn = !autoplayOn;
                                        appSettingsStore.put(
                                            'autoplay', autoplayOn);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Always autoplay from last position",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: autoplayFromLastPositionOn,
                                    onChanged: (value) {
                                      setState(() {
                                        autoplayFromLastPositionOn =
                                            !autoplayFromLastPositionOn;
                                        appSettingsStore.put(
                                            'autoplayFromLastPositionOn',
                                            autoplayFromLastPositionOn);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: constraints.maxHeight - 400,
                  child: TrackListPanel(
                      key: trackListPanelKey, constraints: constraints),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 100,
              child: Container(
                color: Colors.grey.shade800.withOpacity(0.2),
                child: TrackControls(key: trackControlsKey),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class SortTrackWidget extends StatefulWidget {
  const SortTrackWidget({Key? key}) : super(key: key);

  @override
  State<SortTrackWidget> createState() => SortTrackWidgetState();
}

class SortTrackWidgetState extends State<SortTrackWidget> {
  int index = 2;

  void sortOff() {
    setState(() {
      index = 0;
    });
  }

  void rebuild() {
    if (appSettingsStore != null) {
      dynamic sortByProperty = appSettingsStore.get('sort-by');
      if (sortByProperty != null) {
        index = sortByProperty as int;
      }
    }
    setState(() {
      if (index == 1) {
        sortOldest();
      } else if (index == 2) {
        sortNewest();
      } else if (index == 3) {
        sortFavourites();
      } else if (index == 4) {
        sortAtoZ();
      } else if (index == 5) {
        sortZtoA();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 18),
        Text(
          "Sort Track List by :",
          style: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              index = 1;
              sortNewest();
              trackListPanelKey.currentState?.setTrackList(tracks);
              appSettingsStore.put('sort-by', index);
            });
          },
          child: Text(
            "Newest",
            style: TextStyle(
              color: index == 1 ? Colors.blue.shade300 : Colors.grey.shade400,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              index = 2;
              sortOldest();
              trackListPanelKey.currentState?.setTrackList(tracks);
              appSettingsStore.put('sort-by', index);
            });
          },
          child: Text(
            "Oldest",
            style: TextStyle(
              color: index == 2 ? Colors.blue.shade300 : Colors.grey.shade400,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              index = 3;
              sortFavourites();
              trackListPanelKey.currentState?.setTrackList(tracks);
              appSettingsStore.put('sort-by', index);
            });
          },
          child: Text(
            "Favourites",
            style: TextStyle(
              color: index == 3 ? Colors.blue.shade300 : Colors.grey.shade400,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              index = 4;
              sortAtoZ();
              trackListPanelKey.currentState?.setTrackList(tracks);
              appSettingsStore.put('sort-by', index);
            });
          },
          child: Text(
            "A to Z",
            style: TextStyle(
              color: index == 4 ? Colors.blue.shade300 : Colors.grey.shade400,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              index = 5;
              sortZtoA();
              trackListPanelKey.currentState?.setTrackList(tracks);
              appSettingsStore.put('sort-by', index);
            });
          },
          child: Text(
            "Z to A",
            style: TextStyle(
              color: index == 5 ? Colors.blue.shade300 : Colors.grey.shade400,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
