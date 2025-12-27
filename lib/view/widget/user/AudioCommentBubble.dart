import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioCommentBubble extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const AudioCommentBubble({
    Key? key,
    required this.audioUrl,
    required this.isMe,
  }) : super(key: key);

  @override
  State<AudioCommentBubble> createState() => _AudioCommentBubbleState();
}

class _AudioCommentBubbleState extends State<AudioCommentBubble> {
  late AudioPlayer player;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();

    // Listen to states
    player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to position updates
    player.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => duration = newDuration);
    });

    player.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => position = newPosition);
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (isPlaying) {
      await player.pause();
    } else {
      await player.play(UrlSource(widget.audioUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Fixed width for audio bubble
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.brown : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: widget.isMe ? Colors.white : Colors.black87,
              size: 30,
            ),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                trackHeight: 3,
                activeTrackColor: widget.isMe ? Colors.white : Colors.black87,
                inactiveTrackColor:
                    widget.isMe ? Colors.white30 : Colors.grey[400],
                thumbColor: widget.isMe ? Colors.white : Colors.black87,
              ),
              child: Slider(
                min: 0,
                max:
                    duration.inSeconds.toDouble() > 0
                        ? duration.inSeconds.toDouble()
                        : 1.0,
                value: position.inSeconds.toDouble().clamp(
                  0,
                  duration.inSeconds.toDouble(),
                ),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await player.seek(position);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
