import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/agencia/audit/blocs/auditoria/auditoria_bloc.dart';
import 'package:frontend/features/agencia/audit/domain/entities/log_auditoria.dart';
import '../../widgets/audit/audit_toolbar.dart';
import '../../widgets/audit/log_detail_modal.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar con filtros y exportar
          const AuditToolbar(),

          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con título y leyenda
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y descripción
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Registro de Auditoría (Logs)",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Trazabilidad completa de acciones de seguridad y sistema.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Leyenda de nomenclatura
                      _buildNomenclatureLegend(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // TABLA
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: BlocBuilder<AuditoriaBloc, AuditoriaState>(
                        builder: (context, state) {
                          if (state is AuditoriaLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is AuditoriaLoaded) {
                            if (state.logs.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No se encontraron registros con ese filtro.",
                                ),
                              );
                            }
                            return _buildLogTable(context, state.logs);
                          } else if (state is AuditoriaError) {
                            return Center(child: Text(state.message));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTable(BuildContext context, List<LogAuditoria> logs) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return _ExpandableLogRow(log: logs[index]);
      },
    );
  }

  Widget _buildNomenclatureLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                'Nomenclatura',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            color: Colors.red[800]!,
            bgColor: Colors.red[50]!,
            icon: Icons.error_outline,
            code: 'CRT',
            label: 'Crítico',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            color: Colors.amber[900]!,
            bgColor: Colors.amber[50]!,
            icon: Icons.warning_amber,
            code: 'ADV',
            label: 'Advertencia',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            color: Colors.blue[800]!,
            bgColor: Colors.blue[50]!,
            icon: Icons.info_outline,
            code: 'INF',
            label: 'Información',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color bgColor,
    required IconData icon,
    required String code,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 3),
              Text(
                code,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
      ],
    );
  }
}

// Stateful widget for expandable rows
class _ExpandableLogRow extends StatefulWidget {
  final LogAuditoria log;
  const _ExpandableLogRow({required this.log});

  @override
  State<_ExpandableLogRow> createState() => _ExpandableLogRowState();
}

class _ExpandableLogRowState extends State<_ExpandableLogRow> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Abrir modal de detalles
        showDialog(
          context: context,
          builder: (_) => LogDetailModal(log: widget.log),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                "${widget.log.fecha.hour}:${widget.log.fecha.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            const SizedBox(width: 16),
            _buildNivelBadgeInline(widget.log.nivel),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: Text(
                widget.log.actor,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.log.accion,
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: Text(
                widget.log.id,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelBadgeInline(String nivel) {
    Color bg;
    Color text;
    IconData icon;
    String shortText;

    switch (nivel) {
      case 'CRITICO':
        bg = Colors.red[50]!;
        text = Colors.red[800]!;
        icon = Icons.error_outline;
        shortText = 'CRT';
        break;
      case 'ADVERTENCIA':
        bg = Colors.amber[50]!;
        text = Colors.amber[900]!;
        icon = Icons.warning_amber;
        shortText = 'ADV';
        break;
      default: // INFO
        bg = Colors.blue[50]!;
        text = Colors.blue[800]!;
        icon = Icons.info_outline;
        shortText = 'INF';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: text.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 3),
          Text(
            shortText,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
