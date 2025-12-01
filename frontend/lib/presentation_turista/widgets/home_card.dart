import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

class HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const HomeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color ?? Theme.of(context).primaryColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.subheading,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
