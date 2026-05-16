import 'package:flutter/material.dart';
import 'package:frontend/features/guia/shared/theme/guia_theme.dart';

class GuiaCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget>? actions;
  final Widget? customBottomWidget;
  final double height;
  final VoidCallback? onBackPressed;

  const GuiaCustomAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actions,
    this.customBottomWidget,
    this.height = 120.0,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      backgroundColor: GuiaColors.primary,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (onBackPressed != null) ...[
                            GestureDetector(
                              onTap: onBackPressed,
                              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Icon(icon, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            subtitle,
                            style: GuiaTextStyles.appBarSmallLabel,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions ?? [],
                      ),
                    ],
                  ),
                  // Bottom Row
                  if (customBottomWidget != null)
                    customBottomWidget!
                  else
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.apps_rounded, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: GuiaTextStyles.appBarTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
