import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_theme.dart';
import '../Controller/car_inspection_controller.dart';
import 'package:get/get.dart';

Widget buildImagePicker({
  required CarInspectionStepperController c,
  required String fieldKey,
  required String label,
  int maxImages = 10,
  bool enabled = true,
}) {
  final imagePaths = c.getLocalImages(fieldKey);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            '${imagePaths.length}/$maxImages',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Obx(() {
            final loading = c.isFieldUploading(fieldKey);
            final uploaded = c.isFieldUploaded(fieldKey);

            return InkWell(
              onTap: (!enabled || loading)
                  ? null
                  : () => c.uploadSelectedImagesForField(fieldKey),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: uploaded
                      ? kPrimary.withOpacity(0.10)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: uploaded
                        ? kPrimary.withOpacity(0.35)
                        : AppColor.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (loading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimary,
                        ),
                      )
                    else
                      Icon(
                        uploaded
                            ? Icons.check_circle_rounded
                            : Icons.cloud_upload_rounded,
                        size: 16,
                        color: uploaded ? kPrimary : AppColor.fieldIcon,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      uploaded ? "Uploaded" : "Upload",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: uploaded ? kPrimary : AppColor.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 98,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: enabled ? (imagePaths.length + 1) : imagePaths.length,
          itemBuilder: (context, index) {
            if (enabled && index == imagePaths.length) {
              if (imagePaths.length >= maxImages) return const SizedBox();
              return GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();

                  if (maxImages == 1) {
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      await c.setLocalImages(fieldKey, [picked.path]);
                    }
                    return;
                  }

                  final pickedFiles = await picker.pickMultiImage();
                  if (pickedFiles.isNotEmpty) {
                    final newPaths = pickedFiles.map((f) => f.path).toList();
                    final remaining = maxImages - imagePaths.length;
                    final toAdd = newPaths.take(remaining).toList();
                    await c.setLocalImages(fieldKey, [...imagePaths, ...toAdd]);
                  }
                },
                child: _addTile(),
              );
            }

            return Stack(
              children: [
                Container(
                  width: 98,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    image: DecorationImage(
                      image: FileImage(File(imagePaths[index])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (enabled)
                  Positioned(
                    top: 6,
                    right: 14,
                    child: GestureDetector(
                      onTap: () async {
                        final updated = List<String>.from(imagePaths)
                          ..removeAt(index);
                        await c.setLocalImages(fieldKey, updated);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      const SizedBox(height: 14),
    ],
  );
}

Widget _addTile() {
  return Container(
    width: 98,
    margin: const EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kPrimary, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_rounded, color: kPrimary, size: 30),
        SizedBox(height: 4),
        Text('Add', style: TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

Widget buildValidatedMultiImagePicker({
  required CarInspectionStepperController c,
  required String fieldKey,
  required String label,
  required int minRequired,
  required int maxImages,
  bool enabled = true,
}) {
  final imagePaths = c.getLocalImages(fieldKey);

  return FormField<List<String>>(
    initialValue: imagePaths,
    validator: (_) {
      final now = c.getLocalImages(fieldKey);
      if (now.length < minRequired) {
        return 'Please add at least $minRequired image(s) for $label';
      }
      if (now.length > maxImages) {
        return 'Max $maxImages images allowed for $label';
      }
      return null;
    },
    builder: (state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildImagePicker(
            c: c,
            fieldKey: fieldKey,
            label: label,
            maxImages: maxImages,
            enabled: enabled,
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 10),
              child: Text(
                state.errorText ?? '',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    },
  );
}
