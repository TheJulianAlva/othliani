import 'package:flutter/material.dart';

class KPICard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String subtitle;
  final bool isAlert;
  final VoidCallback? onTap;

  const KPICard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.subtitle,
    this.isAlert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Alert Styles
    final backgroundColor = isAlert ? const Color(0xFFFFEBEE) : Colors.white;
    final iconColor =
        isAlert ? const Color(0xFFC62828) : const Color(0xFF0F4C75);
    final valueColor = isAlert ? const Color(0xFFC62828) : Colors.black87;
    final titleColor = isAlert ? const Color(0xFFC62828) : Colors.grey.shade700;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor:
              isAlert
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
          hoverColor:
              isAlert
                  ? Colors.red.withValues(alpha: 0.05)
                  : Colors.blue.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color:
                        isAlert
                            ? const Color(0xFFE53935)
                            : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
