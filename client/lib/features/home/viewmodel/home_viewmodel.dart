import 'dart:io';
import 'dart:ui';

import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/models/fav_song_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_viewmodel.g.dart';

@riverpod
Future<List<SongModel>> getAllSongs(GetAllSongsRef ref) async {
  final currentUser = ref.watch(currentUserNotifierProvider);
  // 로그아웃 상태면 빈 목록 반환
  if (currentUser == null) {
    return [];
  }
  
  final token = currentUser.token;
  final res = await ref.watch(homeRepositoryProvider).getAllSongs(
        token: token,
      );

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<List<SongModel>> getFavSongs(GetFavSongsRef ref) async {
  final currentUser = ref.watch(currentUserNotifierProvider);
  // 로그아웃 상태면 빈 목록 반환
  if (currentUser == null) {
    return [];
  }
  
  final token = currentUser.token;
  final res = await ref.watch(homeRepositoryProvider).getFavSongs(
        token: token,
      );

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late HomeRepository _homeRepository;
  late HomeLocalRepository _homeLocalRepository;

  @override
  AsyncValue<String?> build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return const AsyncValue.data(null);
  }

  Future<void> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required String artist,
    required Color selectedColor,
  }) async {
    state = const AsyncValue.loading();
    
    // 사용자가 로그인되어 있는지 확인
    final currentUser = ref.read(currentUserNotifierProvider);
    if (currentUser == null) {
      state = AsyncValue.error('사용자 로그인이 필요합니다', StackTrace.current);
      return;
    }
    
    final res = await _homeRepository.uploadSong(
      selectedAudio: selectedAudio,
      selectedThumbnail: selectedThumbnail,
      songName: songName,
      artist: artist,
      hexCode: rgbToHex(selectedColor),
      token: currentUser.token,
    );

    final val = switch (res) {
      Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => state = AsyncValue.data(r),
    };
    print(val);
  }

  List<SongModel> getRecentlyPlayedSongs() {
    return _homeLocalRepository.loadSongs();
  }

  Future<void> favSong({required String songId}) async {
    state = const AsyncValue.loading();
    
    // 사용자가 로그인되어 있는지 확인
    final currentUser = ref.read(currentUserNotifierProvider);
    if (currentUser == null) {
      state = AsyncValue.error('사용자 로그인이 필요합니다', StackTrace.current);
      return;
    }
    
    final res = await _homeRepository.favSong(
      songId: songId,
      token: currentUser.token,
    );

    final val = switch (res) {
      Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => _favSongSuccess(r, songId),
    };
    print(val);
  }

  AsyncValue _favSongSuccess(bool isFavorited, String songId) {
    final userNotifier = ref.read(currentUserNotifierProvider.notifier);
    final currentUser = ref.read(currentUserNotifierProvider);
    
    // 사용자가 로그인되어 있는지 확인
    if (currentUser == null) {
      return state = AsyncValue.error('사용자 로그인이 필요합니다', StackTrace.current);
    }
    
    if (isFavorited) {
      userNotifier.addUser(
        currentUser.copyWith(
          favorites: [
            ...currentUser.favorites,
            FavSongModel(
              id: '',
              song_id: songId,
              user_id: '',
            ),
          ],
        ),
      );
    } else {
      userNotifier.addUser(
        currentUser.copyWith(
              favorites: currentUser.favorites
                  .where(
                    (fav) => fav.song_id != songId,
                  )
                  .toList(),
            ),
      );
    }
    ref.invalidate(getFavSongsProvider);
    return state = AsyncValue.data(isFavorited ? "favorited" : "unfavorited");
  }

  Future<void> deleteSong({required String songId}) async {
    state = const AsyncValue.loading();
    print('로컬 UI에서 곡 숨기기 시작: 곡 ID - $songId');
    
    try {
      // 로컬에서만 곡 숨기기
      _homeLocalRepository.hideSong(songId);
      
      // 현재 상태 갱신
      state = const AsyncValue.data("Song hidden successfully");
      
      // 리스트 갱신을 위해 프로바이더 무효화
      ref.invalidate(getAllSongsProvider);
      ref.invalidate(getFavSongsProvider);
      
      print('곡이 UI에서 숨겨짐: $songId');
    } catch (e) {
      print('UI에서 곡 숨기기 실패: $e');
      state = AsyncValue.error('Failed to hide song: $e', StackTrace.current);
    }
  }

  // 숨긴 곡 목록 가져오기
  List<String> getHiddenSongs() {
    return _homeLocalRepository.getHiddenSongIds();
  }
  
  // 곡이 숨겨져 있는지 확인
  bool isSongHidden(String songId) {
    return _homeLocalRepository.isSongHidden(songId);
  }
  
  // 숨긴 곡 다시 표시하기
  void unhideSong(String songId) {
    _homeLocalRepository.showSong(songId);
    ref.invalidate(getAllSongsProvider);
    ref.invalidate(getFavSongsProvider);
  }
}