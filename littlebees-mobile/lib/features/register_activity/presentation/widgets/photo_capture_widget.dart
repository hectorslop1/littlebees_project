import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../design_system/theme/app_colors.dart';

class PhotoCaptureWidget extends StatelessWidget {
  final File? photo;
  final VoidCallback onCapture;
  final VoidCallback? onRemove;
  final bool isLoading;
  final String label;

  const PhotoCaptureWidget({
    super.key,
    this.photo,
    required this.onCapture,
    this.onRemove,
    this.isLoading = false,
    this.label = 'Toca para tomar foto',
  });

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return _buildPhotoPreview();
    }

    return _buildCaptureButton();
  }

  Widget _buildCaptureButton() {
    return InkWell(
      onTap: isLoading ? null : onCapture,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.camera,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            photo!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    LucideIcons.x,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.check,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Foto capturada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
