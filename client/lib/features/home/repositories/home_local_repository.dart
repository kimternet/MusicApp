import 'package:client/features/home/models/song_model.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_local_repository.g.dart';

@riverpod
HomeLocalRepository homeLocalRepository(HomeLocalRepositoryRef ref) {
  return HomeLocalRepository();
}

class HomeLocalRepository {
  final Box box = Hive.box();
  final String hiddenSongsKey = 'hidden_songs';

  void uploadLocalSong(SongModel song) {
    box.put(song.id, song.toJson());
  }

  List<SongModel> loadSongs() {
    List<SongModel> songs = [];
    for (final key in box.keys) {
      if (key != hiddenSongsKey && !key.toString().startsWith('hidden_')) {
        songs.add(SongModel.fromJson(box.get(key)));
      }
    }
    return songs;
  }

  void removeSong(String songId) {
    if (box.containsKey(songId)) {
      box.delete(songId);
    }
  }
  
  // 숨겨진 곡 관리 메소드
  List<String> getHiddenSongIds() {
    final hiddenList = box.get(hiddenSongsKey, defaultValue: <String>[]);
    return List<String>.from(hiddenList);
  }
  
  void hideSong(String songId) {
    final List<String> hiddenSongs = getHiddenSongIds();
    if (!hiddenSongs.contains(songId)) {
      hiddenSongs.add(songId);
      box.put(hiddenSongsKey, hiddenSongs);
      print('곡이 로컬에서 숨겨짐: $songId');
    }
  }
  
  void showSong(String songId) {
    final List<String> hiddenSongs = getHiddenSongIds();
    if (hiddenSongs.contains(songId)) {
      hiddenSongs.remove(songId);
      box.put(hiddenSongsKey, hiddenSongs);
      print('숨겨진 곡이 다시 표시됨: $songId');
    }
  }
  
  bool isSongHidden(String songId) {
    return getHiddenSongIds().contains(songId);
  }
}