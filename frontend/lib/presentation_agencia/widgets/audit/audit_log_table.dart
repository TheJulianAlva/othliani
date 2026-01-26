import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuditLogTable extends StatefulWidget {
  const AuditLogTable({super.key});

  @override
  State<AuditLogTable> createState() => _AuditLogTableState();
}

class _AuditLogTableState extends State<AuditLogTable> {
  // Mock Data
  final List<AuditEntry> _entries = [
    AuditEntry(
      timestamp: '2026-01-25 10:42:15',
      level: 'CRT',
      actor: 'Sys_Algorithm',
      actionTitle: 'Detectado Alejamiento',
      actionDetail: '> Turista: Ana Gómez',
      ip: 'Servidor Interno',
      jsonMetadata: '''{
  "alert_id": "ALT-9921",
  "distance": "120m",
  "threshold": "50m",
  "coordinates": {
    "lat": 19.108,
    "lng": -99.759
  }
}''',
    ),
    AuditEntry(
      timestamp: '2026-01-25 10:40:00',
      level: 'INF',
      actor: 'Admin: Juan P.',
      actionTitle: 'Modificó Geocerca',
      actionDetail: '> Viaje #2045: 50m->20m',
      ip: '192.168.1.10',
      jsonMetadata: '''{
  "previous_value": "50m",
  "new_value": "20m",
  "reason": "Niebla reportada",
  "timestamp_server": "10:40:00.123 Z"
}''',
    ),
    AuditEntry(
      timestamp: '2026-01-25 09:15:22',
      level: 'WRN',
      actor: 'Guía: Marcos R.',
      actionTitle: 'Pérdida de Conexión',
      actionDetail: '> Duración: 120s',
      ip: '10.22.41.2',
      jsonMetadata: '''{
  "device_id": "ANDROID-X82",
  "signal_strength": "0%",
  "last_known_loc": "Checkpoint 1"
}''',
    ),
    AuditEntry(
      timestamp: '2026-01-25 08:30:10',
      level: 'INF',
      actor: 'Admin: Juan P.',
      actionTitle: 'Acceso a Datos (ARCO)',
      actionDetail: '> Perfil: Ana Gómez',
      ip: '192.168.1.10',
      jsonMetadata: '''{
  "access_type": "READ",
  "fields_accessed": [
     "medical_info",
     "emergency_contact"
  ],
  "justification": "Verificación pre-viaje"
}''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: const [
              Expanded(flex: 2, child: _HeaderCell('FECHA / HORA (UTC)')),
              Expanded(
                flex: 1,
                child: _LevelHeader(),
              ), // Custom Header with Tooltip
              Expanded(flex: 2, child: _HeaderCell('ACTOR (QUIÉN)')),
              Expanded(flex: 4, child: _HeaderCell('ACCIÓN (QUÉ HIZO)')),
              Expanded(flex: 2, child: _HeaderCell('IP / DISP')),
              SizedBox(width: 32), // Chevron space
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              return _AuditEntryRow(entry: _entries[index]);
            },
          ),
        ),

        // Footer (Pagination)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('< Pág 1 de 50 >'),
              Text('Mostrando 50 líneas v'),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.black54,
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'NIVEL',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          padding: const EdgeInsets.all(12),
          richMessage: const TextSpan(
            children: [
              TextSpan(
                text: 'Guía de Niveles de Severidad:\n\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '🔴 CRT (Crítico): ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              TextSpan(text: 'Incidentes de seguridad, fallos.\n'),
              TextSpan(
                text: '🟡 WRN (Advertencia): ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              TextSpan(text: 'Eventos anómalos (batería, logins).\n'),
              TextSpan(
                text: '🔵 INF (Informativo): ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              TextSpan(text: 'Operaciones normales.'),
            ],
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          child: Icon(
            Icons.info_outline,
            size: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _AuditEntryRow extends StatefulWidget {
  final AuditEntry entry;
  const _AuditEntryRow({required this.entry});

  @override
  State<_AuditEntryRow> createState() => _AuditEntryRowState();
}

class _AuditEntryRowState extends State<_AuditEntryRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // Determine Color based on Level
    Color levelColor = Colors.blue;
    Color levelBg = Colors.blue.shade50;

    if (widget.entry.level == 'CRT') {
      levelColor = Colors.red;
      levelBg = Colors.red.shade50;
    } else if (widget.entry.level == 'WRN') {
      levelColor = Colors.orange.shade800;
      levelBg = Colors.amber.shade50;
    } else {
      levelColor = Colors.blue.shade700;
      levelBg = Colors.blue.shade50;
    }

    final monoStyle = const TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      color: Colors.black87,
    );

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  _expanded
                      ? Colors.blue.shade50.withValues(alpha: 0.3)
                      : Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(widget.entry.timestamp, style: monoStyle),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ), // Tighter pad
                        decoration: BoxDecoration(
                          color: levelBg,
                          borderRadius: BorderRadius.circular(6), // Rounded
                        ),
                        child: Text(
                          widget.entry.level,
                          style: monoStyle.copyWith(
                            color: levelColor,
                            fontWeight: FontWeight.w700, // Bolder
                            fontSize: 11, // Smaller
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(widget.entry.actor, style: monoStyle),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.entry.actionTitle,
                        style: monoStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.entry.actionDetail,
                        style: monoStyle.copyWith(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(widget.entry.ip, style: monoStyle),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            color: const Color(0xFFFAFAFA),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'METADATOS TÉCNICOS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: widget.entry.jsonMetadata),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('JSON copiado al portapapeles'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.copy, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Copiar',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Terminal Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), // Slate 900
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectionArea(
                    child: _buildRichJson(widget.entry.jsonMetadata),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Simple Highlighting logic
  Widget _buildRichJson(String json) {
    final List<TextSpan> spans = [];
    final lines = json.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      // Simple coloring logic
      // Key: "key":
      // String value: "value"
      // Number: 123

      final parts = line.split(':');
      if (parts.length > 1) {
        // Has Key
        final keyPart = parts[0];
        final valPart = parts.sublist(1).join(':'); // Rejoin rest

        spans.add(
          TextSpan(
            text: keyPart,
            style: const TextStyle(color: Colors.cyanAccent),
          ),
        );
        spans.add(const TextSpan(text: ':'));

        if (valPart.trim().startsWith('"')) {
          // String
          spans.add(
            TextSpan(
              text: valPart,
              style: const TextStyle(color: Colors.lightGreenAccent),
            ),
          );
        } else if (valPart.trim().contains('{') ||
            valPart.trim().contains('[')) {
          // Structure punctuation
          spans.add(
            TextSpan(
              text: valPart,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        } else {
          // Number/Bool/Null
          spans.add(
            TextSpan(
              text: valPart,
              style: const TextStyle(color: Colors.orangeAccent),
            ),
          );
        }
      } else {
        // Just braces or single values
        spans.add(
          TextSpan(text: line, style: const TextStyle(color: Colors.white70)),
        );
      }
      spans.add(const TextSpan(text: '\n'));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }
}

class AuditEntry {
  final String timestamp;
  final String level;
  final String actor;
  final String actionTitle;
  final String actionDetail;
  final String ip;
  final String jsonMetadata;

  AuditEntry({
    required this.timestamp,
    required this.level,
    required this.actor,
    required this.actionTitle,
    required this.actionDetail,
    required this.ip,
    required this.jsonMetadata,
  });
}
