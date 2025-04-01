import 'dart:io';

import 'package:client/core/provider/current_user_notifier.dart';
// import 'package:client/core/utils.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';
// import 'package:flutter/material.dart';
// import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_viewmodel.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late HomeRepository _homeRepository;

  @override
  AsyncValue<String?> build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    return const AsyncValue.data(null);
  }

  Future<void> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required String artist,
    required String hexCode,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(currentUserNotifierProvider);
    if (user == null) {
      state = AsyncValue.error('로그인이 필요합니다', StackTrace.current);
      return;
    }

    final res = await _homeRepository.uploadSong(
      selectedAudio: selectedAudio,
      selectedThumbnail: selectedThumbnail,
      songName: songName,
      artist: artist,
      hexCode: hexCode,
      token: user.token,
    );

    state = switch (res) {
      Left(value: final l) => AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => AsyncValue.data(r),
    };
  }
}
