import 'package:flutter/material.dart';

class KPICard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String subtitle;
  final bool isAlert;
  final VoidCallback? onTap;
  
  // Nuevas propiedades para diseño
  final Color? customIconColor;
  final Color? customIconBgColor;

  const KPICard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.subtitle,
    this.isAlert = false,
    this.onTap,
    this.customIconColor,
    this.customIconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    // Alert Styles
    final backgroundColor = isAlert ? const Color(0xFFFFEBEE) : Colors.white;
    
    // Icon colors logic
    final iconColor = isAlert 
        ? const Color(0xFFC62828) 
        : (customIconColor ?? const Color(0xFF1B3B6F)); // Default VELTUR blue
        
    final iconBgColor = isAlert
        ? const Color(0xFFFFCDD2)
        : (customIconBgColor ?? const Color(0xFFE8EEFF));

    final valueColor = isAlert ? const Color(0xFFC62828) : Colors.black87;
    final titleColor = isAlert ? const Color(0xFFC62828) : Colors.grey.shade600;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: iconBgColor.withValues(alpha: 0.3),
          hoverColor: iconBgColor.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono con fondo redondeado
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          color: valueColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isAlert ? const Color(0xFFE53935) : Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
