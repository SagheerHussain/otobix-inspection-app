import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:otobix_inspection_app/Controller/car_inspection_controller.dart';
import 'package:otobix_inspection_app/models/car_model.dart';

class CarInspectionStepperScreen extends StatelessWidget {
  const CarInspectionStepperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CarInspectionStepperController());

    return Obx(() {
      controller.uiTick.value;

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
              fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: _buildCustomStepper(controller),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStep(controller),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(controller),
      );
    });
  }

  Widget _buildCustomStepper(CarInspectionStepperController c) {
    return SizedBox(
      height: 100,
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
                title: c.steps[index]['title'],
                icon: c.steps[index]['icon'],
                isActive: isActive,
                isCompleted: isCompleted,
              ),
              if (index < c.steps.length - 1)
                Container(
                  width: 40,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 50),
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
    final carModel = c.carModel;

    switch (c.currentStep.value) {
      case 0:
        return RegistrationDocumentsStep(
          formKey: c.formKeys[0],
          carModel: carModel,
        );
      case 1:
        return BasicInfoStep(formKey: c.formKeys[1], carModel: carModel);
      case 2:
        return ExteriorFrontStep(formKey: c.formKeys[2], carModel: carModel);
      case 3:
        return ExteriorRearStep(formKey: c.formKeys[3], carModel: carModel);
      case 4:
        return EngineMechanicalStep(formKey: c.formKeys[4], carModel: carModel);
      case 5:
        return InteriorElectronicsStep(
          formKey: c.formKeys[5],
          carModel: carModel,
        );
      case 6:
        return FinalDetailsStep(formKey: c.formKeys[6], carModel: carModel);
      case 7:
        return ReviewStep(carModel: carModel);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNavigationBar(CarInspectionStepperController c) {
    final step = c.currentStep.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF2196F3), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (step > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: c.goNextOrSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step == c.steps.length - 1 ? 'Submit' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

/* =========================================================
   STEP ITEM (TOP STEPPER)
   ========================================================= */
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
    Color circleColor;
    Color textColor;

    if (isCompleted) {
      circleColor = const Color(0xFF4CAF50);
      textColor = Colors.grey[700]!;
    } else if (isActive) {
      circleColor = const Color(0xFF2196F3);
      textColor = const Color(0xFF2196F3);
    } else {
      circleColor = Colors.grey[300]!;
      textColor = Colors.grey[400]!;
    }

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? circleColor : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: circleColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive || isCompleted ? Colors.white : circleColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

/* =========================================================
   COMMON UI HELPERS (Reusable)
   ========================================================= */

Widget buildSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    ],
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
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      key: ValueKey('$label-${initialValue ?? ""}'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3), size: 22),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      initialValue: initialValue,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: (value) {
        if (!requiredField) return null;
        if (value == null || value.isEmpty) return 'Please enter $label';
        return null;
      },
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
  // Ensure value is null if empty or not in items
  final validValue =
      (value != null && value.isNotEmpty && items.contains(value))
      ? value
      : null;

  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label-${validValue ?? "empty"}'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3), size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      value: validValue,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: (v) {
        if (!requiredField) return null;
        if (v == null || v.isEmpty) return 'Please select $label';
        return null;
      },
    ),
  );
}

Widget buildModernDatePicker({
  required BuildContext context,
  required String label,
  required String hint,
  required IconData icon,
  required Function(DateTime?) onDateSelected,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String displayFormat = 'dd MMM yyyy',
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF2196F3),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
          Get.find<CarInspectionStepperController>().touch();
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF2196F3), size: 22),
          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Text(
          initialDate != null
              ? DateFormat(displayFormat).format(initialDate)
              : hint,
          style: TextStyle(
            color: initialDate != null ? Colors.black87 : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}

Widget buildConditionSelector({
  required String label,
  required String value,
  required List<String> options,
  required void Function(String) onChanged,
}) {
  final c = Get.find<CarInspectionStepperController>();

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final selected = value == opt;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  onChanged(opt);
                  c.touch();
                },
                child: Container(
                  margin: EdgeInsets.only(right: opt == options.last ? 0 : 8),
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF2196F3)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2196F3)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

Widget buildCommentField({
  required String label,
  required String hint,
  required Function(String) onChanged,
  String? initialValue,
  int maxLines = 3,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      key: ValueKey('$label-${initialValue ?? ""}'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.comment, color: Color(0xFF2196F3)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      initialValue: initialValue,
      maxLines: maxLines,
      onChanged: onChanged,
    ),
  );
}

// ✅ NEW: Image Picker Widget with Horizontal Scroll
Widget buildImagePicker({
  required String label,
  required List<String> imagePaths,
  required Function(List<String>) onImagesChanged,
  int maxImages = 10,
}) {
  final c = Get.find<CarInspectionStepperController>();

  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image, color: Color(0xFF2196F3), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              '${imagePaths.length}/$maxImages',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagePaths.length + 1,
            itemBuilder: (context, index) {
              // Add button
              if (index == imagePaths.length) {
                if (imagePaths.length >= maxImages) return const SizedBox();

                return GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFiles = await picker.pickMultiImage();

                    if (pickedFiles.isNotEmpty) {
                      final newPaths = pickedFiles.map((f) => f.path).toList();
                      final remainingSlots = maxImages - imagePaths.length;
                      final pathsToAdd = newPaths.take(remainingSlots).toList();

                      onImagesChanged([...imagePaths, ...pathsToAdd]);
                      c.touch();
                    }
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2196F3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate,
                          color: Color(0xFF2196F3),
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Image preview
              return Stack(
                children: [
                  Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      image: DecorationImage(
                        image: FileImage(File(imagePaths[index])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 16,
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
        ),
      ],
    ),
  );
}

/* =========================================================
   STEP 1: REGISTRATION & DOCUMENTS
   ========================================================= */
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader('Registration Details', Icons.description),
          const SizedBox(height: 20),

          buildModernTextField(
            label: 'Registration Number',
            hint: 'e.g., DL 01 AB 1234',
            icon: Icons.format_list_numbered,
            initialValue: carModel.registrationNumber,
            onChanged: (v) => carModel.registrationNumber = v,
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
                    FocusScope.of(context).unfocus();
                    await c.fetchRcAdvancedAndFill();
                  },
                  child: const Text('Fetch'),
                ),
              );
            }),
          ),

          buildModernDatePicker(
            context: context,
            label: 'Registration Date',
            hint: 'Select registration date',
            icon: Icons.date_range,
            onDateSelected: (date) => carModel.registrationDate = date,
            initialDate: carModel.registrationDate,
          ),

          buildModernTextField(
            label: 'Registered Owner',
            hint: 'Enter owner name',
            icon: Icons.person,
            onChanged: (v) => carModel.registeredOwner = v,
            initialValue: carModel.registeredOwner,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('RC Book Details', Icons.book),
          const SizedBox(height: 20),

          buildModernDropdown(
            context: context,
            label: 'RC Book Availability',
            hint: 'Select availability',
            icon: Icons.check_circle,
            items: const ['Available', 'Not Available', 'Applied', 'Lost'],
            onChanged: (v) {
              carModel.rcBookAvailability = v ?? '';
              c.touch();
            },
            value: carModel.rcBookAvailability,
          ),

          buildModernDropdown(
            context: context,
            label: 'RC Condition',
            hint: 'Select condition',
            icon: Icons.assessment,
            items: const ['Good', 'Damaged', 'Torn', 'Faded'],
            onChanged: (v) {
              carModel.rcCondition = v ?? '';
              c.touch();
            },
            value: carModel.rcCondition,
          ),

          buildModernDatePicker(
            context: context,
            label: 'Fitness Valid Till',
            hint: 'Select fitness expiry date',
            icon: Icons.event_available,
            onDateSelected: (date) => carModel.fitnessTill = date,
            initialDate: carModel.fitnessTill,
          ),

          // ✅ RC & Tax Token Images
          buildImagePicker(
            label: 'RC & Tax Token Images',
            imagePaths: carModel.rcTaxToken,
            onImagesChanged: (paths) => carModel.rcTaxToken = paths,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Insurance Details', Icons.security),
          const SizedBox(height: 20),

          buildModernDropdown(
            context: context,
            label: 'Insurance',
            hint: 'Select insurance status',
            icon: Icons.policy,
            items: const ['Valid', 'Expired', 'Not Available'],
            onChanged: (v) {
              carModel.insurance = v ?? '';
              c.touch();
            },
            value: carModel.insurance,
          ),

          buildModernTextField(
            label: 'Insurance Policy Number',
            hint: 'Enter policy number',
            icon: Icons.numbers,
            onChanged: (v) => carModel.insurancePolicyNumber = v,
            initialValue: carModel.insurancePolicyNumber,
          ),

          buildModernDatePicker(
            context: context,
            label: 'Insurance Validity',
            hint: 'Select insurance expiry date',
            icon: Icons.event_note,
            onDateSelected: (date) => carModel.insuranceValidity = date,
            initialDate: carModel.insuranceValidity,
          ),

          buildModernDropdown(
            context: context,
            label: 'No Claim Bonus',
            hint: 'Select NCB status',
            icon: Icons.attach_money,
            items: const ['Available', 'Not Available', 'Transferred'],
            onChanged: (v) {
              carModel.noClaimBonus = v ?? '';
              c.touch();
            },
            value: carModel.noClaimBonus,
          ),

          // ✅ Insurance Copy Images
          buildImagePicker(
            label: 'Insurance Copy Images',
            imagePaths: carModel.insuranceCopy,
            onImagesChanged: (paths) => carModel.insuranceCopy = paths,
          ),

          // ✅ Both Keys Images
          buildImagePicker(
            label: 'Both Keys Images',
            imagePaths: carModel.bothKeys,
            onImagesChanged: (paths) => carModel.bothKeys = paths,
          ),

          // ✅ Form 26 (if RC is lost)
          buildImagePicker(
            label: 'Form 26 / GD Copy (if RC is lost)',
            imagePaths: carModel.form26GdCopyIfRcIsLost,
            onImagesChanged: (paths) => carModel.form26GdCopyIfRcIsLost = paths,
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   STEP 2: BASIC INFO
   ========================================================= */
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
    final c = Get.find<CarInspectionStepperController>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader('Vehicle Details', Icons.directions_car),
          const SizedBox(height: 20),

          buildModernTextField(
            label: 'Make',
            hint: 'e.g., Toyota, Honda, BMW',
            icon: Icons.business,
            onChanged: (v) => carModel.make = v,
            initialValue: carModel.make,
          ),
          buildModernTextField(
            label: 'Model',
            hint: 'e.g., Camry, Civic, X5',
            icon: Icons.car_rental,
            onChanged: (v) => carModel.model = v,
            initialValue: carModel.model,
          ),
          buildModernTextField(
            label: 'Variant',
            hint: 'e.g., VXi, SV, M Sport',
            icon: Icons.category,
            onChanged: (v) => carModel.variant = v,
            initialValue: carModel.variant,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Engine & Chassis', Icons.settings),
          const SizedBox(height: 20),

          buildModernTextField(
            label: 'Engine Number',
            hint: 'Enter engine number',
            icon: Icons.engineering,
            onChanged: (v) => carModel.engineNumber = v,
            initialValue: carModel.engineNumber,
          ),
          buildModernTextField(
            label: 'Chassis Number',
            hint: 'Enter chassis number',
            icon: Icons.numbers,
            onChanged: (v) => carModel.chassisNumber = v,
            initialValue: carModel.chassisNumber,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Specifications', Icons.info_outline),
          const SizedBox(height: 20),

          buildModernDropdown(
            context: context,
            label: 'Fuel Type',
            hint: 'Select fuel type',
            icon: Icons.local_gas_station,
            items: const ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'],
            onChanged: (v) {
              carModel.fuelType = v ?? '';
              c.touch();
            },
            value: carModel.fuelType,
          ),

          buildModernTextField(
            label: 'Cubic Capacity (cc)',
            hint: 'e.g., 1500, 2000',
            icon: Icons.speed,
            keyboardType: TextInputType.number,
            onChanged: (v) => carModel.cubicCapacity = int.tryParse(v) ?? 0,
            initialValue: carModel.cubicCapacity > 0
                ? carModel.cubicCapacity.toString()
                : '',
          ),

          buildModernDatePicker(
            context: context,
            label: 'Year/Month of Manufacture',
            hint: 'Select manufacturing date',
            icon: Icons.calendar_today,
            onDateSelected: (date) => carModel.yearMonthOfManufacture = date,
            initialDate: carModel.yearMonthOfManufacture,
            displayFormat: 'MMM yyyy',
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   STEP 3: EXTERIOR FRONT & SIDES
   ========================================================= */
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader('Front Exterior', Icons.car_repair),
          const SizedBox(height: 20),

          // ✅ Front Main Images
          buildImagePicker(
            label: 'Front Main View Images',
            imagePaths: carModel.frontMain,
            onImagesChanged: (paths) => carModel.frontMain = paths,
          ),

          buildConditionSelector(
            label: 'Bonnet',
            value: carModel.bonnet,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.bonnet = v,
          ),
          buildImagePicker(
            label: 'Bonnet Images',
            imagePaths: carModel.bonnetImages,
            onImagesChanged: (paths) => carModel.bonnetImages = paths,
          ),

          buildConditionSelector(
            label: 'Front Windshield',
            value: carModel.frontWindshield,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.frontWindshield = v,
          ),
          buildImagePicker(
            label: 'Front Windshield Images',
            imagePaths: carModel.frontWindshieldImages,
            onImagesChanged: (paths) => carModel.frontWindshieldImages = paths,
          ),

          buildConditionSelector(
            label: 'Front Bumper',
            value: carModel.frontBumper,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.frontBumper = v,
          ),
          buildImagePicker(
            label: 'Front Bumper Images',
            imagePaths: carModel.frontBumperImages,
            onImagesChanged: (paths) => carModel.frontBumperImages = paths,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Left Side', Icons.directions_car_filled),
          const SizedBox(height: 20),

          // ✅ LHS 45 Degree
          buildImagePicker(
            label: 'LHS Front 45° Images',
            imagePaths: carModel.lhsFront45Degree,
            onImagesChanged: (paths) => carModel.lhsFront45Degree = paths,
          ),

          buildConditionSelector(
            label: 'LHS Headlamp',
            value: carModel.lhsHeadlamp,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.lhsHeadlamp = v,
          ),
          buildImagePicker(
            label: 'LHS Headlamp Images',
            imagePaths: carModel.lhsHeadlampImages,
            onImagesChanged: (paths) => carModel.lhsHeadlampImages = paths,
          ),

          buildConditionSelector(
            label: 'LHS Foglamp',
            value: carModel.lhsFoglamp,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.lhsFoglamp = v,
          ),
          buildImagePicker(
            label: 'LHS Foglamp Images',
            imagePaths: carModel.lhsFoglampImages,
            onImagesChanged: (paths) => carModel.lhsFoglampImages = paths,
          ),

          buildConditionSelector(
            label: 'LHS Fender',
            value: carModel.lhsFender,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.lhsFender = v,
          ),
          buildImagePicker(
            label: 'LHS Fender Images',
            imagePaths: carModel.lhsFenderImages,
            onImagesChanged: (paths) => carModel.lhsFenderImages = paths,
          ),

          buildConditionSelector(
            label: 'LHS Front Door',
            value: carModel.lhsFrontDoor,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.lhsFrontDoor = v,
          ),
          buildImagePicker(
            label: 'LHS Front Door Images',
            imagePaths: carModel.lhsFrontDoorImages,
            onImagesChanged: (paths) => carModel.lhsFrontDoorImages = paths,
          ),

          buildConditionSelector(
            label: 'LHS Front Tyre',
            value: carModel.lhsFrontTyre,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.lhsFrontTyre = v,
          ),
          buildImagePicker(
            label: 'LHS Front Tyre Images',
            imagePaths: carModel.lhsFrontTyreImages,
            onImagesChanged: (paths) => carModel.lhsFrontTyreImages = paths,
          ),

          buildImagePicker(
            label: 'LHS Front Alloy Images',
            imagePaths: carModel.lhsFrontAlloyImages,
            onImagesChanged: (paths) => carModel.lhsFrontAlloyImages = paths,
          ),

          buildImagePicker(
            label: 'LHS ORVM Images',
            imagePaths: carModel.lhsOrvmImages,
            onImagesChanged: (paths) => carModel.lhsOrvmImages = paths,
          ),

          buildImagePicker(
            label: 'LHS A-Pillar Images',
            imagePaths: carModel.lhsAPillarImages,
            onImagesChanged: (paths) => carModel.lhsAPillarImages = paths,
          ),

          buildImagePicker(
            label: 'LHS B-Pillar Images',
            imagePaths: carModel.lhsBPillarImages,
            onImagesChanged: (paths) => carModel.lhsBPillarImages = paths,
          ),

          buildImagePicker(
            label: 'LHS Running Border Images',
            imagePaths: carModel.lhsRunningBorderImages,
            onImagesChanged: (paths) => carModel.lhsRunningBorderImages = paths,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Right Side', Icons.directions_car_filled),
          const SizedBox(height: 20),

          buildConditionSelector(
            label: 'RHS Headlamp',
            value: carModel.rhsHeadlamp,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rhsHeadlamp = v,
          ),
          buildImagePicker(
            label: 'RHS Headlamp Images',
            imagePaths: carModel.rhsHeadlampImages,
            onImagesChanged: (paths) => carModel.rhsHeadlampImages = paths,
          ),

          buildConditionSelector(
            label: 'RHS Foglamp',
            value: carModel.rhsFoglamp,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rhsFoglamp = v,
          ),
          buildImagePicker(
            label: 'RHS Foglamp Images',
            imagePaths: carModel.rhsFoglampImages,
            onImagesChanged: (paths) => carModel.rhsFoglampImages = paths,
          ),

          buildConditionSelector(
            label: 'RHS Fender',
            value: carModel.rhsFender,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rhsFender = v,
          ),
          buildImagePicker(
            label: 'RHS Fender Images',
            imagePaths: carModel.rhsFenderImages,
            onImagesChanged: (paths) => carModel.rhsFenderImages = paths,
          ),

          buildConditionSelector(
            label: 'RHS Front Door',
            value: carModel.rhsFrontDoor,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rhsFrontDoor = v,
          ),
          buildImagePicker(
            label: 'RHS Front Door Images',
            imagePaths: carModel.rhsFrontDoorImages,
            onImagesChanged: (paths) => carModel.rhsFrontDoorImages = paths,
          ),

          buildConditionSelector(
            label: 'RHS Front Tyre',
            value: carModel.rhsFrontTyre,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rhsFrontTyre = v,
          ),
          buildImagePicker(
            label: 'RHS Front Tyre Images',
            imagePaths: carModel.rhsFrontTyreImages,
            onImagesChanged: (paths) => carModel.rhsFrontTyreImages = paths,
          ),

          buildImagePicker(
            label: 'RHS Front Alloy Images',
            imagePaths: carModel.rhsFrontAlloyImages,
            onImagesChanged: (paths) => carModel.rhsFrontAlloyImages = paths,
          ),

          buildImagePicker(
            label: 'RHS ORVM Images',
            imagePaths: carModel.rhsOrvmImages,
            onImagesChanged: (paths) => carModel.rhsOrvmImages = paths,
          ),

          buildImagePicker(
            label: 'RHS A-Pillar Images',
            imagePaths: carModel.rhsAPillarImages,
            onImagesChanged: (paths) => carModel.rhsAPillarImages = paths,
          ),

          buildImagePicker(
            label: 'RHS B-Pillar Images',
            imagePaths: carModel.rhsBPillarImages,
            onImagesChanged: (paths) => carModel.rhsBPillarImages = paths,
          ),

          buildImagePicker(
            label: 'RHS Running Border Images',
            imagePaths: carModel.rhsRunningBorderImages,
            onImagesChanged: (paths) => carModel.rhsRunningBorderImages = paths,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('General Comments', Icons.comment),
          const SizedBox(height: 20),

          buildCommentField(
            label: 'Exterior Comments',
            hint: 'Add any additional comments about exterior condition',
            onChanged: (v) => carModel.comments = v,
            initialValue: carModel.comments,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   STEP 4: EXTERIOR REAR
   ========================================================= */
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
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader('Rear Exterior', Icons.car_repair),
          const SizedBox(height: 20),

          // ✅ Rear Main Images
          buildImagePicker(
            label: 'Rear Main View Images',
            imagePaths: carModel.rearMain,
            onImagesChanged: (paths) => carModel.rearMain = paths,
          ),

          buildConditionSelector(
            label: 'Rear Bumper',
            value: carModel.rearBumper,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rearBumper = v,
          ),
          buildImagePicker(
            label: 'Rear Bumper Images',
            imagePaths: carModel.rearBumperImages,
            onImagesChanged: (paths) => carModel.rearBumperImages = paths,
          ),

          buildConditionSelector(
            label: 'Rear Windshield',
            value: carModel.rearWindshield,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rearWindshield = v,
          ),
          buildImagePicker(
            label: 'Rear Windshield Images',
            imagePaths: carModel.rearWindshieldImages,
            onImagesChanged: (paths) => carModel.rearWindshieldImages = paths,
          ),

          buildConditionSelector(
            label: 'Boot Door',
            value: carModel.bootDoor,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.bootDoor = v,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Lights & Indicators', Icons.lightbulb),
          const SizedBox(height: 20),

          buildConditionSelector(
            label: 'LHS Tail Lamp',
            value: carModel.lhsTailLamp,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.lhsTailLamp = v,
          ),
          buildImagePicker(
            label: 'LHS Tail Lamp Images',
            imagePaths: carModel.lhsTailLampImages,
            onImagesChanged: (paths) => carModel.lhsTailLampImages = paths,
          ),

          buildConditionSelector(
            label: 'RHS Tail Lamp',
            value: carModel.rhsTailLamp,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rhsTailLamp = v,
          ),
          buildImagePicker(
            label: 'RHS Tail Lamp Images',
            imagePaths: carModel.rhsTailLampImages,
            onImagesChanged: (paths) => carModel.rhsTailLampImages = paths,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Boot Area', Icons.inventory),
          const SizedBox(height: 20),

          buildConditionSelector(
            label: 'Spare Tyre',
            value: carModel.spareTyre,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.spareTyre = v,
          ),
          buildImagePicker(
            label: 'Spare Tyre Images',
            imagePaths: carModel.spareTyreImages,
            onImagesChanged: (paths) => carModel.spareTyreImages = paths,
          ),

          buildConditionSelector(
            label: 'Boot Floor',
            value: carModel.bootFloor,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.bootFloor = v,
          ),
          buildImagePicker(
            label: 'Boot Floor Images',
            imagePaths: carModel.bootFloorImages,
            onImagesChanged: (paths) => carModel.bootFloorImages = paths,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Left Rear Side', Icons.directions_car_filled),
          const SizedBox(height: 20),

          buildConditionSelector(
            label: 'LHS Rear Alloy',
            value: carModel.lhsRearAlloy,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.lhsRearAlloy = v,
          ),
          buildImagePicker(
            label: 'LHS Rear Alloy Images',
            imagePaths: carModel.lhsRearAlloyImages,
            onImagesChanged: (paths) => carModel.lhsRearAlloyImages = paths,
          ),

          buildConditionSelector(
            label: 'LHS Rear Tyre',
            value: carModel.lhsRearTyre,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.lhsRearTyre = v,
          ),
          buildImagePicker(
            label: 'LHS Rear Tyre Images',
            imagePaths: carModel.lhsRearTyreImages,
            onImagesChanged: (paths) => carModel.lhsRearTyreImages = paths,
          ),

          buildImagePicker(
            label: 'LHS Rear Door Images',
            imagePaths: carModel.lhsRearDoorImages,
            onImagesChanged: (paths) => carModel.lhsRearDoorImages = paths,
          ),

          buildImagePicker(
            label: 'LHS C-Pillar Images',
            imagePaths: carModel.lhsCPillarImages,
            onImagesChanged: (paths) => carModel.lhsCPillarImages = paths,
          ),

          buildImagePicker(
            label: 'LHS Quarter Panel Images',
            imagePaths: carModel.lhsQuarterPanelImages,
            onImagesChanged: (paths) => carModel.lhsQuarterPanelImages = paths,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Right Rear Side', Icons.directions_car_filled),
          const SizedBox(height: 20),

          // ✅ RHS Rear 45 Degree
          buildImagePicker(
            label: 'RHS Rear 45° Images',
            imagePaths: carModel.rhsRear45Degree,
            onImagesChanged: (paths) => carModel.rhsRear45Degree = paths,
          ),

          buildConditionSelector(
            label: 'RHS Rear Alloy',
            value: carModel.rhsRearAlloy,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rhsRearAlloy = v,
          ),
          buildImagePicker(
            label: 'RHS Rear Alloy Images',
            imagePaths: carModel.rhsRearAlloyImages,
            onImagesChanged: (paths) => carModel.rhsRearAlloyImages = paths,
          ),

          buildConditionSelector(
            label: 'RHS Rear Tyre',
            value: carModel.rhsRearTyre,
            options: const ['Good', 'Minor', 'Major', 'Broken'],
            onChanged: (v) => carModel.rhsRearTyre = v,
          ),
          buildImagePicker(
            label: 'RHS Rear Tyre Images',
            imagePaths: carModel.rhsRearTyreImages,
            onImagesChanged: (paths) => carModel.rhsRearTyreImages = paths,
          ),

          buildImagePicker(
            label: 'RHS Rear Door Images',
            imagePaths: carModel.rhsRearDoorImages,
            onImagesChanged: (paths) => carModel.rhsRearDoorImages = paths,
          ),

          buildImagePicker(
            label: 'RHS C-Pillar Images',
            imagePaths: carModel.rhsCPillarImages,
            onImagesChanged: (paths) => carModel.rhsCPillarImages = paths,
          ),

          buildImagePicker(
            label: 'RHS Quarter Panel Images',
            imagePaths: carModel.rhsQuarterPanelImages,
            onImagesChanged: (paths) => carModel.rhsQuarterPanelImages = paths,
          ),

          buildImagePicker(
            label: 'Roof Images',
            imagePaths: carModel.roofImages,
            onImagesChanged: (paths) => carModel.roofImages = paths,
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   STEP 5: ENGINE & MECHANICAL
   ========================================================= */
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
    final c = Get.find<CarInspectionStepperController>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader('Engine Condition', Icons.engineering),
          const SizedBox(height: 20),

          // ✅ Engine Bay Images
          buildImagePicker(
            label: 'Engine Bay Images',
            imagePaths: carModel.engineBay,
            onImagesChanged: (paths) => carModel.engineBay = paths,
          ),

          buildConditionSelector(
            label: 'Engine',
            value: carModel.engine,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.engine = v,
          ),

          buildConditionSelector(
            label: 'Battery',
            value: carModel.battery,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.battery = v,
          ),
          buildImagePicker(
            label: 'Battery Images',
            imagePaths: carModel.batteryImages,
            onImagesChanged: (paths) => carModel.batteryImages = paths,
          ),

          buildConditionSelector(
            label: 'Coolant',
            value: carModel.coolant,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.coolant = v,
          ),

          buildConditionSelector(
            label: 'Engine Oil',
            value: carModel.engineOil,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.engineOil = v,
          ),

          buildImagePicker(
            label: 'Apron LHS/RHS Images',
            imagePaths: carModel.apronLhsRhs,
            onImagesChanged: (paths) => carModel.apronLhsRhs = paths,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Transmission', Icons.settings),
          const SizedBox(height: 20),

          buildConditionSelector(
            label: 'Clutch',
            value: carModel.clutch,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.clutch = v,
          ),

          buildConditionSelector(
            label: 'Gear Shift',
            value: carModel.gearShift,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.gearShift = v,
          ),

          buildConditionSelector(
            label: 'Exhaust Smoke',
            value: carModel.exhaustSmoke,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.exhaustSmoke = v,
          ),
          buildImagePicker(
            label: 'Exhaust Smoke Images',
            imagePaths: carModel.exhaustSmokeImages,
            onImagesChanged: (paths) => carModel.exhaustSmokeImages = paths,
          ),

          buildImagePicker(
            label: 'Engine Sound (Video/Audio)',
            imagePaths: carModel.engineSound,
            onImagesChanged: (paths) => carModel.engineSound = paths,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Suspension & Steering', Icons.directions_car),
          const SizedBox(height: 20),

          buildConditionSelector(
            label: 'Steering',
            value: carModel.steering,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.steering = v,
          ),

          buildConditionSelector(
            label: 'Brakes',
            value: carModel.brakes,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.brakes = v,
          ),

          buildConditionSelector(
            label: 'Suspension',
            value: carModel.suspension,
            options: const ['Good', 'Fair', 'Poor', 'Faulty'],
            onChanged: (v) => carModel.suspension = v,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Additional Details', Icons.add_circle),
          const SizedBox(height: 20),

          buildModernTextField(
            label: 'Odometer Reading (kms)',
            hint: 'Enter current odometer reading',
            icon: Icons.speed,
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                carModel.odometerReadingInKms = int.tryParse(v) ?? 0,
            initialValue: carModel.odometerReadingInKms > 0
                ? carModel.odometerReadingInKms.toString()
                : '',
          ),

          buildModernDropdown(
            context: context,
            label: 'Fuel Level',
            hint: 'Select fuel level',
            icon: Icons.local_gas_station,
            items: const ['Full', '3/4', '1/2', '1/4', 'Empty'],
            onChanged: (v) {
              carModel.fuelLevel = v ?? '';
              c.touch();
            },
            value: carModel.fuelLevel,
          ),

          buildImagePicker(
            label: 'Additional Engine Images',
            imagePaths: carModel.additionalImages,
            onImagesChanged: (paths) => carModel.additionalImages = paths,
          ),

          buildCommentField(
            label: 'Comments on Engine',
            hint: 'Add comments about engine condition',
            onChanged: (v) => carModel.commentsOnEngine = v,
            initialValue: carModel.commentsOnEngine,
          ),

          buildCommentField(
            label: 'Comments on Transmission',
            hint: 'Add comments about transmission',
            onChanged: (v) => carModel.commentsOnTransmission = v,
            initialValue: carModel.commentsOnTransmission,
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   STEP 6: INTERIOR & ELECTRONICS
   ========================================================= */
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader('Interior Condition', Icons.event_seat),
          const SizedBox(height: 20),

          buildImagePicker(
            label: 'Front Seats (Driver Side Door Open)',
            imagePaths: carModel.frontSeatsFromDriverSideDoorOpen,
            onImagesChanged: (paths) =>
                carModel.frontSeatsFromDriverSideDoorOpen = paths,
          ),

          buildImagePicker(
            label: 'Rear Seats (Right Side Door Open)',
            imagePaths: carModel.rearSeatsFromRightSideDoorOpen,
            onImagesChanged: (paths) =>
                carModel.rearSeatsFromRightSideDoorOpen = paths,
          ),

          buildImagePicker(
            label: 'Dashboard from Rear Seat',
            imagePaths: carModel.dashboardFromRearSeat,
            onImagesChanged: (paths) => carModel.dashboardFromRearSeat = paths,
          ),

          buildConditionSelector(
            label: 'Leather Seats',
            value: carModel.leatherSeats,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.leatherSeats = v,
          ),

          buildConditionSelector(
            label: 'Fabric Seats',
            value: carModel.fabricSeats,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.fabricSeats = v,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Electronics', Icons.electrical_services),
          const SizedBox(height: 20),

          buildImagePicker(
            label: 'Meter Console (Engine On)',
            imagePaths: carModel.meterConsoleWithEngineOn,
            onImagesChanged: (paths) =>
                carModel.meterConsoleWithEngineOn = paths,
          ),

          buildConditionSelector(
            label: 'Music System',
            value: carModel.musicSystem,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.musicSystem = v,
          ),

          buildConditionSelector(
            label: 'Stereo',
            value: carModel.stereo,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.stereo = v,
          ),

          buildConditionSelector(
            label: 'Power Windows',
            value: carModel.noOfPowerWindows,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.noOfPowerWindows = v,
          ),

          buildConditionSelector(
            label: 'ABS',
            value: carModel.abs,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.abs = v,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Air Conditioning', Icons.ac_unit),
          const SizedBox(height: 20),

          buildConditionSelector(
            label: 'AC Manual',
            value: carModel.airConditioningManual,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.airConditioningManual = v,
          ),

          buildConditionSelector(
            label: 'AC Climate Control',
            value: carModel.airConditioningClimateControl,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.airConditioningClimateControl = v,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Safety Features', Icons.safety_check),
          const SizedBox(height: 20),

          buildModernTextField(
            label: 'Number of Airbags',
            hint: 'Enter number of airbags',
            icon: Icons.airline_seat_recline_extra,
            keyboardType: TextInputType.number,
            onChanged: (v) => carModel.noOfAirBags = int.tryParse(v) ?? 0,
            initialValue: carModel.noOfAirBags > 0
                ? carModel.noOfAirBags.toString()
                : '',
          ),

          buildImagePicker(
            label: 'Airbag Images',
            imagePaths: carModel.airbags,
            onImagesChanged: (paths) => carModel.airbags = paths,
          ),

          buildConditionSelector(
            label: 'Reverse Camera',
            value: carModel.reverseCamera,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.reverseCamera = v,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Additional Features', Icons.add),
          const SizedBox(height: 20),

          buildConditionSelector(
            label: 'Sunroof',
            value: carModel.sunroof,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.sunroof = v,
          ),
          buildImagePicker(
            label: 'Sunroof Images',
            imagePaths: carModel.sunroofImages,
            onImagesChanged: (paths) => carModel.sunroofImages = paths,
          ),

          buildConditionSelector(
            label: 'Rear Wiper/Washer',
            value: carModel.rearWiperWasher,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.rearWiperWasher = v,
          ),

          buildConditionSelector(
            label: 'Rear Defogger',
            value: carModel.rearDefogger,
            options: const ['Good', 'Fair', 'Poor', 'Not Working'],
            onChanged: (v) => carModel.rearDefogger = v,
          ),

          buildImagePicker(
            label: 'Additional Interior Images',
            imagePaths: carModel.additionalImages2,
            onImagesChanged: (paths) => carModel.additionalImages2 = paths,
          ),

          buildCommentField(
            label: 'Comments on Electricals',
            hint: 'Add comments about electrical systems',
            onChanged: (v) => carModel.commentsOnElectricals = v,
            initialValue: carModel.commentsOnElectricals,
          ),

          buildCommentField(
            label: 'Comments on AC',
            hint: 'Add comments about air conditioning',
            onChanged: (v) => carModel.commentsOnAc = v,
            initialValue: carModel.commentsOnAc,
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   STEP 7: FINAL DETAILS
   ========================================================= */
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
    final c = Get.find<CarInspectionStepperController>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader('Contact Information', Icons.contact_page),
          const SizedBox(height: 20),

          buildModernTextField(
            label: 'Contact Number',
            hint: 'Enter contact number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            onChanged: (v) => carModel.contactNumber = v,
            initialValue: carModel.contactNumber,
          ),
          buildModernTextField(
            label: 'Email Address',
            hint: 'Enter email address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => carModel.emailAddress = v,
            initialValue: carModel.emailAddress,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Inspection Details', Icons.assessment),
          const SizedBox(height: 20),

          buildModernTextField(
            label: 'City',
            hint: 'Enter city name',
            icon: Icons.location_city,
            onChanged: (v) => carModel.city = v,
            initialValue: carModel.city,
          ),
          buildModernTextField(
            label: 'Appointment ID',
            hint: 'Enter appointment ID',
            icon: Icons.confirmation_number,
            onChanged: (v) => carModel.appointmentId = v,
            initialValue: carModel.appointmentId,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Pricing & Status', Icons.monetization_on),
          const SizedBox(height: 20),

          buildModernTextField(
            label: 'Price Discovery',
            hint: 'Enter estimated price',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            onChanged: (v) => carModel.priceDiscovery = int.tryParse(v) ?? 0,
            initialValue: carModel.priceDiscovery > 0
                ? carModel.priceDiscovery.toString()
                : '',
          ),
          buildModernTextField(
            label: 'Price Discovery By',
            hint: 'Enter appraiser name',
            icon: Icons.person,
            onChanged: (v) => carModel.priceDiscoveryBy = v,
            initialValue: carModel.priceDiscoveryBy,
          ),

          buildModernDropdown(
            context: context,
            label: 'Status',
            hint: 'Select inspection status',
            icon: Icons.stairs,
            items: const [
              'Pending',
              'In Progress',
              'Completed',
              'Approved',
              'Rejected',
            ],
            onChanged: (v) {
              carModel.status = v ?? '';
              c.touch();
            },
            value: carModel.status,
          ),

          const SizedBox(height: 32),
          buildSectionHeader('Additional Information', Icons.note_add),
          const SizedBox(height: 20),

          buildCommentField(
            label: 'Additional Details',
            hint: 'Add any additional information or notes',
            onChanged: (v) => carModel.additionalDetails = v,
            initialValue: carModel.additionalDetails,
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   STEP 8: REVIEW
   ========================================================= */
class ReviewStep extends StatelessWidget {
  final CarModel carModel;

  const ReviewStep({super.key, required this.carModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Review & Submit', Icons.check_circle),
        const SizedBox(height: 20),

        _ReviewCard(
          icon: Icons.directions_car,
          title: 'Vehicle Details',
          items: [
            'Make: ${carModel.make.isNotEmpty ? carModel.make : "Not provided"}',
            'Model: ${carModel.model.isNotEmpty ? carModel.model : "Not provided"}',
            'Variant: ${carModel.variant.isNotEmpty ? carModel.variant : "Not provided"}',
            'Fuel Type: ${carModel.fuelType.isNotEmpty ? carModel.fuelType : "Not provided"}',
          ],
        ),

        const SizedBox(height: 16),
        _ReviewCard(
          icon: Icons.description,
          title: 'Registration Details',
          items: [
            'Registration No: ${carModel.registrationNumber.isNotEmpty ? carModel.registrationNumber : "Not provided"}',
            'RC Status: ${carModel.rcBookAvailability.isNotEmpty ? carModel.rcBookAvailability : "Not provided"}',
            'Insurance: ${carModel.insurance.isNotEmpty ? carModel.insurance : "Not provided"}',
          ],
        ),

        const SizedBox(height: 16),
        _ReviewCard(
          icon: Icons.image,
          title: 'Images Summary',
          items: [
            'RC & Tax Token: ${carModel.rcTaxToken.length} images',
            'Insurance Copy: ${carModel.insuranceCopy.length} images',
            'Exterior Images: ${carModel.frontMain.length + carModel.bonnetImages.length + carModel.rearMain.length} images',
            'Interior Images: ${carModel.frontSeatsFromDriverSideDoorOpen.length + carModel.dashboardFromRearSeat.length} images',
            'Engine Bay: ${carModel.engineBay.length} images',
            'Total Images: ${_getTotalImagesCount(carModel)} images',
          ],
        ),

        const SizedBox(height: 16),
        _ReviewCard(
          icon: Icons.car_repair,
          title: 'Exterior Condition',
          items: [
            'Bonnet: ${carModel.bonnet.isNotEmpty ? carModel.bonnet : "Not assessed"}',
            'Front Bumper: ${carModel.frontBumper.isNotEmpty ? carModel.frontBumper : "Not assessed"}',
            'Rear Bumper: ${carModel.rearBumper.isNotEmpty ? carModel.rearBumper : "Not assessed"}',
          ],
        ),

        const SizedBox(height: 16),
        _ReviewCard(
          icon: Icons.engineering,
          title: 'Engine & Mechanical',
          items: [
            'Engine: ${carModel.engine.isNotEmpty ? carModel.engine : "Not assessed"}',
            'Odometer: ${carModel.odometerReadingInKms > 0 ? "${carModel.odometerReadingInKms} kms" : "Not recorded"}',
            'Brakes: ${carModel.brakes.isNotEmpty ? carModel.brakes : "Not assessed"}',
          ],
        ),

        const SizedBox(height: 16),
        _ReviewCard(
          icon: Icons.event_seat,
          title: 'Interior & Electronics',
          items: [
            'AC: ${carModel.airConditioningManual.isNotEmpty ? carModel.airConditioningManual : "Not assessed"}',
            'Music System: ${carModel.musicSystem.isNotEmpty ? carModel.musicSystem : "Not assessed"}',
            'Airbags: ${carModel.noOfAirBags > 0 ? carModel.noOfAirBags.toString() : "Not specified"}',
          ],
        ),

        const SizedBox(height: 16),
        _ReviewCard(
          icon: Icons.assessment,
          title: 'Final Details',
          items: [
            'Contact: ${carModel.contactNumber.isNotEmpty ? carModel.contactNumber : "Not provided"}',
            'City: ${carModel.city.isNotEmpty ? carModel.city : "Not provided"}',
            'Status: ${carModel.status.isNotEmpty ? carModel.status : "Not set"}',
          ],
        ),

        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Color(0xFF2196F3)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please review all information carefully before submitting. Once submitted, the inspection will be sent for approval.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _getTotalImagesCount(CarModel model) {
    return model.rcTaxToken.length +
        model.insuranceCopy.length +
        model.bothKeys.length +
        model.form26GdCopyIfRcIsLost.length +
        model.frontMain.length +
        model.bonnetImages.length +
        model.frontWindshieldImages.length +
        model.roofImages.length +
        model.frontBumperImages.length +
        model.lhsHeadlampImages.length +
        model.lhsFoglampImages.length +
        model.rhsHeadlampImages.length +
        model.rhsFoglampImages.length +
        model.lhsFront45Degree.length +
        model.lhsFenderImages.length +
        model.lhsFrontAlloyImages.length +
        model.lhsFrontTyreImages.length +
        model.lhsRunningBorderImages.length +
        model.lhsOrvmImages.length +
        model.lhsAPillarImages.length +
        model.lhsFrontDoorImages.length +
        model.lhsBPillarImages.length +
        model.lhsRearDoorImages.length +
        model.lhsCPillarImages.length +
        model.lhsRearTyreImages.length +
        model.lhsRearAlloyImages.length +
        model.lhsQuarterPanelImages.length +
        model.rearMain.length +
        model.rearBumperImages.length +
        model.lhsTailLampImages.length +
        model.rhsTailLampImages.length +
        model.rearWindshieldImages.length +
        model.spareTyreImages.length +
        model.bootFloorImages.length +
        model.rhsRear45Degree.length +
        model.rhsQuarterPanelImages.length +
        model.rhsRearAlloyImages.length +
        model.rhsRearTyreImages.length +
        model.rhsCPillarImages.length +
        model.rhsRearDoorImages.length +
        model.rhsBPillarImages.length +
        model.rhsFrontDoorImages.length +
        model.rhsAPillarImages.length +
        model.rhsRunningBorderImages.length +
        model.rhsFrontAlloyImages.length +
        model.rhsFrontTyreImages.length +
        model.rhsOrvmImages.length +
        model.rhsFenderImages.length +
        model.engineBay.length +
        model.apronLhsRhs.length +
        model.batteryImages.length +
        model.additionalImages.length +
        model.engineSound.length +
        model.exhaustSmokeImages.length +
        model.meterConsoleWithEngineOn.length +
        model.airbags.length +
        model.sunroofImages.length +
        model.frontSeatsFromDriverSideDoorOpen.length +
        model.rearSeatsFromRightSideDoorOpen.length +
        model.dashboardFromRearSeat.length +
        model.additionalImages2.length;
  }
}

class _ReviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2196F3), size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
