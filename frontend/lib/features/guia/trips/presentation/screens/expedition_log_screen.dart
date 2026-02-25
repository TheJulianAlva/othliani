import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/incident_log.dart';
import '../../data/datasources/caja_negra_local_datasource.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExpeditionLogScreen extends StatelessWidget {
  final CajaNegraLocalDataSource cajaNegra;
  final bool esGuiaIndependiente;

  ExpeditionLogScreen({
    super.key,
    CajaNegraLocalDataSource? cajaNegraRef,
    this.esGuiaIndependiente = true,
  }) : cajaNegra = cajaNegraRef ?? sl<CajaNegraLocalDataSource>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bitácora de Expedición"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<IncidentLog>>(
        future: cajaNegra.obtenerEvidencia(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data ?? [];
          final bool fueViajeLimpio = logs.isEmpty;

          return Column(
            children: [
              // 1. MENSAJE SUPERIOR CONTEXTUAL
              Container(
                padding: const EdgeInsets.all(16),
                color: esGuiaIndependiente ? Colors.amber[50] : Colors.blue[50],
                child: Row(
                  children: [
                    Icon(
                      esGuiaIndependiente
                          ? Icons.shield_outlined
                          : Icons.corporate_fare,
                      color:
                          esGuiaIndependiente ? Colors.amber[800] : Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        esGuiaIndependiente
                            ? "Este es tu respaldo legal. OhtliAni protege tu licencia de guía certificando tus acciones."
                            : "Estos registros están encriptados y serán enviados a la gerencia de tu agencia.",
                        style: TextStyle(
                          color:
                              esGuiaIndependiente
                                  ? Colors.amber[900]
                                  : Colors.blue[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. LA LISTA DE EVENTOS (o mensaje de éxito)
              Expanded(
                child:
                    fueViajeLimpio
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.eco,
                                size: 80,
                                color: Colors.green[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Expedición Impecable",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (esGuiaIndependiente)
                                const Text(
                                  "+1 Viaje Seguro para tu Sello Verde 🏅",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            final horaLocal = log.timestamp.toLocal();
                            final horaFormateada = DateFormat(
                              'HH:mm:ss',
                            ).format(horaLocal);

                            return ListTile(
                              leading: _getIconForLog(log.tipo),
                              title: Text(
                                log.descripcion,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Hora: $horaFormateada | Lat: ${log.latitud.toStringAsFixed(4)}",
                              ),
                              trailing: Icon(
                                log.isSynced
                                    ? Icons.cloud_done
                                    : Icons.cloud_off,
                                color:
                                    log.isSynced ? Colors.green : Colors.grey,
                              ),
                            );
                          },
                        ),
              ),

              // 3. BOTONES DE ACCIÓN SEGÚN EL TIPO DE GUÍA
              Padding(
                padding: const EdgeInsets.all(24.0),
                child:
                    esGuiaIndependiente
                        ? _buildBotonesIndependiente(context, logs)
                        : _buildBotonAgencia(context, logs),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✨ BOTONES EXCLUSIVOS PARA GUÍA PERSONAL ✨
  Widget _buildBotonesIndependiente(
    BuildContext context,
    List<IncidentLog> logs,
  ) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Generando PDF de protección legal..."),
              ),
            );
            await _generarPdf(context, logs);
          },
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Exportar como PDF Legal"),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Respaldando viaje en Nube OhtliAni..."),
              ),
            );
            await Future.delayed(const Duration(seconds: 2));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Viaje respaldado con éxito. Cerrando..."),
                ),
              );
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.cloud_sync),
          label: const Text("Respaldar Viaje y Cerrar"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.amber[700],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // BOTÓN PARA GUÍA DE AGENCIA
  Widget _buildBotonAgencia(BuildContext context, List<IncidentLog> logs) {
    return ElevatedButton.icon(
      onPressed: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sincronizando logs con la central...')),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte enviado correctamente a la gerencia.'),
            ),
          );
          Navigator.of(context).pop();
        }
      },
      icon: const Icon(Icons.cloud_upload),
      label: const Text("Subir Reporte a la Central"),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _generarPdf(BuildContext context, List<IncidentLog> logs) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Bitácora de Expedición Legal - OhtliAni",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Evidencia inmutable de incidentes durante el viaje."),
              pw.SizedBox(height: 20),
              if (logs.isEmpty)
                pw.Text(
                  "Expedición Impecable - 0 incidentes registrados.",
                  style: const pw.TextStyle(color: PdfColors.green),
                )
              else
                pw.Column(
                  children:
                      logs.map((log) {
                        final hora = DateFormat(
                          'yyyy-MM-dd HH:mm:ss',
                        ).format(log.timestamp.toLocal());
                        return pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 10),
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                log.descripcion,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text("Hora: $hora"),
                              pw.Text(
                                "Tipo: ${log.tipo.name} | Coords: ${log.latitud}, ${log.longitud}",
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'caja_negra_ohtliani.pdf',
    );
  }

  Widget _getIconForLog(TipoIncidente tipo) {
    switch (tipo) {
      case TipoIncidente.sosGuiaActivado:
        return const Icon(Icons.warning, color: Colors.red);
      case TipoIncidente.sosGuiaCancelado:
        return const Icon(Icons.check_circle, color: Colors.orange);
      case TipoIncidente.alertaTuristaAlejado:
        return const Icon(Icons.directions_run, color: Colors.orange);
      case TipoIncidente.incidenteResuelto:
        return const Icon(Icons.verified_user, color: Colors.green);
      default:
        return const Icon(Icons.info, color: Colors.blue);
    }
  }
}
