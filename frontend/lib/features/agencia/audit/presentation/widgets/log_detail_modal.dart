import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../../features/agencia/audit/domain/entities/log_auditoria.dart';

class LogDetailModal extends StatelessWidget {
  final LogAuditoria log;

  const LogDetailModal({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final color = _getColorByNivel(log.nivel);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            Row(
              children: [
                Icon(Icons.terminal, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detalle del Evento",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        log.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    log.nivel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // 2. DATOS PRINCIPALES
            _buildInfoRow("Actor", log.actor),
            const SizedBox(height: 8),
            _buildInfoRow("Acción", log.accion),
            const SizedBox(height: 8),
            _buildInfoRow("IP / Origen", log.ip),
            const SizedBox(height: 8),
            _buildInfoRow(
              "Fecha Hora",
              "${log.fecha.day.toString().padLeft(2, '0')}/${log.fecha.month.toString().padLeft(2, '0')}/${log.fecha.year} ${log.fecha.hour.toString().padLeft(2, '0')}:${log.fecha.minute.toString().padLeft(2, '0')}",
            ),

            // 3. METADATA TÉCNICA (JSON DUMP)
            if (log.metadata != null) ...[
              const SizedBox(height: 24),
              const Text(
                "METADATA TÉCNICA",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _prettyPrintJson(log.metadata!),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            // 4. ACCIONES INTELIGENTES
            if (log.relatedRoute != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: color),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text("Investigar Contexto (Ir al Viaje)"),
                  onPressed: () {
                    Navigator.pop(context); // Cerrar modal primero
                    context.go(log.relatedRoute!); // Navegar
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  Color _getColorByNivel(String nivel) {
    if (nivel == 'CRITICO') return Colors.red;
    if (nivel == 'ADVERTENCIA') return Colors.amber[800]!;
    return Colors.blue;
  }

  String _prettyPrintJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }
}
