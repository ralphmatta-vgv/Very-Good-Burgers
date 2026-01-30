import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Full-screen editor to position a rectangular image inside a circular frame.
/// User can pan and zoom; result is the same image file with scale/offset for display.
class ProfilePhotoEditor extends StatefulWidget {
  const ProfilePhotoEditor({
    super.key,
    required this.imageFile,
    required this.onConfirm,
    required this.onCancel,
  });

  final File imageFile;
  final void Function(double scale, double offsetX, double offsetY) onConfirm;
  final VoidCallback onCancel;

  /// Reference circle size used for stored offset (so we can scale when displaying in 80px).
  static const double referenceSize = 280;

  @override
  State<ProfilePhotoEditor> createState() => _ProfilePhotoEditorState();
}

class _ProfilePhotoEditorState extends State<ProfilePhotoEditor> {
  double _scale = 1.0;
  double _offsetX = 0;
  double _offsetY = 0;

  double _baseScale = 1.0;
  double _baseOffsetX = 0;
  double _baseOffsetY = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = ProfilePhotoEditor.referenceSize;
    final circleLeft = (size.width - circleSize) / 2;
    final circleTop = (size.height - circleSize) / 2 - 24;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onCancel,
        ),
        title: const Text(
          'Position your photo',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Gesture area for pan/zoom over the circle
          Positioned(
            left: circleLeft,
            top: circleTop,
            width: circleSize,
            height: circleSize,
            child: GestureDetector(
              onScaleStart: (d) {
                _baseScale = _scale;
                _baseOffsetX = _offsetX;
                _baseOffsetY = _offsetY;
              },
              onScaleUpdate: (d) {
                setState(() {
                  _scale = (_baseScale * d.scale).clamp(0.5, 4.0);
                  _offsetX = _baseOffsetX + d.focalPointDelta.dx;
                  _offsetY = _baseOffsetY + d.focalPointDelta.dy;
                });
              },
              child: ClipOval(
                child: SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: OverflowBox(
                    maxWidth: circleSize * 3,
                    maxHeight: circleSize * 3,
                    alignment: Alignment.center,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(_offsetX, _offsetY)
                        ..scale(_scale),
                      child: Image.file(
                        widget.imageFile,
                        width: circleSize * 2,
                        height: circleSize * 2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Circular border overlay
          Positioned(
            left: circleLeft,
            top: circleTop,
            width: circleSize,
            height: circleSize,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54, width: 2),
                ),
              ),
            ),
          ),
          // Hint
          Positioned(
            left: 24,
            right: 24,
            bottom: 100,
            child: Text(
              'Pinch to zoom, drag to move',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onConfirm(_scale, _offsetX, _offsetY),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Use Photo'),
            ),
          ),
        ),
      ),
    );
  }
}
