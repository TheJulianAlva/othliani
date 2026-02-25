import 'package:flutter/material.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CriticalMedicalCard
//
// Tarjeta de alto contraste (Amarillo Emergencia + borde rojo) que muestra
// la ficha médica vital de un [Turista] en el momento exacto de la crisis.
//
// Se oculta automáticamente si el turista es estándar y no tiene datos médicos,
// para no estorbar en alertas de bajo riesgo.
// ─────────────────────────────────────────────────────────────────────────────

class CriticalMedicalCard extends StatelessWidget {
  final Turista turista;

  const CriticalMedicalCard({super.key, required this.turista});

  bool get _tieneInfoMedica =>
      turista.vulnerabilidad == NivelVulnerabilidad.critica ||
      (turista.tipoSangre?.isNotEmpty ?? false) ||
      (turista.alergias?.isNotEmpty ?? false) ||
      (turista.condicionesMedicas?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    // Si no hay información médica relevante → no ocupa espacio
    if (!_tieneInfoMedica) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFFD600,
        ), // Amarillo Emergencia (máxima visibilidad)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB71C1C), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ──────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.medical_information_rounded,
                color: Color(0xFFB71C1C),
                size: 28,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '¡ALERTA MÉDICA VITAL!',
                  style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Badge de prioridad crítica
              if (turista.vulnerabilidad == NivelVulnerabilidad.critica)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'P1',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(color: Color(0x40000000), thickness: 1.5, height: 20),

          // ── Tipo de sangre ───────────────────────────────────────────────
          if (turista.tipoSangre?.isNotEmpty ?? false) ...[
            _FilaMedica(
              icono: '🩸',
              etiqueta: 'Tipo de sangre',
              valor: turista.tipoSangre!,
              grande: true,
            ),
            const SizedBox(height: 10),
          ],

          // ── Alergias ─────────────────────────────────────────────────────
          if (turista.alergias?.isNotEmpty ?? false) ...[
            _FilaMedica(
              icono: '⚠️',
              etiqueta: 'Alergias',
              valor: turista.alergias!,
              grande: true,
            ),
            const SizedBox(height: 10),
          ],

          // ── Condiciones médicas ───────────────────────────────────────────
          if (turista.condicionesMedicas?.isNotEmpty ?? false) ...[
            _FilaMedica(
              icono: '💊',
              etiqueta: 'Condición médica',
              valor: turista.condicionesMedicas!,
              grande: true,
            ),
            const SizedBox(height: 10),
          ],

          // ── Contacto de emergencia ────────────────────────────────────────
          if (turista.contactoEmergenciaNombre?.isNotEmpty ?? false) ...[
            const Divider(color: Color(0x30000000), height: 16),
            _FilaMedica(
              icono: '📞',
              etiqueta:
                  turista.contactoEmergenciaParentesco ?? 'Contacto emergencia',
              valor:
                  '${turista.contactoEmergenciaNombre!}'
                  '${turista.contactoEmergenciaTelefono != null ? "  ·  ${turista.contactoEmergenciaTelefono}" : ""}',
              grande: false,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Fila de dato médico ───────────────────────────────────────────────────────

class _FilaMedica extends StatelessWidget {
  final String icono;
  final String etiqueta;
  final String valor;
  final bool grande;

  const _FilaMedica({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icono, style: TextStyle(fontSize: grande ? 22 : 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                valor,
                style: TextStyle(
                  fontSize: grande ? 17 : 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
