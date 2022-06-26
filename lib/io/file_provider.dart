

import 'package:file_picker/file_picker.dart';
import 'package:heart_tunes/io/track_data.dart';

Future<List<Track>> pickTracks() async {
  List<Track> tracks = [];
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: true);
  if(result != null){
    for (var file in result.files) {
      // favourite is initially false as the track is newly added
      tracks.add(Track(path: file.path as String, favourite: false));
    }
  }
  return tracks;
}




