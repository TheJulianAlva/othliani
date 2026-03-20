import 'package:flutter/material.dart';

/// Widget de clima compartido entre el layout B2B y B2C.
/// En el mock muestra datos estáticos; en producción se conectará a una API.
class WeatherWidget extends StatelessWidget {
  final bool isCompact;

  const WeatherWidget({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.wb_sunny_rounded, color: Colors.yellowAccent, size: 14),
            SizedBox(width: 6),
            Text(
              '24°C · Soleado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono y temperatura
          const Icon(
            Icons.wb_sunny_rounded,
            color: Color(0xFFFFA000),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '24 °C · Soleado',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  'Viento: 12 km/h · Humedad: 65 %',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // Índice UV
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA000).withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'UV 7',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Color(0xFFF57C00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
