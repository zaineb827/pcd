import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MeditationTimerPage extends StatefulWidget {
  final int duration; // in minutes
  final bool shouldPlayEndBell;
  final bool backgroundSound;

  const MeditationTimerPage({
    Key? key,
    required this.duration,
    required this.shouldPlayEndBell,
    required this.backgroundSound,
  }) : super(key: key);

  @override
  _MeditationTimerPageState createState() => _MeditationTimerPageState();
}

class _MeditationTimerPageState extends State<MeditationTimerPage> {
  late Timer _timer;
  int _remainingSeconds = 0;
  late AudioPlayer _audioPlayer;
  late AudioPlayer _bellPlayer;
  bool _isRunning = true;
  bool _showCompletion = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration * 60;
    _audioPlayer = AudioPlayer();
    _bellPlayer = AudioPlayer();
    _startTimer();
    if (widget.backgroundSound) _playBackgroundSound();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          _handleTimerCompletion();
        }
      });
    });
  }

  Future<void> _playBackgroundSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/background.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing background sound: $e');
    }
  }

  Future<void> _playEndBell() async {
    try {
      await _bellPlayer.setAsset('assets/sounds/end_bell.mp3');
      await _bellPlayer.play();
    } catch (e) {
      debugPrint('Error playing end bell: $e');
    }
  }

  Future<void> _handleTimerCompletion() async {
    setState(() => _showCompletion = true);
    if (widget.backgroundSound) await _audioPlayer.stop();
    if (widget.shouldPlayEndBell) await _playEndBell();

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _showCompletion = false);
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _togglePause() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
        if (widget.backgroundSound) _audioPlayer.play();
      } else {
        _timer.cancel();
        if (widget.backgroundSound) _audioPlayer.pause();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
    _bellPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            _audioPlayer.dispose();
            _bellPlayer.dispose();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/background.jpg', // Assure-toi d'ajouter cette image dans ton projet
            fit: BoxFit.cover,
          ),

          // Minuteur et boutons en bas
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_showCompletion)
                  const Text(
                    'Meditation Complete!',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      fontSize: 64,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                  onPressed: _togglePause,
                ),
                const SizedBox(height: 10),
                if (widget.backgroundSound && _isRunning)
                  const Text(
                    'Background sound is playing',
                    style: TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
