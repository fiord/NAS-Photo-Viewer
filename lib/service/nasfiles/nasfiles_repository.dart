import 'dart:convert';
import 'package:nas_photo_viewer/data/shared_preference/shared_preferences.dart';
import 'package:nas_photo_viewer/model/nas_file.dart';

const String _nasfilesKey = 'nas_files';

class NasFilesRepository {
  Future<bool> saveNasFiles(List<List<NasFile>> nasfiles) async {
    String json = nasfiles
        .map((e) {
          return e.map((e2) {
            return jsonEncode(e2.toJSON);
          }).toList();
        })
        .toList()
        .toString();
    return await SharedPreference.setString(key: _nasfilesKey, value: json);
  }

  Future<List<List<NasFile>>?> getNasFiles() async {
    final res = await SharedPreference.getString(key: _nasfilesKey);
    if (res == null) {
      return null;
    }
    final obj = jsonDecode(res) as List<dynamic>;
    return obj.map<List<NasFile>>((dynamic e) {
      return (e as List<dynamic>).map<NasFile>((dynamic e2) {
        return NasFile.fromJSON(e2);
      }).toList();
    }).toList();
  }
}
