import 'package:client/core/provider/current_song_notifier.dart';
import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
// import 'package:client/core/utils.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicSlab extends ConsumerWidget {
  const MusicSlab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    // Safely access currentUserNotifierProvider with a fallback for when it's null
    final currentUser = ref.watch(currentUserNotifierProvider);
    final userFavorites = currentUser?.favorites ?? [];

    if (currentSong == null) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return const MusicPlayer();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween =
                  Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
                CurveTween(
                  curve: Curves.easeIn,
                ),
              );

              final offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Pallete.spotifyCardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'music-image',
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                currentSong.thumbnail_url,
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentSong.song_name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Pallete.whiteColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentSong.artist,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Pallete.subtitleText,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          // Only allow favorite if the user is logged in
                          if (currentUser != null) {
                            await ref.read(homeViewModelProvider.notifier).favSong(
                                  songId: currentSong.id,
                                );
                          }
                        },
                        iconSize: 22,
                        icon: Icon(
                          userFavorites
                                  .where((fav) => fav.song_id == currentSong.id)
                                  .toList()
                                  .isNotEmpty
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: userFavorites
                                  .where((fav) => fav.song_id == currentSong.id)
                                  .toList()
                                  .isNotEmpty 
                              ? Pallete.spotifyGreen 
                              : Pallete.whiteColor,
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Pallete.spotifyGreen,
                        ),
                        child: IconButton(
                          onPressed: songNotifier.playPause,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            songNotifier.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Pallete.whiteColor,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: StreamBuilder(
                stream: songNotifier.audioPlayer?.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data;
                  final duration = songNotifier.audioPlayer?.duration;
                  double progress = 0.0;
                  
                  if (position != null && duration != null && duration.inMilliseconds > 0) {
                    progress = position.inMilliseconds / duration.inMilliseconds;
                    progress = progress.clamp(0.0, 1.0);
                  }

                  return Stack(
                    children: [
                      // Background progress bar
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      // Foreground progress
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        height: 3,
                        width: progress * MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Pallete.spotifyGreen,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}