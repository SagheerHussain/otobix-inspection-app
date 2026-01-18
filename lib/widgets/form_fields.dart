import 'package:flutter/material.dart';
import 'package:otobix_inspection_app/widgets/app_theme.dart';

Widget _prefixIconPill(IconData icon, {bool enabled = true}) {
  return Container(
    margin: const EdgeInsets.only(left: 10, right: 8),
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: enabled ? const Color(0xFFF1F5F9) : const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColor.border),
    ),
    child: Icon(icon, color: AppColor.fieldIcon, size: 20),
  );
}

InputDecoration _fieldDecoration({
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffix,
  String? errorText,
  bool enabled = true,
  bool readOnly = false,
}) {
  final fill = (readOnly || !enabled)
      ? const Color(0xFFF1F5F9)
      : AppColor.fieldFill;

  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: errorText,
    prefixIcon: _prefixIconPill(icon, enabled: enabled),
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    suffixIcon: suffix,
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColor.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColor.fieldFocusBorder, width: 2),
    ),
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
  bool readOnly = false,
  bool enabled = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      key: ValueKey('$label-${initialValue ?? ""}'),
      initialValue: initialValue,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enabled: enabled,
      onChanged: (v) {
        if (!enabled || readOnly) return;
        onChanged(v);
      },
      validator: (v) {
        if (!requiredField) return null;
        if (v == null || v.trim().isEmpty) return 'Please enter $label';
        return null;
      },
      cursorColor: AppColor.fieldIcon,
      decoration: _fieldDecoration(
        label: label,
        hint: hint,
        icon: icon,
        suffix: suffix,
        enabled: enabled,
        readOnly: readOnly,
      ),
    ),
  );
}

// CSV helpers
List<String> _parseCsvList(String raw) {
  final r = raw.trim();
  if (r.isEmpty) return [];
  return r.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

String _joinCsvList(List<String> items) {
  if (items.isEmpty) return '';
  return items.join(', ');
}

// Date helpers
String _fmtDate(DateTime? d) {
  if (d == null) return '';
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd/$mm/$yyyy';
}

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
  bool enabled = true,
}) {
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
          onTap: !enabled
              ? null
              : () async {
                  FocusScope.of(context).unfocus();
                  final now = DateTime.now();

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: value ?? now,
                    firstDate: firstDate ?? DateTime(1990),
                    lastDate: lastDate ?? DateTime(now.year + 30),
                    helpText: label,
                    builder: (ctx, child) {
                      final base = Theme.of(ctx);
                      return Theme(
                        data: base.copyWith(
                          colorScheme: base.colorScheme.copyWith(
                            primary: kPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    onChanged(picked);
                    state.didChange(picked);
                  }
                },
          child: InputDecorator(
            decoration: _fieldDecoration(
              label: label,
              hint: hint,
              icon: icon,
              enabled: enabled,
              errorText: state.hasError ? state.errorText : null,
              suffix: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: enabled ? AppColor.fieldIcon : Colors.grey.shade400,
                ),
              ),
            ),
            child: Text(
              display,
              style: TextStyle(
                color: value == null ? AppColor.textMuted : AppColor.textDark,
                fontWeight: value == null ? FontWeight.w600 : FontWeight.w900,
              ),
            ),
          ),
        ),
      );
    },
  );
}

// expose for other files
InputDecoration fieldDecorationPublic({
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffix,
  String? errorText,
  bool enabled = true,
  bool readOnly = false,
}) {
  return _fieldDecoration(
    label: label,
    hint: hint,
    icon: icon,
    suffix: suffix,
    errorText: errorText,
    enabled: enabled,
    readOnly: readOnly,
  );
}

// expose csv helpers for dropdown builders
List<String> parseCsvListPublic(String raw) => _parseCsvList(raw);
String joinCsvListPublic(List<String> items) => _joinCsvList(items);
