// lib/screens/car_inspection_stepper_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ✅ adjust this import according to your project structure
import '../models/car_model.dart';

/// =====================================================
/// CONTROLLER (GetX) - included so screen is runnable
/// =====================================================
class CarInspectionStepperController extends GetxController {
  final currentStep = 0.obs;
  final uiTick = 0.obs;

  final rcFetchLoading = false.obs;

  final steps = const [
    {'title': 'Registration', 'icon': Icons.description},
    {'title': 'Basic Info', 'icon': Icons.info},
    {'title': 'Exterior Front', 'icon': Icons.directions_car},
    {'title': 'Exterior Rear', 'icon': Icons.car_repair},
    {'title': 'Engine', 'icon': Icons.build},
    {'title': 'Interior', 'icon': Icons.airline_seat_recline_normal},
    {'title': 'Final', 'icon': Icons.checklist},
    {'title': 'Review', 'icon': Icons.preview},
  ];

  late final List<GlobalKey<FormState>> formKeys = List.generate(
    7,
    (_) => GlobalKey<FormState>(),
  );

  final CarModel carModel = CarModel();

  void touch() => uiTick.value++;

  void goPrev() {
    if (currentStep.value > 0) {
      currentStep.value--;
      touch();
    }
  }

  void goNextOrSubmit() {
    // last step = Review (no form)
    if (currentStep.value == steps.length - 1) return;

    // validate form steps only (0..6)
    if (currentStep.value <= 6) {
      final key = formKeys[currentStep.value];
      final ok = key.currentState?.validate() ?? true;
      if (!ok) {
        Get.snackbar(
          'Validation',
          'Please fill required fields',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
    }

    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      touch();
    }
  }

  /// Dummy fetch function (replace with your API)
  Future<void> fetchRcAdvancedAndFill() async {
    try {
      rcFetchLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // Example autofill:
      // carModel.make = 'Maruti';
      // carModel.model = 'Swift';
      // carModel.variant = 'VXI';
      // carModel.registrationDate = DateTime(2021, 3, 10);

      touch();
      Get.snackbar(
        'Fetched',
        'RC data fetched (demo)',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      rcFetchLoading.value = false;
    }
  }
}

/// =====================================================
/// SCREEN
/// =====================================================
class CarInspectionStepperScreen extends StatelessWidget {
  const CarInspectionStepperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CarInspectionStepperController());

    return Obx(() {
      controller.uiTick.value; // rebuild hook

      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Car Inspection',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: _buildCustomStepper(controller),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: _buildCurrentStep(controller),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(controller),
      );
    });
  }

  Widget _buildCustomStepper(CarInspectionStepperController c) {
    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: c.steps.length,
        itemBuilder: (context, index) {
          final isActive = index == c.currentStep.value;
          final isCompleted = index < c.currentStep.value;
          return Row(
            children: [
              _StepItem(
                index: index + 1,
                title: c.steps[index]['title'] as String,
                icon: c.steps[index]['icon'] as IconData,
                isActive: isActive,
                isCompleted: isCompleted,
              ),
              if (index < c.steps.length - 1)
                Container(
                  width: 36,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 44),
                  color: isCompleted
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[300],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep(CarInspectionStepperController c) {
    final m = c.carModel;

    switch (c.currentStep.value) {
      case 0:
        return RegistrationDocumentsStep(formKey: c.formKeys[0], carModel: m);
      case 1:
        return BasicInfoStep(formKey: c.formKeys[1], carModel: m);
      case 2:
        return ExteriorFrontStep(formKey: c.formKeys[2], carModel: m);
      case 3:
        return ExteriorRearStep(formKey: c.formKeys[3], carModel: m);
      case 4:
        return EngineMechanicalStep(formKey: c.formKeys[4], carModel: m);
      case 5:
        return InteriorElectronicsStep(formKey: c.formKeys[5], carModel: m);
      case 6:
        return FinalDetailsStep(formKey: c.formKeys[6], carModel: m);
      case 7:
        return ReviewStep(carModel: m);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar(CarInspectionStepperController c) {
    final step = c.currentStep.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (step > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: c.goPrev,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF2196F3), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Previous',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            if (step > 0) const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: c.goNextOrSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step == c.steps.length - 1 ? 'Done' : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      step == c.steps.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;

  const _StepItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor = isCompleted
        ? const Color(0xFF4CAF50)
        : isActive
        ? const Color(0xFF2196F3)
        : Colors.grey[300]!;
    final Color textColor = isActive
        ? const Color(0xFF2196F3)
        : Colors.grey[600]!;

    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? circleColor : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: circleColor.withOpacity(0.28),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive || isCompleted ? Colors.white : circleColor,
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 84,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

/// =====================================================
/// COMMON UI HELPERS
/// =====================================================
Widget buildSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    ],
  );
}

Widget buildModernCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

Widget buildModernTextField({
  required String label,
  required String hint,
  required IconData icon,
  required Function(String) onChanged,
  String? initialValue,
  TextInputType keyboardType = TextInputType.text,
  bool requiredField = true,
  Widget? suffix,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      key: ValueKey('$label-${initialValue ?? ""}'),
      initialValue: initialValue,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: (v) {
        if (!requiredField) return null;
        if (v == null || v.trim().isEmpty) return 'Please enter $label';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
      ),
    ),
  );
}

Widget buildModernDropdown({
  required BuildContext context,
  required String label,
  required String hint,
  required IconData icon,
  required List<String> items,
  required Function(String?) onChanged,
  String? value,
  bool requiredField = true,
}) {
  final validValue =
      (value != null && value.trim().isNotEmpty && items.contains(value))
      ? value
      : null;

  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label-${validValue ?? "empty"}'),
      value: validValue,
      validator: (v) {
        if (!requiredField) return null;
        if (v == null || v.isEmpty) return 'Please select $label';
        return null;
      },
      items: items
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
      ),
    ),
  );
}

/// ✅ Date formatter
String _fmtDate(DateTime? d) {
  if (d == null) return '';
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd/$mm/$yyyy';
}

/// ✅ WORKING Date Picker (tap to select date)
Widget buildModernDatePicker({
  required BuildContext context,
  required String label,
  required String hint,
  required IconData icon,
  required DateTime? value,
  required void Function(DateTime?) onChanged,
  bool requiredField = false,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final c = Get.find<CarInspectionStepperController>();

  return FormField<DateTime?>(
    initialValue: value,
    validator: (_) {
      if (!requiredField) return null;
      if (value == null) return 'Please select $label';
      return null;
    },
    builder: (state) {
      final display = value == null ? hint : _fmtDate(value);

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InkWell(
          onTap: () async {
            FocusScope.of(context).unfocus();
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: firstDate ?? DateTime(1990),
              lastDate: lastDate ?? DateTime(now.year + 30),
              helpText: label,
            );
            if (picked != null) {
              onChanged(picked);
              state.didChange(picked);
              c.touch();
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
              suffixIcon: const Icon(
                Icons.calendar_month,
                color: Color(0xFF2196F3),
              ),
              errorText: state.hasError ? state.errorText : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF2196F3),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              display,
              style: TextStyle(
                color: value == null ? Colors.grey[600] : Colors.black87,
                fontWeight: value == null ? FontWeight.w500 : FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// ✅ Multi Select bottom sheet
Widget buildModernMultiSelect({
  required BuildContext context,
  required String label,
  required String hint,
  required IconData icon,
  required List<String> options,
  required List<String> selected,
  required void Function(List<String>) onChanged,
  bool requiredField = false,
}) {
  final c = Get.find<CarInspectionStepperController>();

  return FormField<List<String>>(
    initialValue: selected,
    validator: (_) {
      if (!requiredField) return null;
      if (selected.isEmpty) return 'Please select $label';
      return null;
    },
    builder: (state) {
      final display = selected.isEmpty ? hint : selected.join(', ');

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InkWell(
          onTap: () async {
            FocusScope.of(context).unfocus();
            final res = await _openMultiSelectSheet(
              context: context,
              title: label,
              options: options,
              initial: selected,
            );
            if (res != null) {
              onChanged(res);
              state.didChange(res);
              c.touch();
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              errorText: state.hasError ? state.errorText : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF2196F3),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              display,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected.isEmpty ? Colors.grey[600] : Colors.black87,
                fontWeight: selected.isEmpty
                    ? FontWeight.w500
                    : FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<List<String>?> _openMultiSelectSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  required List<String> initial,
}) async {
  final temp = List<String>.from(initial);

  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, temp),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Expanded(
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (_, i) {
                        final opt = options[i];
                        final checked = temp.contains(opt);
                        return CheckboxListTile(
                          value: checked,
                          title: Text(opt),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                if (!temp.contains(opt)) temp.add(opt);
                              } else {
                                temp.remove(opt);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// ✅ Multi Images picker
Widget buildImagePicker({
  required String label,
  required List<String> imagePaths,
  required void Function(List<String>) onImagesChanged,
  int maxImages = 10,
}) {
  final c = Get.find<CarInspectionStepperController>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.image, color: Color(0xFF2196F3), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            '${imagePaths.length}/$maxImages',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 98,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imagePaths.length + 1,
          itemBuilder: (context, index) {
            if (index == imagePaths.length) {
              if (imagePaths.length >= maxImages) return const SizedBox();

              return GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();

                  if (maxImages == 1) {
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      onImagesChanged([picked.path]);
                      c.touch();
                    }
                    return;
                  }

                  final pickedFiles = await picker.pickMultiImage();
                  if (pickedFiles.isNotEmpty) {
                    final newPaths = pickedFiles.map((f) => f.path).toList();
                    final remaining = maxImages - imagePaths.length;
                    final toAdd = newPaths.take(remaining).toList();
                    onImagesChanged([...imagePaths, ...toAdd]);
                    c.touch();
                  }
                },
                child: Container(
                  width: 98,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF2196F3),
                      width: 2,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        color: Color(0xFF2196F3),
                        size: 30,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Add',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Stack(
              children: [
                Container(
                  width: 98,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[300]!),
                    image: DecorationImage(
                      image: FileImage(File(imagePaths[index])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 14,
                  child: GestureDetector(
                    onTap: () {
                      final updated = List<String>.from(imagePaths)
                        ..removeAt(index);
                      onImagesChanged(updated);
                      c.touch();
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

/// ✅ Validated multi-images wrapper
Widget buildValidatedMultiImagePicker({
  required String label,
  required List<String> imagePaths,
  required void Function(List<String>) onImagesChanged,
  required int minRequired,
  required int maxImages,
}) {
  return FormField<List<String>>(
    initialValue: imagePaths,
    validator: (_) {
      if (imagePaths.length < minRequired) {
        return 'Please add at least $minRequired image(s) for $label';
      }
      if (imagePaths.length > maxImages) {
        return 'Max $maxImages images allowed for $label';
      }
      return null;
    },
    builder: (state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildImagePicker(
            label: label,
            imagePaths: imagePaths,
            maxImages: maxImages,
            onImagesChanged: (p) {
              onImagesChanged(p);
              state.didChange(p);
            },
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

/// ✅ Single image picker + validation
Widget buildValidatedSingleImagePicker({
  required String label,
  required String imagePath,
  required void Function(String) onChanged,
  required bool mandatory,
}) {
  return FormField<String>(
    initialValue: imagePath,
    validator: (_) {
      if (!mandatory) return null;
      if (imagePath.trim().isEmpty) return 'Please add $label';
      return null;
    },
    builder: (state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _singleImageBox(
            label: label,
            imagePath: imagePath,
            onChanged: (p) {
              onChanged(p);
              state.didChange(p);
            },
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
          const SizedBox(height: 6),
        ],
      );
    },
  );
}

Widget _singleImageBox({
  required String label,
  required String imagePath,
  required void Function(String) onChanged,
}) {
  final c = Get.find<CarInspectionStepperController>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: imagePath.isEmpty
                  ? Center(
                      child: Text(
                        'No image selected',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(File(imagePath), fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    onChanged(picked.path);
                    c.touch();
                  }
                },
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Pick'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: imagePath.isEmpty
                    ? null
                    : () {
                        onChanged('');
                        c.touch();
                      },
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 14),
    ],
  );
}

/// ✅ Single video picker + validation
Widget buildValidatedSingleVideoPicker({
  required String label,
  required String videoPath,
  required void Function(String) onChanged,
  required bool mandatory,
}) {
  return FormField<String>(
    initialValue: videoPath,
    validator: (_) {
      if (!mandatory) return null;
      if (videoPath.trim().isEmpty) return 'Please add $label';
      return null;
    },
    builder: (state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _singleVideoBox(
            label: label,
            videoPath: videoPath,
            onChanged: (p) {
              onChanged(p);
              state.didChange(p);
            },
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

Widget _singleVideoBox({
  required String label,
  required String videoPath,
  required void Function(String) onChanged,
}) {
  final c = Get.find<CarInspectionStepperController>();
  final fileName = videoPath.isEmpty ? '' : videoPath.split('/').last;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.videocam, color: Color(0xFF2196F3)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      videoPath.isEmpty ? 'No video selected' : fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: videoPath.isEmpty
                            ? Colors.grey[600]
                            : Colors.black87,
                        fontWeight: videoPath.isEmpty
                            ? FontWeight.w700
                            : FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickVideo(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    onChanged(picked.path);
                    c.touch();
                  }
                },
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Pick'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: videoPath.isEmpty
                    ? null
                    : () {
                        onChanged('');
                        c.touch();
                      },
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 14),
    ],
  );
}

/// =====================================================
/// STEPS
/// =====================================================

class RegistrationDocumentsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarModel carModel;

  const RegistrationDocumentsStep({
    super.key,
    required this.formKey,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CarInspectionStepperController>();

    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Registration / RC', Icons.description),
                const SizedBox(height: 14),

                buildModernTextField(
                  label: 'Registration Number',
                  hint: 'e.g. DL 01 AB 1234',
                  icon: Icons.format_list_numbered,
                  initialValue: carModel.registrationNumber,
                  onChanged: (v) => carModel.registrationNumber = v,
                  requiredField: true,
                  suffix: Obx(() {
                    if (c.rcFetchLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: TextButton(
                        onPressed: () async {
                          await c.fetchRcAdvancedAndFill();
                        },
                        child: const Text('Fetch'),
                      ),
                    );
                  }),
                ),

                // ✅ Date pickers
                buildModernDatePicker(
                  context: context,
                  label: 'Registration Date',
                  hint: 'Select date',
                  icon: Icons.event,
                  value: carModel.registrationDate,
                  onChanged: (d) => carModel.registrationDate = d,
                  requiredField: false,
                ),
                buildModernDatePicker(
                  context: context,
                  label: 'Fitness Validity Till',
                  hint: 'Select date',
                  icon: Icons.verified,
                  value: carModel.fitnessTill,
                  onChanged: (d) => carModel.fitnessTill = d,
                  requiredField: false,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'RC Availability',
                  hint: 'Select',
                  icon: Icons.library_books,
                  options: const [
                    'Original',
                    'Photocopy',
                    'Duplicate',
                    'Lost',
                    'Lost with Photocopy',
                  ],
                  selected: carModel.registrationCertificateAvailability,
                  onChanged: (v) =>
                      carModel.registrationCertificateAvailability = v,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'RC Status',
                  hint: 'Select',
                  icon: Icons.verified,
                  items: const ['Okay', 'Damaged', 'Faded', 'Not Applicable'],
                  value: carModel.registrationCertificateStatus,
                  onChanged: (v) =>
                      carModel.registrationCertificateStatus = v ?? '',
                  requiredField: false,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'Mismatch In RC',
                  hint: 'Select mismatches',
                  icon: Icons.warning_amber,
                  options: const [
                    'No Mismatch',
                    'Make',
                    'Model',
                    'Variant',
                    'Owner Serial Number',
                    'Fuel Type',
                    'Color',
                    'Seating Capacity',
                    'Month & Year of Manufacture',
                  ],
                  selected: carModel.mismatchInRc,
                  onChanged: (v) => carModel.mismatchInRc = v,
                ),

                // ✅ RC Images: min 2 max 3
                buildValidatedMultiImagePicker(
                  label: 'RC Images (2-3)',
                  imagePaths: carModel.registrationCertificateImages,
                  minRequired: 2,
                  maxImages: 3,
                  onImagesChanged: (paths) =>
                      carModel.registrationCertificateImages = paths,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Road Tax', Icons.receipt_long),
                const SizedBox(height: 14),

                buildModernDropdown(
                  context: context,
                  label: 'Road Tax Type',
                  hint: 'Select',
                  icon: Icons.category,
                  items: const ['OTT', 'LTT'],
                  value: carModel.roadTaxValidity,
                  onChanged: (v) => carModel.roadTaxValidity = v ?? '',
                  requiredField: false,
                ),

                // buildModernDatePicker(
                //   context: context,
                //   label: 'Road Tax Validity Till',
                //   hint: 'Select date',
                //   icon: Icons.date_range,
                //   value: carModel.roadTaxValidTill,
                //   onChanged: (d) => carModel.roadTaxValidTill = d,
                //   requiredField: false,
                // ),

                FormField<List<String>>(
                  initialValue: carModel.roadTaxImages,
                  validator: (_) => carModel.roadTaxImages.length == 1
                      ? null
                      : 'Please add 1 Road Tax image',
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildImagePicker(
                          label: 'Road Tax Image (1)',
                          imagePaths: carModel.roadTaxImages,
                          maxImages: 1,
                          onImagesChanged: (p) {
                            carModel.roadTaxImages = p;
                            state.didChange(p);
                          },
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
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
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Hypothecation', Icons.account_balance),
                const SizedBox(height: 14),

                buildModernDropdown(
                  context: context,
                  label: 'Hypothecation Details',
                  hint: 'Select',
                  icon: Icons.account_balance_wallet,
                  items: const [
                    'Loan Active',
                    'Vaild Bank NOC Available',
                    'NOC Not Available, Loan Closed',
                  ],
                  value: carModel.hypothecationDetails,
                  onChanged: (v) => carModel.hypothecationDetails = v ?? '',
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Hypothecator Name',
                  hint: 'Bank / Finance company',
                  icon: Icons.account_balance,
                  initialValue: carModel.hypothecatorName,
                  onChanged: (v) => carModel.hypothecatorName = v,
                  requiredField: false,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Insurance', Icons.security),
                const SizedBox(height: 14),

                buildModernDropdown(
                  context: context,
                  label: 'Insurance Status',
                  hint: 'Select',
                  icon: Icons.policy,
                  items: const ['Valid', 'Expired', 'Not Available'],
                  value: carModel.insurance,
                  onChanged: (v) => carModel.insurance = v ?? '',
                  requiredField: false,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'Insurance Details',
                  hint: 'Select details',
                  icon: Icons.fact_check,
                  options: const [
                    'Yes But Not Seen',
                    'Expired',
                    'Third Party',
                    'Comprehensive',
                    'Zero Depriciation',
                  ],
                  selected: carModel.insuranceDetails,
                  onChanged: (v) => carModel.insuranceDetails = v,
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Insurance Policy Number',
                  hint: 'Enter',
                  icon: Icons.numbers,
                  initialValue: carModel.insurancePolicyNumber,
                  onChanged: (v) => carModel.insurancePolicyNumber = v,
                  requiredField: false,
                ),

                buildModernDatePicker(
                  context: context,
                  label: 'Insurance Validity Till',
                  hint: 'Select date',
                  icon: Icons.event_available,
                  value: carModel.insuranceValidity,
                  onChanged: (d) => carModel.insuranceValidity = d,
                  requiredField: false,
                ),

                // exactly 2 insurance copy images
                FormField<List<String>>(
                  initialValue: carModel.insuranceCopy,
                  validator: (_) => carModel.insuranceCopy.length == 2
                      ? null
                      : 'Please add exactly 2 Insurance Copy images',
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildImagePicker(
                          label: 'Insurance Copy Images (2)',
                          imagePaths: carModel.insuranceCopy,
                          maxImages: 2,
                          onImagesChanged: (p) {
                            carModel.insuranceCopy = p;
                            state.didChange(p);
                          },
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
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
                ),

                FormField<List<String>>(
                  initialValue: carModel.bothKeys,
                  validator: (_) => carModel.bothKeys.length == 2
                      ? null
                      : 'Please add exactly 2 Both Keys images',
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildImagePicker(
                          label: 'Both Keys Images (2)',
                          imagePaths: carModel.bothKeys,
                          maxImages: 2,
                          onImagesChanged: (p) {
                            carModel.bothKeys = p;
                            state.didChange(p);
                          },
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
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
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('RTO / Legal', Icons.gavel),
                const SizedBox(height: 14),

                buildModernDropdown(
                  context: context,
                  label: 'RTO NOC',
                  hint: 'Select',
                  icon: Icons.description_outlined,
                  items: const [
                    'Issued',
                    'Expired (issued 90 days ago)',
                    'Missing',
                  ],
                  value: carModel.rtoNoc,
                  onChanged: (v) => carModel.rtoNoc = v ?? '',
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'RTO Form 28',
                  hint: 'Select',
                  icon: Icons.assignment,
                  items: const [
                    'Issued',
                    'Expired (issued 90 days ago)',
                    'Missing',
                  ],
                  value: carModel.rtoForm28,
                  onChanged: (v) => carModel.rtoForm28 = v ?? '',
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Party Peshi',
                  hint: 'Select',
                  icon: Icons.people,
                  items: const [
                    'Seller will attend anywhere in West Bengal',
                    'Seller will appear in Kolkata region only',
                  ],
                  value: carModel.partyPeshi,
                  onChanged: (v) => carModel.partyPeshi = v ?? '',
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Duplicate Key',
                  hint: 'Select',
                  icon: Icons.vpn_key,
                  items: const ['Available', 'Missing'],
                  value: carModel.duplicateKey,
                  onChanged: (v) => carModel.duplicateKey = v ?? '',
                  requiredField: false,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Chassis & VIN', Icons.confirmation_number),
                const SizedBox(height: 14),

                buildValidatedSingleImagePicker(
                  label: 'Chassis Embossment Image',
                  imagePath: carModel.chassisEmbossmentImage,
                  mandatory: true,
                  onChanged: (p) => carModel.chassisEmbossmentImage = p,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Chassis Details',
                  hint: 'Select',
                  icon: Icons.check_circle,
                  items: const ['Okay', 'Not Okay'],
                  value: carModel.chassisDetails,
                  onChanged: (v) => carModel.chassisDetails = v ?? '',
                  requiredField: false,
                ),
                buildValidatedSingleImagePicker(
                  label: 'VIN Plate Image',
                  imagePath: carModel.vinPlateImage,
                  mandatory: true,
                  onChanged: (p) => carModel.vinPlateImage = p,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'VIN Plate Details',
                  hint: 'Select',
                  icon: Icons.info,
                  items: const ['Okay', 'VIN Plate Replaced', 'Not Available'],
                  value: carModel.vinPlateDetails,
                  onChanged: (v) => carModel.vinPlateDetails = v ?? '',
                  requiredField: false,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Pollution / Blacklist', Icons.eco),
                const SizedBox(height: 14),

                buildValidatedSingleImagePicker(
                  label: 'Pollution Certificate Image (optional)',
                  imagePath: carModel.pollutionCertificateImage,
                  mandatory: false,
                  onChanged: (p) => carModel.pollutionCertificateImage = p,
                ),


                buildModernTextField(
                  label: 'Pollution Certificate Number',
                  hint: 'Enter',
                  icon: Icons.numbers,
                  initialValue: carModel.pollutionCertificateNumber,
                  onChanged: (v) => carModel.pollutionCertificateNumber = v,
                  requiredField: false,
                ),

                buildModernDatePicker(
                  context: context,
                  label: 'Pollution Validity Till',
                  hint: 'Select date',
                  icon: Icons.event_note,
                  value: carModel.pollutionCertificateValidity,
                  onChanged: (d) => carModel.pollutionCertificateValidity = d,
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Blacklist Status',
                  hint: 'Select',
                  icon: Icons.warning,
                  items: const ['No', 'Yes', 'Under Verification'],
                  value: carModel.blacklistStatus,
                  onChanged: (v) => carModel.blacklistStatus = v ?? '',
                  requiredField: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BasicInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarModel carModel;

  const BasicInfoStep({
    super.key,
    required this.formKey,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Basic Vehicle Info', Icons.info),
                const SizedBox(height: 14),

                buildModernDropdown(
                  context: context,
                  label: 'Make',
                  hint: 'Select',
                  icon: Icons.factory,
                  items: const [
                    'Maruti',
                    'Hyundai',
                    'Honda',
                    'Tata',
                    'Mahindra',
                    'Toyota',
                    'Kia',
                    'Other',
                  ],
                  value: carModel.make,
                  onChanged: (v) => carModel.make = v ?? '',
                  requiredField: false,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'Model',
                  hint: 'Select',
                  icon: Icons.directions_car,
                  items: const [
                    'Swift',
                    'i20',
                    'City',
                    'Nexon',
                    'Creta',
                    'Other',
                  ],
                  value: carModel.model,
                  onChanged: (v) => carModel.model = v ?? '',
                  requiredField: false,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'Variant',
                  hint: 'Select',
                  icon: Icons.layers,
                  items: const ['Base', 'Mid', 'Top', 'Other'],
                  value: carModel.variant,
                  onChanged: (v) => carModel.variant = v ?? '',
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Engine Number',
                  hint: 'Enter engine number',
                  icon: Icons.numbers,
                  initialValue: carModel.engineNumber,
                  onChanged: (v) => carModel.engineNumber = v,
                  requiredField: false,
                ),
                buildModernTextField(
                  label: 'Chassis Number',
                  hint: 'Enter chassis number',
                  icon: Icons.confirmation_number,
                  initialValue: carModel.chassisNumber,
                  onChanged: (v) => carModel.chassisNumber = v,
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Seating Capacity',
                  hint: 'e.g. 5',
                  icon: Icons.event_seat,
                  keyboardType: TextInputType.number,
                  initialValue: carModel.seatingCapacity == 0
                      ? ''
                      : '${carModel.seatingCapacity}',
                  onChanged: (v) =>
                      carModel.seatingCapacity = int.tryParse(v) ?? 0,
                  requiredField: false,
                ),
                buildModernTextField(
                  label: 'Color',
                  hint: 'e.g. White',
                  icon: Icons.color_lens,
                  initialValue: carModel.color,
                  onChanged: (v) => carModel.color = v,
                  requiredField: false,
                ),
                buildModernTextField(
                  label: 'No. of Cylinders',
                  hint: 'e.g. 4',
                  icon: Icons.settings,
                  keyboardType: TextInputType.number,
                  initialValue: carModel.numberOfCylinders == 0
                      ? ''
                      : '${carModel.numberOfCylinders}',
                  onChanged: (v) =>
                      carModel.numberOfCylinders = int.tryParse(v) ?? 0,
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Body Type',
                  hint: 'e.g. Hatchback',
                  icon: Icons.directions_car_filled,
                  initialValue: carModel.bodyType,
                  onChanged: (v) => carModel.bodyType = v,
                  requiredField: false,
                ),
                buildModernTextField(
                  label: 'Norms',
                  hint: 'e.g. BS6',
                  icon: Icons.rule,
                  initialValue: carModel.norms,
                  onChanged: (v) => carModel.norms = v,
                  requiredField: false,
                ),
                buildModernTextField(
                  label: 'Vehicle Category',
                  hint: 'e.g. Private',
                  icon: Icons.category,
                  initialValue: carModel.vehicleCategory,
                  onChanged: (v) => carModel.vehicleCategory = v,
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Wheel Base',
                  hint: 'Enter',
                  icon: Icons.straighten,
                  initialValue: carModel.wheelBase,
                  onChanged: (v) => carModel.wheelBase = v,
                  requiredField: false,
                ),
                buildModernTextField(
                  label: 'Gross Vehicle Weight',
                  hint: 'Enter',
                  icon: Icons.scale,
                  initialValue: carModel.grossVehicleWeight,
                  onChanged: (v) => carModel.grossVehicleWeight = v,
                  requiredField: false,
                ),
                buildModernTextField(
                  label: 'Unladen Weight',
                  hint: 'Enter',
                  icon: Icons.monitor_weight,
                  initialValue: carModel.unladenWeight,
                  onChanged: (v) => carModel.unladenWeight = v,
                  requiredField: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExteriorFrontStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarModel carModel;

  const ExteriorFrontStep({
    super.key,
    required this.formKey,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Exterior - Front', Icons.directions_car),
                const SizedBox(height: 14),

                buildValidatedSingleImagePicker(
                  label: 'Front Main Image',
                  imagePath: carModel.frontMainImage,
                  mandatory: true,
                  onChanged: (p) => carModel.frontMainImage = p,
                ),

                // Bonnet
                buildModernMultiSelect(
                  context: context,
                  label: 'Bonnet',
                  hint: 'Select',
                  icon: Icons.car_repair,
                  options: const [
                    'Original',
                    'Minor Scratch',
                    'Major Dent',
                    'Repainted',
                    'Replaced',
                  ],
                  selected: carModel.bonnet,
                  onChanged: (v) => carModel.bonnet = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'Bonnet Images',
                  imagePaths: carModel.bonnetImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.bonnetImages = p,
                ),

                // Front Windshield
                buildModernMultiSelect(
                  context: context,
                  label: 'Front Windshield',
                  hint: 'Select',
                  icon: Icons.wind_power,
                  options: const ['Okay', 'Crack', 'Replaced', 'Not Available'],
                  selected: carModel.frontWindshield,
                  onChanged: (v) => carModel.frontWindshield = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'Front Windshield Images',
                  imagePaths: carModel.frontWindshieldImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.frontWindshieldImages = p,
                ),

                // Wiper/Washer
                buildModernMultiSelect(
                  context: context,
                  label: 'Front Wiper/Washer',
                  hint: 'Select',
                  icon: Icons.wash,
                  options: const ['Working', 'Not Working', 'Missing'],
                  selected: carModel.frontWiperWasher,
                  onChanged: (v) => carModel.frontWiperWasher = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'Front Wiper/Washer Images',
                  imagePaths: carModel.frontWiperWasherImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.frontWiperWasherImages = p,
                ),

                // Roof
                buildModernMultiSelect(
                  context: context,
                  label: 'Roof',
                  hint: 'Select',
                  icon: Icons.roofing,
                  options: const [
                    'Original',
                    'Scratch',
                    'Dent',
                    'Repainted',
                    'Replaced',
                  ],
                  selected: carModel.roof,
                  onChanged: (v) => carModel.roof = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'Roof Images',
                  imagePaths: carModel.roofImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.roofImages = p,
                ),

                // Front Bumper
                buildModernMultiSelect(
                  context: context,
                  label: 'Front Bumper',
                  hint: 'Select',
                  icon: Icons.car_crash,
                  options: const [
                    'Original',
                    'Scratch',
                    'Dent',
                    'Repainted',
                    'Replaced',
                  ],
                  selected: carModel.frontBumper,
                  onChanged: (v) => carModel.frontBumper = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'Front Bumper Images',
                  imagePaths: carModel.frontBumperImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.frontBumperImages = p,
                ),

                const SizedBox(height: 6),
                buildSectionHeader('LHS Front', Icons.turn_left),
                const SizedBox(height: 14),

                // LHS Headlamp
                buildModernMultiSelect(
                  context: context,
                  label: 'LHS Headlamp',
                  hint: 'Select',
                  icon: Icons.light,
                  options: const ['Okay', 'Cracked', 'Not Working', 'Replaced'],
                  selected: carModel.lhsHeadlamp,
                  onChanged: (v) => carModel.lhsHeadlamp = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'LHS Headlamp Images',
                  imagePaths: carModel.lhsHeadlampImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.lhsHeadlampImages = p,
                ),

                // LHS Foglamp
                buildModernMultiSelect(
                  context: context,
                  label: 'LHS Foglamp',
                  hint: 'Select',
                  icon: Icons.highlight,
                  options: const [
                    'Okay',
                    'Cracked',
                    'Not Working',
                    'Replaced',
                    'Not Available',
                  ],
                  selected: carModel.lhsFoglamp,
                  onChanged: (v) => carModel.lhsFoglamp = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'LHS Foglamp Images',
                  imagePaths: carModel.lhsFoglampImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.lhsFoglampImages = p,
                ),

                // LHS Fender
                buildModernMultiSelect(
                  context: context,
                  label: 'LHS Fender',
                  hint: 'Select',
                  icon: Icons.car_crash,
                  options: const [
                    'Original',
                    'Scratch',
                    'Dent',
                    'Repainted',
                    'Replaced',
                  ],
                  selected: carModel.lhsFender,
                  onChanged: (v) => carModel.lhsFender = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'LHS Fender Images',
                  imagePaths: carModel.lhsFenderImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.lhsFenderImages = p,
                ),

                // LHS Wheel/Tyre/ORVM
                buildModernMultiSelect(
                  context: context,
                  label: 'LHS Front Wheel',
                  hint: 'Select',
                  icon: Icons.circle,
                  options: const ['Okay', 'Scratched', 'Bent', 'Replaced'],
                  selected: carModel.lhsFrontWheel,
                  onChanged: (v) => carModel.lhsFrontWheel = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'LHS Front Wheel Images',
                  imagePaths: carModel.lhsFrontWheelImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.lhsFrontWheelImages = p,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'LHS Front Tyre',
                  hint: 'Select',
                  icon: Icons.tire_repair,
                  options: const ['Good', 'Average', 'Bad', 'Replace Soon'],
                  selected: carModel.lhsFrontTyre,
                  onChanged: (v) => carModel.lhsFrontTyre = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'LHS Front Tyre Images',
                  imagePaths: carModel.lhsFrontTyreImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.lhsFrontTyreImages = p,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'LHS ORVM',
                  hint: 'Select',
                  icon: Icons.remove_red_eye,
                  options: const ['Okay', 'Broken', 'Missing', 'Replaced'],
                  selected: carModel.lhsOrvm,
                  onChanged: (v) => carModel.lhsOrvm = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'LHS ORVM Images',
                  imagePaths: carModel.lhsOrvmImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.lhsOrvmImages = p,
                ),

                // Running boards
                buildModernMultiSelect(
                  context: context,
                  label: 'LHS Running Board',
                  hint: 'Select',
                  icon: Icons.linear_scale,
                  options: const [
                    'Okay',
                    'Dent',
                    'Scratch',
                    'Repaired',
                    'Replaced',
                  ],
                  selected: carModel.lhsRunningBoard,
                  onChanged: (v) => carModel.lhsRunningBoard = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'LHS Running Board Images',
                  imagePaths: carModel.lhsRunningBoardImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.lhsRunningBoardImages = p,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'RHS Running Board',
                  hint: 'Select',
                  icon: Icons.linear_scale,
                  options: const [
                    'Okay',
                    'Dent',
                    'Scratch',
                    'Repaired',
                    'Replaced',
                  ],
                  selected: carModel.rhsRunningBoard,
                  onChanged: (v) => carModel.rhsRunningBoard = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'RHS Running Board Images',
                  imagePaths: carModel.rhsRunningBoardImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.rhsRunningBoardImages = p,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExteriorRearStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarModel carModel;

  const ExteriorRearStep({
    super.key,
    required this.formKey,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    // bootDoorOpenImage in model is String, you can store as "|||"
    List<String> bootOpenImgs = carModel.bootDoorOpenImage.trim().isEmpty
        ? <String>[]
        : carModel.bootDoorOpenImage
              .split('|||')
              .where((e) => e.isNotEmpty)
              .toList();

    void setBootOpenImgs(List<String> imgs) {
      carModel.bootDoorOpenImage = imgs.join('|||');
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Exterior - Rear', Icons.car_repair),
                const SizedBox(height: 14),

                buildModernMultiSelect(
                  context: context,
                  label: 'Rear Bumper',
                  hint: 'Select',
                  icon: Icons.car_repair,
                  options: const [
                    'Original',
                    'Scratch',
                    'Dent',
                    'Repainted',
                    'Replaced',
                  ],
                  selected: carModel.rearBumper,
                  onChanged: (v) => carModel.rearBumper = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'Rear Bumper Images',
                  imagePaths: carModel.rearBumperImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.rearBumperImages = p,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'Rear Windshield',
                  hint: 'Select',
                  icon: Icons.wind_power,
                  options: const ['Okay', 'Crack', 'Replaced', 'Not Available'],
                  selected: carModel.rearWindshield,
                  onChanged: (v) => carModel.rearWindshield = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'Rear Windshield Images',
                  imagePaths: carModel.rearWindshieldImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.rearWindshieldImages = p,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'Rear Wiper/Washer',
                  hint: 'Select',
                  icon: Icons.wash,
                  options: const ['Working', 'Not Working', 'Missing'],
                  selected: carModel.rearWiperWasher,
                  onChanged: (v) => carModel.rearWiperWasher = v,
                ),
                buildValidatedMultiImagePicker(
                  label: 'Rear Wiper/Washer Images',
                  imagePaths: carModel.rearWiperWasherImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.rearWiperWasherImages = p,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Boot / Spare', Icons.luggage),
                const SizedBox(height: 14),

                // boot door open images (stored in String)
                FormField<List<String>>(
                  initialValue: bootOpenImgs,
                  validator: (_) => null,
                  builder: (state) {
                    return buildImagePicker(
                      label: 'Boot Door Open Images',
                      imagePaths: bootOpenImgs,
                      maxImages: 6,
                      onImagesChanged: (p) {
                        bootOpenImgs = p;
                        setBootOpenImgs(p);
                        state.didChange(p);
                      },
                    );
                  },
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'Boot Door',
                  hint: 'Select',
                  icon: Icons.door_sliding,
                  options: const [
                    'Okay',
                    'Scratch',
                    'Dent',
                    'Repainted',
                    'Replaced',
                  ],
                  selected: carModel.bootDoor,
                  onChanged: (v) => carModel.bootDoor = v,
                ),
                buildModernMultiSelect(
                  context: context,
                  label: 'Spare Wheel',
                  hint: 'Select',
                  icon: Icons.circle,
                  options: const ['Available', 'Not Available', 'Damaged'],
                  selected: carModel.spareWheel,
                  onChanged: (v) => carModel.spareWheel = v,
                ),
                buildModernMultiSelect(
                  context: context,
                  label: 'Spare Tyre',
                  hint: 'Select',
                  icon: Icons.tire_repair,
                  options: const ['Good', 'Average', 'Bad', 'Not Available'],
                  selected: carModel.spareTyre,
                  onChanged: (v) => carModel.spareTyre = v,
                ),
                buildModernMultiSelect(
                  context: context,
                  label: 'Boot Floor',
                  hint: 'Select',
                  icon: Icons.grid_4x4,
                  options: const ['Okay', 'Rust', 'Wet', 'Damaged'],
                  selected: carModel.bootFloor,
                  onChanged: (v) => carModel.bootFloor = v,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EngineMechanicalStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarModel carModel;

  const EngineMechanicalStep({
    super.key,
    required this.formKey,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Engine Bay', Icons.build),
                const SizedBox(height: 14),

                buildValidatedMultiImagePicker(
                  label: 'Engine Bay Images',
                  imagePaths: carModel.engineBayImages,
                  minRequired: 0,
                  maxImages: 10,
                  onImagesChanged: (p) => carModel.engineBayImages = p,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'Engine Condition',
                  hint: 'Select',
                  icon: Icons.engineering,
                  options: const ['Okay', 'Oil Leak', 'Noise', 'Repair Needed'],
                  selected: carModel.engine,
                  onChanged: (v) => carModel.engine = v,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'Comments on Engine',
                  hint: 'Select',
                  icon: Icons.comment,
                  options: const [
                    'Smooth',
                    'Vibration',
                    'Knocking',
                    'Overheating',
                  ],
                  selected: carModel.commentsOnEngine,
                  onChanged: (v) => carModel.commentsOnEngine = v,
                  requiredField: false,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'ABS',
                  hint: 'Select',
                  icon: Icons.safety_check,
                  items: const ['Present', 'Not Present', 'Not Working'],
                  value: carModel.abs,
                  onChanged: (v) => carModel.abs = v ?? '',
                  requiredField: false,
                ),

                buildValidatedSingleVideoPicker(
                  label: 'Engine Sound Video',
                  videoPath: carModel.engineSoundVideo,
                  mandatory: false,
                  onChanged: (p) => carModel.engineSoundVideo = p,
                ),
                buildValidatedSingleVideoPicker(
                  label: 'Exhaust Smoke Video',
                  videoPath: carModel.exhaustSmokeVideo,
                  mandatory: false,
                  onChanged: (p) => carModel.exhaustSmokeVideo = p,
                ),

                buildValidatedSingleImagePicker(
                  label: 'Cluster Meter With Engine Image',
                  imagePath: carModel.clusterMeterWithEngineImage,
                  mandatory: false,
                  onChanged: (p) => carModel.clusterMeterWithEngineImage = p,
                ),

                buildModernTextField(
                  label: 'Odometer Reading (KMs)',
                  hint: 'Enter',
                  icon: Icons.speed,
                  keyboardType: TextInputType.number,
                  initialValue: carModel.odometerReadingInKms,
                  onChanged: (v) => carModel.odometerReadingInKms = v,
                  requiredField: false,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'Fuel Level',
                  hint: 'Select',
                  icon: Icons.local_gas_station,
                  items: const ['Empty', '1/4', '1/2', '3/4', 'Full'],
                  value: carModel.fuelLevel,
                  onChanged: (v) => carModel.fuelLevel = v ?? '',
                  requiredField: false,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Test Drive / Mechanical', Icons.settings),
                const SizedBox(height: 14),

                buildModernDropdown(
                  context: context,
                  label: 'Steering',
                  hint: 'Select',
                  icon: Icons.sports_motorsports,
                  items: const ['Okay', 'Hard', 'Noise', 'Repair Needed'],
                  value: carModel.steering,
                  onChanged: (v) => carModel.steering = v ?? '',
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Clutch',
                  hint: 'Select',
                  icon: Icons.settings_suggest,
                  items: const ['Okay', 'Hard', 'Slipping', 'Repair Needed'],
                  value: carModel.clutch,
                  onChanged: (v) => carModel.clutch = v ?? '',
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Gear Shift',
                  hint: 'Select',
                  icon: Icons.swap_horiz,
                  items: const ['Smooth', 'Hard', 'Noise', 'Repair Needed'],
                  value: carModel.gearShift,
                  onChanged: (v) => carModel.gearShift = v ?? '',
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Transmission Type',
                  hint: 'Select',
                  icon: Icons.auto_mode,
                  items: const ['Manual', 'Automatic', 'AMT', 'CVT', 'DCT'],
                  value: carModel.transmissionType,
                  onChanged: (v) => carModel.transmissionType = v ?? '',
                  requiredField: false,
                ),
                buildModernTextField(
                  label: 'Comments on Transmission',
                  hint: 'Enter',
                  icon: Icons.comment,
                  initialValue: carModel.commentsOnTransmission,
                  onChanged: (v) => carModel.commentsOnTransmission = v,
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Drive Train',
                  hint: 'Select',
                  icon: Icons.settings,
                  items: const ['FWD', 'RWD', 'AWD', '4WD'],
                  value: carModel.driveTrain,
                  onChanged: (v) => carModel.driveTrain = v ?? '',
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Brakes',
                  hint: 'Select',
                  icon: Icons.car_crash,
                  items: const ['Okay', 'Noise', 'Weak', 'Repair Needed'],
                  value: carModel.brakes,
                  onChanged: (v) => carModel.brakes = v ?? '',
                  requiredField: false,
                ),
                buildModernDropdown(
                  context: context,
                  label: 'Suspension',
                  hint: 'Select',
                  icon: Icons.blur_circular,
                  items: const ['Okay', 'Noise', 'Weak', 'Repair Needed'],
                  value: carModel.suspension,
                  onChanged: (v) => carModel.suspension = v ?? '',
                  requiredField: false,
                ),

                buildValidatedSingleImagePicker(
                  label: 'Test Drive Odometer Image',
                  imagePath: carModel.testDriveOdometerImage,
                  mandatory: false,
                  onChanged: (p) => carModel.testDriveOdometerImage = p,
                ),
                buildModernTextField(
                  label: 'Test Drive Odometer Reading',
                  hint: 'Enter',
                  icon: Icons.speed,
                  initialValue: carModel.testDriveOdometerReading,
                  onChanged: (v) => carModel.testDriveOdometerReading = v,
                  requiredField: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InteriorElectronicsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarModel carModel;

  const InteriorElectronicsStep({
    super.key,
    required this.formKey,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader(
                  'Interior',
                  Icons.airline_seat_recline_normal,
                ),
                const SizedBox(height: 14),

                buildModernDropdown(
                  context: context,
                  label: 'IRVM',
                  hint: 'Select',
                  icon: Icons.remove_red_eye,
                  items: const ['Okay', 'Broken', 'Missing'],
                  value: carModel.irvm,
                  onChanged: (v) => carModel.irvm = v ?? '',
                  requiredField: false,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'Dashboard',
                  hint: 'Select',
                  icon: Icons.dashboard,
                  options: const ['Okay', 'Scratch', 'Crack', 'Repaired'],
                  selected: carModel.dashboard,
                  onChanged: (v) => carModel.dashboard = v,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'Infotainment System',
                  hint: 'Select',
                  icon: Icons.screen_share,
                  options: const [
                    'Working',
                    'Not Working',
                    'Missing',
                    'Aftermarket',
                  ],
                  selected: carModel.infotainmentSystem,
                  onChanged: (v) => carModel.infotainmentSystem = v,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'Inbuilt Speaker',
                  hint: 'Select',
                  icon: Icons.speaker,
                  items: const ['Working', 'Not Working', 'Missing'],
                  value: carModel.inbuiltSpeaker,
                  onChanged: (v) => carModel.inbuiltSpeaker = v ?? '',
                  requiredField: false,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'External Speaker',
                  hint: 'Select',
                  icon: Icons.speaker_group,
                  items: const ['Working', 'Not Working', 'Not Installed'],
                  value: carModel.externalSpeaker,
                  onChanged: (v) => carModel.externalSpeaker = v ?? '',
                  requiredField: false,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'Steering Mounted Media Controls',
                  hint: 'Select',
                  icon: Icons.settings_remote,
                  items: const ['Working', 'Not Working', 'Not Available'],
                  value: carModel.steeringMountedMediaControls,
                  onChanged: (v) =>
                      carModel.steeringMountedMediaControls = v ?? '',
                  requiredField: false,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'AC Type',
                  hint: 'Select',
                  icon: Icons.ac_unit,
                  options: const ['Manual', 'Automatic', 'Dual Zone'],
                  selected: carModel.acType,
                  onChanged: (v) => carModel.acType = v,
                ),

                buildModernMultiSelect(
                  context: context,
                  label: 'AC Cool',
                  hint: 'Select',
                  icon: Icons.thermostat,
                  options: const ['Good', 'Average', 'Not Cooling'],
                  selected: carModel.acCool,
                  onChanged: (v) => carModel.acCool = v,
                ),

                buildModernTextField(
                  label: 'Comments on AC',
                  hint: 'Enter',
                  icon: Icons.comment,
                  initialValue: carModel.commentsOnAc,
                  onChanged: (v) => carModel.commentsOnAc = v,
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'No. of Power Windows',
                  hint: 'e.g. 4',
                  icon: Icons.window,
                  keyboardType: TextInputType.number,
                  initialValue: carModel.noOfPowerWindows,
                  onChanged: (v) => carModel.noOfPowerWindows = v,
                  requiredField: false,
                ),
              ],
            ),
          ),

          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader(
                  'Airbags / Seats',
                  Icons.airline_seat_recline_extra,
                ),
                const SizedBox(height: 14),

                buildModernTextField(
                  label: 'Number of Airbags',
                  hint: 'e.g. 2',
                  icon: Icons.safety_divider,
                  keyboardType: TextInputType.number,
                  initialValue: carModel.numberOfAirbags == 0
                      ? ''
                      : '${carModel.numberOfAirbags}',
                  onChanged: (v) =>
                      carModel.numberOfAirbags = int.tryParse(v) ?? 0,
                  requiredField: false,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'Driver Side Airbag',
                  hint: 'Select',
                  icon: Icons.air,
                  items: const ['Present', 'Not Present', 'Deployed'],
                  value: carModel.driverSideAirbag,
                  onChanged: (v) => carModel.driverSideAirbag = v ?? '',
                  requiredField: false,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'Co-Driver Side Airbag',
                  hint: 'Select',
                  icon: Icons.air,
                  items: const ['Present', 'Not Present', 'Deployed'],
                  value: carModel.coDriverSideAirbag,
                  onChanged: (v) => carModel.coDriverSideAirbag = v ?? '',
                  requiredField: false,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'Seats Upholstery',
                  hint: 'Select',
                  icon: Icons.event_seat,
                  items: const [
                    'Fabric',
                    'Leather',
                    'Leatherette',
                    'Torn',
                    'Dirty',
                  ],
                  value: carModel.seatsUpholstery,
                  onChanged: (v) => carModel.seatsUpholstery = v ?? '',
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Interior Seating Capacity',
                  hint: 'e.g. 5',
                  icon: Icons.event_seat,
                  keyboardType: TextInputType.number,
                  initialValue: carModel.interiorSeatingCapacity == 0
                      ? ''
                      : '${carModel.interiorSeatingCapacity}',
                  onChanged: (v) =>
                      carModel.interiorSeatingCapacity = int.tryParse(v) ?? 0,
                  requiredField: false,
                ),

                buildValidatedSingleImagePicker(
                  label: 'Front Seats Driver Side Image',
                  imagePath: carModel.frontSeatsDriverSideImage,
                  mandatory: false,
                  onChanged: (p) => carModel.frontSeatsDriverSideImage = p,
                ),
                buildValidatedSingleImagePicker(
                  label: 'Rear Seats Right Side Image',
                  imagePath: carModel.rearSeatsRightSideImage,
                  mandatory: false,
                  onChanged: (p) => carModel.rearSeatsRightSideImage = p,
                ),
                buildValidatedSingleImagePicker(
                  label: 'Dashboard From Rear Seat Image',
                  imagePath: carModel.dashboardFromRearSeatImage,
                  mandatory: false,
                  onChanged: (p) => carModel.dashboardFromRearSeatImage = p,
                ),

                buildModernDropdown(
                  context: context,
                  label: 'Reverse Camera',
                  hint: 'Select',
                  icon: Icons.camera_rear,
                  items: const ['Working', 'Not Working', 'Not Available'],
                  value: carModel.reverseCamera,
                  onChanged: (v) => carModel.reverseCamera = v ?? '',
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Comment on Interior',
                  hint: 'Enter',
                  icon: Icons.comment,
                  initialValue: carModel.commentOnInterior,
                  onChanged: (v) => carModel.commentOnInterior = v,
                  requiredField: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FinalDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CarModel carModel;

  const FinalDetailsStep({
    super.key,
    required this.formKey,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Final Details', Icons.checklist),
                const SizedBox(height: 14),

                buildModernTextField(
                  label: 'Contact Number',
                  hint: 'Enter',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  initialValue: carModel.contactNumber,
                  onChanged: (v) => carModel.contactNumber = v,
                  requiredField: false,
                ),

                buildModernTextField(
                  label: 'Additional Details',
                  hint: 'Write notes',
                  icon: Icons.notes,
                  initialValue: carModel.additionalDetails,
                  onChanged: (v) => carModel.additionalDetails = v,
                  requiredField: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewStep extends StatelessWidget {
  final CarModel carModel;

  const ReviewStep({super.key, required this.carModel});

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              k,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '-' : v,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader('Review', Icons.preview),
          const SizedBox(height: 14),

          _kv('Registration Number', carModel.registrationNumber),
          _kv('Registration Date', _fmtDate(carModel.registrationDate)),
          _kv('Fitness Validity Till', _fmtDate(carModel.fitnessTill)),

          _kv('Make', carModel.make),
          _kv('Model', carModel.model),
          _kv('Variant', carModel.variant),

          _kv('Insurance Status', carModel.insurance),
          _kv('Insurance Validity Till', _fmtDate(carModel.insuranceValidity)),

          const SizedBox(height: 10),
          Text(
            'Tip: Submit action aap apne API call se connect kar sakte ho.',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
