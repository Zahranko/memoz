import 'dart:io';
import 'package:flutter/material.dart';

// --- 1. DYNAMIC IMAGE GRID PICKER ---
class MultiImagePickerBox extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAddTap;
  final Function(int) onRemoveTap;

  const MultiImagePickerBox({
    Key? key,
    required this.images,
    required this.onAddTap,
    required this.onRemoveTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return GestureDetector(
        onTap: onAddTap,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate_outlined,
                size: 50,
                color: Colors.grey,
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to add photos',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // State B: Images selected -> Show Grid
    return SizedBox(
      height: 220, // Fixed height for the scrollable area
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1, // +1 for the "Add" button
        separatorBuilder: (ctx, i) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == images.length) {
            return GestureDetector(
              onTap: onAddTap,
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 30, color: Colors.grey),
                      Text(
                        'Add More',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[index],
                  width: 200,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => onRemoveTap(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
