import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh gallery when entering
    // context.read<GameController>().loadGallery(); // Logic is internal to Init, but could ideally be exposed
  }

  @override
  Widget build(BuildContext context) {
    final images = context.watch<GameController>().galleryImages;

    return Scaffold(
      appBar: AppBar(title: const Text("Spell Gallery")),
      body: images.isEmpty
          ? const Center(child: Text("Magic sketches will appear here..."))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final path = images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
