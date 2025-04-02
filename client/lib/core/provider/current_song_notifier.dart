import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepository _homeLocalRepository;
  AudioPlayer? audioPlayer;
  bool isPlaying = false;

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  void updateSong(SongModel song) async {
    await audioPlayer?.dispose();
    audioPlayer = AudioPlayer();

    try {
      final audioSource = AudioSource.uri(
        Uri.parse(song.song_url),
        tag: MediaItem(
          id: song.id,
          title: song.song_name,
          artist: song.artist,
          artUri: Uri.parse(song.thumbnail_url),
        ),
      );
      
      await audioPlayer!.setAudioSource(audioSource);
      
      // 상태 변경 먼저 처리
      _homeLocalRepository.uploadLocalSong(song);
      state = song;
      
      // 이제 재생 시작
      audioPlayer!.play();
      isPlaying = true;
      
      audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          audioPlayer!.seek(Duration.zero);
          audioPlayer!.pause();
          isPlaying = false;
  
          this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
        }
      });
    } catch (e) {
      print('Error loading audio: $e');
      // 에러 처리
    }
  }

  void playPause() {
    if (isPlaying) {
      audioPlayer?.pause();
    } else {
      audioPlayer?.play();
    }
    isPlaying = !isPlaying;
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void seek(double val) {
    try {
      if (audioPlayer?.duration != null) {
        final position = Duration(
          milliseconds: (val * (audioPlayer!.duration?.inMilliseconds ?? 0)).toInt(),
        );
        audioPlayer!.seek(position);
      }
    } catch (e) {
      print('Seek error: $e');
    }
  }
  
  void resetState() {
    audioPlayer?.stop();
    audioPlayer?.dispose();
    audioPlayer = null;
    isPlaying = false;
    state = null;
    print('Current song state reset');
  }
}