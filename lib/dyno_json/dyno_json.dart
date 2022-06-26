
import 'dart:convert';
import 'dart:io';

class DynoJsonStore {
  final String storePath;
  late File storeFile;
  dynamic json;

  DynoJsonStore({required this.storePath});

  Future<void> load() async {
    storeFile = File(storePath);
    if(!(await storeFile.exists())){
      storeFile.parent.createSync(recursive: true);
      storeFile.createSync();
      storeFile.writeAsStringSync('{}', flush: true);
      json = jsonDecode("{}");
    }
    else {
      String text = await storeFile.readAsString();
      if(text.isEmpty){
        text = '{}';
      }
      json = jsonDecode(text);
    }
  }

  dynamic get(dynamic key){
    return json == null ? null : json[key];
  }

  dynamic put(dynamic key, dynamic value){
    json[key] = value;
    save();
  }

  Future<void> putAsync(dynamic key, dynamic value) async {
    json[key] = value;
    await storeFile.writeAsString(jsonEncode(json), flush: true);
  }

  void save(){
    storeFile.writeAsStringSync(jsonEncode(json), flush: true);
  }
}

