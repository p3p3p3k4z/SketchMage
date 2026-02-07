import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';

class MagicResultScreen extends StatefulWidget {
  final String objectId;

  const MagicResultScreen({super.key, required this.objectId});

  @override
  State<MagicResultScreen> createState() => _MagicResultScreenState();
}

class _MagicResultScreenState extends State<MagicResultScreen> {
  AudioPlayer? _audioPlayer;
  String? _matchedKey;

  // Configuration of available assets
  final List<String> _availableKeys = ['cat', 'dog', 'cow', 'bird'];
  
  final Map<String, String> _imageExtensions = {
    'cat': 'png', 'cow': 'jpg', 'dog': 'jpg', 'bird': 'jpg',
  };

  final Map<String, String> _soundExtensions = {
    'cat': 'mp3', 'cow': 'wav', 'dog': 'mp3', 'bird': 'wav',
  };

  @override
  void initState() {
    super.initState();
    _findBestMatch();
    _initAudio();
  }

  void _findBestMatch() {
    final input = widget.objectId.toLowerCase();
    for (var key in _availableKeys) {
      if (input.contains(key)) {
        _matchedKey = key;
        break;
      }
    }
  }

  Future<void> _initAudio() async {
    if (_matchedKey == null) return;
    
    try {
      _audioPlayer = AudioPlayer();
      // Delay to avoid platform channel race conditions (MissingPluginException fix)
      await Future.delayed(const Duration(milliseconds: 800));
      _playMagicSound();
    } catch (e) {
      debugPrint("Could not initialize AudioPlayer: $e");
    }
  }

  Future<void> _playMagicSound() async {
    if (_audioPlayer == null || _matchedKey == null) return;

    final ext = _soundExtensions[_matchedKey!] ?? 'mp3';
    try {
      await _audioPlayer!.play(AssetSource('sound/$_matchedKey.$ext'));
    } catch (e) {
      debugPrint("Sound play error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String displayId = _matchedKey ?? widget.objectId;
    final String ext = _imageExtensions[_matchedKey ?? ''] ?? 'jpg';
    final String imagePath = 'assets/images/${_matchedKey ?? 'default'}.$ext';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. TRANSFORMED IMAGE
          if (_matchedKey != null)
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),

          // 2. OVERLAY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
              ),
            ),
          ),

          // 3. UI
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "MAGIC COMPLETE!",
                  style: TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                Text(
                  displayId.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 40),
                _buildActionButtons(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.deepPurple[900],
      child: const Center(child: Icon(Icons.auto_awesome, size: 100, color: Colors.white24)),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
            child: const Text("Back"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.read<GameController>().reset();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, foregroundColor: Colors.white),
            child: const Text("New Magic"),
          ),
        ),
      ],
    );
  }
}
