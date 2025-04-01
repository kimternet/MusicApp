import 'dart:io';

import 'package:client/core/constants/server_constant.dart';
import 'package:http/http.dart' as http;

class HomeRepository {
  Future<void> uploadSong(
    File selectedImage,
    File selectedAudio,
    ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ServerConstant.serverUrl}/song/upload'),
    );

    request.files.addAll([
      await http.MultipartFile.fromPath('song', selectedAudio.path),
      await http.MultipartFile.fromPath('thumbnail', selectedImage.path),
    ]);

    request.fields.addAll({
      'artist': 'kimflutter',
      'song_name': 'project',
      'hex_code': 'FFFFFF'
    });

    request.headers.addAll({
      'x-auth-token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImUwNGJmOTFlLWQxYzEtNDNjNy1hNDZkLWY2Mjk2MTY0Y2NiOSJ9.J_4-EecVBoayPwFFKwzKKhAk2KpN1GSu5o5C6Y4AxD0'
    });
    final res = await request.send();
    print(res);
  }
}
