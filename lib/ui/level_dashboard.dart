import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart' as import_gallery;

class LevelDashboard extends StatelessWidget {
  const LevelDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SketchMage Levels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const import_gallery.GalleryScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _LevelCard(id: 1, title: "1. Life Rain", color: Colors.blue),
            _LevelCard(id: 2, title: "2. Bubble Shield", color: Colors.purple),
            _LevelCard(id: 3, title: "3. Crossing the Abyss", color: Colors.brown),
            _LevelCard(id: 4, title: "4. Lightning Mountain", color: Colors.yellow[700]!),
            _LevelCard(id: 5, title: "5. Acrobatic Flight", color: Colors.red),
            _LevelCard(id: 99, title: "Creative Mode", color: Colors.teal, isCreative: true),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int id;
  final String title;
  final Color color;
  final bool isCreative;

  const _LevelCard({
    required this.id,
    required this.title,
    required this.color,
    this.isCreative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.2),
      child: InkWell(
        onTap: () {
          context.read<GameController>().setLevel(id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCreative ? Icons.auto_awesome : Icons.edit,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
