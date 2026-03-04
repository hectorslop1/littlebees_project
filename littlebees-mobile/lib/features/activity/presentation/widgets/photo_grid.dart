import 'package:flutter/material.dart';
import '../../domain/photo_model.dart';
import 'photo_tile.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;

  const PhotoGrid({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return PhotoTile(photo: photo, index: index);
        },
      ),
    );
  }
}
