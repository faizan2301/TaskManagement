import 'package:flutter/material.dart';
import '../constants/app_text_style.dart';
class AppAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    this.secondaryButtonText,
    required this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: AppTextStyle.titleLarge(context)),
      content: Text(message, style: AppTextStyle.bodyMedium(context)),
      actions: [
        if (secondaryButtonText != null)
          TextButton(
            onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
            child: Text(secondaryButtonText!, style: AppTextStyle.labelLarge(context).copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
        ElevatedButton(
          onPressed: onPrimaryPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(primaryButtonText, style: AppTextStyle.labelLarge(context).copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}