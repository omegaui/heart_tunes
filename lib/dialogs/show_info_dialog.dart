
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../io/resource_provider.dart';

final List<String> features = [
  "Play Multiple tracks at once",
  "Search Tracks",
  "Golden Play Button (Pause all and Play one)",
  "Autoplay last track on startup",
  "Autoplay from last position",
  "Shuffle and Repeat Support"
];

Future<void> showInfoDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (builder) {
      return Dialog(
        backgroundColor: Colors.grey.shade900,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade900,
                blurRadius: 4,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image(image: appIcon120),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Image(image: micIcon60),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Heart Tunes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "v1.0",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Features Highlight of this release",
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.map((feature) {
                  return Text(
                    feature,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  color: Colors.grey.shade800.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Heart Tunes lives at ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          tooltip: "https://github.com/omegaui",
                          onPressed: () async {
                            Uri url = Uri.dataFromString('https://github.com/omegaui');
                            await launchUrl(url);
                          },
                          icon: Image(image: githubIcon24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}



