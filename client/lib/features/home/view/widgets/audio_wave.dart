import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioWave extends StatefulWidget {
  final String path;
  const AudioWave({super.key, required this.path});

  @override
  State<AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWave> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      print('초기화 시작 - 경로: ${widget.path}');
      final file = File(widget.path);
      if (await file.exists()) {
        print('파일 존재함: ${file.path}');
        
        // 플레이어 초기화
        await _player.setFilePath(widget.path);
        _duration = _player.duration ?? Duration.zero;
        
        // 위치 업데이트 리스너
        _player.positionStream.listen((position) {
          if (mounted) {
            setState(() {
              _position = position;
            });
          }
        });
        
        // 상태 업데이트 리스너
        _player.playerStateStream.listen((state) {
          if (mounted) {
            setState(() {
              _isPlaying = state.playing;
            });
          }
        });
        
        setState(() {
          _isInitialized = true;
        });
        print('오디오 플레이어 초기화 완료 - 길이: ${_duration.inSeconds}초');
      } else {
        print('파일이 존재하지 않음: ${widget.path}');
      }
    } catch (e) {
      print('오디오 플레이어 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 시간 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 프로그레스 바
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.white,
              overlayColor: Colors.blue.withOpacity(0.3),
            ),
            child: Slider(
              value: (_position.inMilliseconds > 0 && _duration.inMilliseconds > 0)
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0.0,
              onChanged: (value) {
                final newPosition = Duration(milliseconds: (value * _duration.inMilliseconds).round());
                _player.seek(newPosition);
              },
            ),
          ),
          
          // 재생 컨트롤
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  if (_isPlaying) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
