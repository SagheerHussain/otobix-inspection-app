import 'package:flutter/material.dart';
import 'package:otobix_inspection_app/widgets/app_theme.dart';

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
        ? AppColor.stepDone
        : (isActive ? kPrimary : Colors.grey.shade300);

    final Color textColor = isActive ? AppColor.textDark : Colors.grey.shade600;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: (isActive || isCompleted) ? circleColor : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2.2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: circleColor.withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            color: (isActive || isCompleted) ? Colors.white : circleColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 92,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
