import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:client/core/theme/app_pallete.dart';

class AudioWave extends StatefulWidget {
  final String path;
  const AudioWave({super.key, required this.path});

  @override
  State<AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWave> with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
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
              if (_isPlaying) {
                _animationController.repeat(reverse: true);
              } else {
                _animationController.stop();
              }
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
    _animationController.dispose();
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
        height: 65,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 오버플로우를 방지하는 새로운 레이아웃 - 웨이브폼 추가
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 상단 컨트롤 바
          Row(
            children: [
              // 재생/일시정지 버튼
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  if (_isPlaying) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                  setState(() {
                    _isPlaying = !_isPlaying;
                    if (_isPlaying) {
                      _animationController.repeat(reverse: true);
                    } else {
                      _animationController.stop();
                    }
                  });
                },
              ),
              const SizedBox(width: 4),
              
              // 현재 시간
              Text(
                _formatDuration(_position),
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                    activeTrackColor: Pallete.gradient2,
                    inactiveTrackColor: Colors.grey[800],
                    thumbColor: Colors.white,
                    overlayColor: Pallete.gradient2.withOpacity(0.3),
                  ),
                  child: Slider(
                    value: (_position.inMilliseconds > 0 && _duration.inMilliseconds > 0)
                        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                        : 0.0,
                    onChanged: (value) {
                      final newPosition = Duration(milliseconds: (value * _duration.inMilliseconds).round());
                      _player.seek(newPosition);
                    },
                  ),
                ),
              ),
              
              // 총 시간
              Text(
                _formatDuration(_duration),
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
          
          // 웨이브폼 애니메이션
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: WaveformPainter(
                    animation: _animationController.value,
                    isPlaying: _isPlaying,
                    progress: (_position.inMilliseconds / (_duration.inMilliseconds > 0 ? _duration.inMilliseconds : 1)).clamp(0.0, 1.0),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double animation;
  final bool isPlaying;
  final double progress;
  
  WaveformPainter({
    required this.animation,
    required this.isPlaying,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final barCount = 40;
    final barWidth = size.width / barCount - 2;
    
    final playedPaint = Paint()
      ..color = Pallete.gradient2
      ..style = PaintingStyle.fill;
    
    final unplayedPaint = Paint()
      ..color = Pallete.borderColor
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < barCount; i++) {
      // 웨이브 패턴 생성
      final seed = i % 10;
      double normalHeight;
      
      // 다양한 높이의 바 생성
      if (seed < 3) {
        normalHeight = 0.8;
      } else if (seed < 5) {
        normalHeight = 0.6;
      } else if (seed < 7) {
        normalHeight = 0.4;
      } else {
        normalHeight = 0.2;
      }
      
      // 재생중일 때 애니메이션 효과
      double heightModifier = 1.0;
      if (isPlaying) {
        // 애니메이션 적용
        final animModifier = math.sin((animation * math.pi * 2) + (i / 5)).abs() * 0.3 + 0.7;
        heightModifier = animModifier;
      }
      
      final barHeight = normalHeight * size.height * heightModifier;
      
      // 바의 위치 계산
      final left = i * (barWidth + 2);
      final top = (size.height - barHeight) / 2;
      
      // 진행 상태에 따라 색상 선택
      final paint = (i / barCount) <= progress ? playedPaint : unplayedPaint;
      
      // 바 그리기
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.isPlaying != isPlaying ||
           oldDelegate.progress != progress;
  }
}
