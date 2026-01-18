import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_inspection_app/constants/app_colors.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final RxBool isLoading;
  final VoidCallback onTap;
  final double height;
  final double width;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final TextStyle? textStyle;
  final double loaderSize;
  final double loaderStrokeWidth;
  final Color loaderColor;
  final double fontSize;
  final double elevation;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onTap,
    this.height = 40,
    this.width = 150,
    this.borderRadius = 50,
    this.backgroundColor = AppColors.green,
    this.textColor = AppColors.white,
    this.textStyle,
    this.loaderSize = 15,
    this.loaderStrokeWidth = 1,
    this.loaderColor = AppColors.white,
    this.fontSize = 15,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading.value ? null : onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Obx(
        () => Material(
          elevation: elevation,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Center(
              child: isLoading.value
                  ? SizedBox(
                      height: loaderSize,
                      width: loaderSize,
                      child: CircularProgressIndicator(
                        color: loaderColor,
                        strokeWidth: loaderStrokeWidth,
                      ),
                    )
                  : Text(
                      text,
                      style:
                          textStyle ??
                          TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
