import 'package:flutter/material.dart';

class PhotoViewerScreen extends StatelessWidget {
  final String photoUrl;
  final String? caption;
  const PhotoViewerScreen({super.key, required this.photoUrl, this.caption});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: caption != null ? Text(caption!) : null,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            photoUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (context, error, stack) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Could not load photo.', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}