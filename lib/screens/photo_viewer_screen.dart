import 'package:flutter/material.dart';

class PhotoViewerScreen extends StatefulWidget {
  final List<String> photoUrls;
  final String? caption;
  final int initialIndex;
  const PhotoViewerScreen({
    super.key,
    required this.photoUrls,
    this.caption,
    this.initialIndex = 0,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.photoUrls.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiple = widget.photoUrls.length > 1;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          multiple
              ? '${widget.caption ?? ''}  (${_index + 1}/${widget.photoUrls.length})'
              : (widget.caption ?? ''),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photoUrls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          return Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                widget.photoUrls[i],
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
          );
        },
      ),
    );
  }
}