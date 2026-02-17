import 'package:flutter/material.dart';
import '../../../features/agencia/users/domain/entities/turista.dart';

class PassengerDetailModal extends StatelessWidget {
  final Turista turista;
  final String estadoViaje; // 'PROGRAMADO', 'EN_CURSO', 'FINALIZADO'

  const PassengerDetailModal({
    super.key,
    required this.turista,
    required this.estadoViaje,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 16,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // HEADER
            _buildHeader(context),
            const Divider(height: 1),

            // BODY (Adaptativo según estado del viaje)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildAdaptiveBody(),
              ),
            ),

            const Divider(height: 1),

            // FOOTER (Acciones adaptativas)
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF0F4C75),
            child: Text(
              turista.nombre[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  turista.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F4C75),
                  ),
                ),
                Text(
                  'ID: ${turista.id} • ${_getStatusLabel()}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel() {
    if (estadoViaje == 'PROGRAMADO') {
      return turista.appInstalada ? 'Confirmado' : 'Pendiente';
    } else if (estadoViaje == 'FINALIZADO') {
      return turista.asistio == true ? 'Asistió' : 'No Show';
    } else {
      return turista.status;
    }
  }

  Widget _buildAdaptiveBody() {
    if (estadoViaje == 'EN_CURSO') {
      return _buildLiveMonitorView();
    } else if (estadoViaje == 'PROGRAMADO') {
      return _buildLogisticsView();
    } else {
      return _buildHistoryView();
    }
  }

  // --- VISTA 1: LOGÍSTICA (PROGRAMADO) ---
  Widget _buildLogisticsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preparación del Turista',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),

        // Estatus de la App
        _infoRow(
          Icons.mobile_friendly,
          'Estatus App',
          turista.appInstalada
              ? 'Instalada y Vinculada ✅'
              : 'Pendiente de instalación ⚠️',
          isWarning: !turista.appInstalada,
        ),
        const SizedBox(height: 12),

        // Datos Médicos
        _infoRow(
          Icons.bloodtype,
          'Tipo de Sangre',
          turista.tipoSangre ?? 'No especificado',
        ),
        const SizedBox(height: 12),
        _infoRow(
          Icons.medical_services,
          'Alergias',
          turista.alergias ?? 'Ninguna',
          isWarning: turista.alergias != null && turista.alergias != 'Ninguna',
        ),
        const SizedBox(height: 12),
        _infoRow(
          Icons.health_and_safety,
          'Condiciones Médicas',
          turista.condicionesMedicas ?? 'Ninguna',
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Contacto de Emergencia
        const Text(
          'Contacto de Emergencia',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                turista.contactoEmergenciaNombre ?? 'No especificado',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Parentesco: ${turista.contactoEmergenciaParentesco ?? 'N/A'}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    turista.contactoEmergenciaTelefono ?? 'No especificado',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Estatus Administrativo
        const Text(
          'Estatus Administrativo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _checklistItem('Pago completado', turista.pagoCompletado),
        _checklistItem('Responsiva firmada', turista.responsivaFirmada),
        _checklistItem('App instalada', turista.appInstalada),

        // Advertencia si falta algo
        if (!turista.responsivaFirmada || !turista.pagoCompletado) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: const [
                Icon(Icons.warning_amber, color: Colors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Faltan requisitos administrativos por completar.',
                    style: TextStyle(color: Colors.brown),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- VISTA 2: HISTORIAL (FINALIZADO) ---
  Widget _buildHistoryView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen del Viaje',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _statCard(
                'Incidentes',
                '${turista.incidentesCount ?? 0}',
                (turista.incidentesCount ?? 0) == 0
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Asistencia',
                turista.asistio == true ? '✅ Sí' : '❌ No',
                turista.asistio == true ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),

        if (turista.calificacion != null) ...[
          const SizedBox(height: 16),
          _statCard(
            'Calificación del Viaje',
            '${turista.calificacion!.toStringAsFixed(1)} / 5.0',
            Colors.blue,
          ),
        ],

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        const Text(
          'Notas del Guía:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            turista.notasGuia ?? 'Sin notas registradas.',
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // --- VISTA 3: MONITOR EN VIVO (EN_CURSO) ---
  Widget _buildLiveMonitorView() {
    return Column(
      children: [
        const Text(
          'Monitoreo en Tiempo Real',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _liveMetric(
              Icons.battery_std,
              '${(turista.bateria * 100).toInt()}%',
              'Batería',
              turista.bateria < 0.2 ? Colors.red : Colors.green,
            ),
            _liveMetric(
              Icons.signal_cellular_alt,
              turista.status == 'OFFLINE' ? 'Sin señal' : '4G',
              'Señal',
              turista.status == 'OFFLINE' ? Colors.grey : Colors.green,
            ),
            _liveMetric(
              Icons.location_on,
              turista.enCampo ? 'En Campo' : 'Fuera',
              'Ubicación',
              turista.enCampo ? Colors.green : Colors.grey,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Estado crítico si aplica
        if (turista.status == 'SOS') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Row(
              children: const [
                Icon(Icons.warning, color: Colors.red, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡ALERTA SOS ACTIVA!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'El turista ha activado el botón de pánico.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Placeholder para mapa o gráficas
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Mapa de ubicación en tiempo real',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _getActionButtons(context),
      ),
    );
  }

  List<Widget> _getActionButtons(BuildContext context) {
    if (estadoViaje == 'PROGRAMADO') {
      return [
        TextButton(onPressed: () {}, child: const Text('Editar Datos')),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send, size: 16),
          label: const Text('Reenviar Acceso App'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F4C75),
          ),
        ),
      ];
    } else if (estadoViaje == 'FINALIZADO') {
      return [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.history, size: 16),
          label: const Text('Ver Logs Completos'),
        ),
      ];
    } else {
      // EN_CURSO
      return [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.message, size: 16),
            label: const Text('Mensaje'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Llamar SOS'),
            style: FilledButton.styleFrom(
              backgroundColor:
                  turista.status == 'SOS'
                      ? Colors.red
                      : const Color(0xFF0F4C75),
            ),
          ),
        ),
      ];
    }
  }

  // --- WIDGETS AUXILIARES ---

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool isWarning = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isWarning ? Colors.orange : Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isWarning ? Colors.orange.shade800 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _checklistItem(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.cancel,
            color: completed ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: completed ? Colors.black87 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _liveMetric(IconData icon, String val, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          val,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
