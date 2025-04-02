// import 'package:client/core/provider/current_song_notifier.dart';
// import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/provider/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongsPage extends ConsumerWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayedSongs =
        ref.watch(homeViewModelProvider.notifier).getRecentlyPlayedSongs();
    final currentSong = ref.watch(currentSongNotifierProvider);
    
    // 숨겨진 곡 목록 가져오기
    final hiddenSongs = ref.watch(homeViewModelProvider.notifier).getHiddenSongs();
    
    // 최근 재생한 곡에서 숨겨진 곡 필터링
    final visibleRecentSongs = recentlyPlayedSongs
        .where((song) => !hiddenSongs.contains(song.id))
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: currentSong == null
          ? null
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  hexToColor(currentSong.hex_code),
                  Pallete.transparentColor,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 36),
            child: SizedBox(
              height: 280,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: visibleRecentSongs.length,
                itemBuilder: (context, index) {
                  final song = visibleRecentSongs[index];
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(currentSongNotifierProvider.notifier)
                          .updateSong(song);
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.grey[850],
                          title: Text(
                            '곡 관리',
                            style: TextStyle(color: Pallete.whiteColor),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.favorite, color: Pallete.whiteColor),
                                title: Text(
                                  '좋아요',
                                  style: TextStyle(color: Pallete.whiteColor),
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await ref
                                      .read(homeViewModelProvider.notifier)
                                      .favSong(songId: song.id);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text(
                                  '삭제',
                                  style: TextStyle(color: Pallete.whiteColor),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.grey[850],
                                      title: Text(
                                        '곡 삭제',
                                        style: TextStyle(color: Pallete.whiteColor),
                                      ),
                                      content: Text(
                                        '${song.song_name}을(를) 정말 삭제하시겠습니까?',
                                        style: TextStyle(color: Pallete.whiteColor),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            '취소',
                                            style: TextStyle(color: Pallete.whiteColor),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            // 알림 표시 (먼저 표시)
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${song.song_name} 삭제 중...'),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                            
                                            Navigator.pop(context);
                                            
                                            // 현재 재생 중인 곡이면 정지
                                            final currentSong = ref.read(currentSongNotifierProvider);
                                            if (currentSong != null && currentSong.id == song.id) {
                                              ref.read(currentSongNotifierProvider.notifier).resetState();
                                            }
                                            
                                            // 노래 삭제
                                            await ref
                                                .read(homeViewModelProvider.notifier)
                                                .deleteSong(songId: song.id);
                                          },
                                          child: Text(
                                            '삭제',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Pallete.borderColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  song.thumbnail_url,
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              song.song_name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Latest today',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ref.watch(getAllSongsProvider).when(
                data: (songs) {
                  // 로그아웃 후 songs가 빈 배열일 때 처리
                  if (songs.isEmpty) {
                    return SizedBox(
                      height: 260,
                      child: const Center(
                        child: Text(
                          '곡이 없거나 로그인이 필요합니다',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  
                  // 숨겨진 곡 목록 가져오기
                  final hiddenSongs = ref.watch(homeViewModelProvider.notifier).getHiddenSongs();
                  
                  // 숨겨진 곡 필터링
                  final visibleSongs = songs.where((song) => !hiddenSongs.contains(song.id)).toList();
                  
                  return SizedBox(
                    height: 260,
                    child: visibleSongs.isEmpty 
                        ? const Center(child: Text('곡이 없습니다.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: visibleSongs.length,
                      itemBuilder: (context, index) {
                        final song = visibleSongs[index];

                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(currentSongNotifierProvider.notifier)
                                .updateSong(song);
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.grey[850],
                                title: Text(
                                  '곡 관리',
                                  style: TextStyle(color: Pallete.whiteColor),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.favorite, color: Pallete.whiteColor),
                                      title: Text(
                                        '좋아요',
                                        style: TextStyle(color: Pallete.whiteColor),
                                      ),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await ref
                                            .read(homeViewModelProvider.notifier)
                                            .favSong(songId: song.id);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.delete, color: Colors.red),
                                      title: Text(
                                        '삭제',
                                        style: TextStyle(color: Pallete.whiteColor),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: Colors.grey[850],
                                            title: Text(
                                              '곡 삭제',
                                              style: TextStyle(color: Pallete.whiteColor),
                                            ),
                                            content: Text(
                                              '${song.song_name}을(를) 정말 삭제하시겠습니까?',
                                              style: TextStyle(color: Pallete.whiteColor),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  '취소',
                                                  style: TextStyle(color: Pallete.whiteColor),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  // 알림 표시 (먼저 표시)
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('${song.song_name} 삭제 중...'),
                                                      backgroundColor: Colors.orange,
                                                    ),
                                                  );
                                                  
                                                  Navigator.pop(context);
                                                  
                                                  // 현재 재생 중인 곡이면 정지
                                                  final currentSong = ref.read(currentSongNotifierProvider);
                                                  if (currentSong != null && currentSong.id == song.id) {
                                                    ref.read(currentSongNotifierProvider.notifier).resetState();
                                                  }
                                                  
                                                  // 노래 삭제
                                                  await ref
                                                      .read(homeViewModelProvider.notifier)
                                                      .deleteSong(songId: song.id);
                                                },
                                                child: Text(
                                                  '삭제',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        song.thumbnail_url,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    song.song_name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    song.artist,
                                    style: const TextStyle(
                                      color: Pallete.subtitleText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                error: (error, st) {
                  return Center(
                    child: Text(
                      error.toString(),
                    ),
                  );
                },
                loading: () => const Loader(),
              ),
        ],
      ),
    );
  }
}