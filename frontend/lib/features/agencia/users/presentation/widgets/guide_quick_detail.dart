import 'package:flutter/material.dart';
import '../../domain/entities/guia.dart';

class GuideQuickDetail extends StatelessWidget {
  final Guia guia;
  final VoidCallback onVerEvaluacion;

  const GuideQuickDetail({
    super.key,
    required this.guia,
    required this.onVerEvaluacion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // --- HEADER FIJO (No se mueve) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(icon: const Icon(Icons.chat_bubble_outline, size: 20), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
                  ],
                ),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFF0F4F8),
                  child: Text(guia.nombre.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F))),
                ),
                const SizedBox(height: 16),
                Text(guia.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F))),
                Text("ID: ${guia.id} • ${guia.rol} Senior", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(radius: 4, backgroundColor: Colors.green),
                      SizedBox(width: 8),
                      Text("Listo Asignación", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // --- CUERPO SCROLLABLE ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // 1. CREDENCIALES & ALERTAS (Ahora primero)
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: Colors.blueGrey.shade700, size: 18),
                      const SizedBox(width: 8),
                      const Text("CREDENCIALES & ALERTAS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B3B6F))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Alerta Licencia (Solo si aplica)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade100)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            const Expanded(child: Text("Licencia Fed. por expirar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Vence en 14 días (22 Mar)", style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCredentialRow("Credencial Sectur (NOM-09)", "VIGENTE (2027)", Colors.green),
                  _buildCredentialRow("Primeros Auxilios (Cruz Roja)", "VIGENTE (Oct 26)", Colors.green),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // 2. DESEMPEÑO GLOBAL
                  Row(
                    children: [
                      Icon(Icons.analytics_outlined, size: 18, color: Colors.blueGrey.shade700),
                      const SizedBox(width: 8),
                      const Text("DESEMPEÑO GLOBAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1B3B6F))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard("4.6 ★", "Satisfacción (CSAT)", Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard("2.4 %", "Tasa de Incidencias", Colors.green)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // 3. ÚLTIMOS VIAJES LIDERADOS (Ahora con formato de opinión/estrellas)
                  Row(
                    children: [
                      Icon(Icons.history, size: 18, color: Colors.blueGrey.shade700),
                      const SizedBox(width: 8),
                      const Text("ÚLTIMOS VIAJES LIDERADOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1B3B6F))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTripReviewCard("V-100 (Grutas de Tolantongo)", 5.0, "Excelente guía, muy atento."),
                  _buildTripReviewCard("V-082 (Chignahuapan)", 4.0, "Puntual y conocedor."),
                  _buildTripReviewCard("V-075 (Nevado de Toluca)", 4.5, "Muy buena actitud."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripReviewCard(String title, double stars, String review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F)), overflow: TextOverflow.ellipsis)),
              Row(children: List.generate(5, (i) => Icon(Icons.star, size: 10, color: i < stars.floor() ? Colors.orange : Colors.grey.shade300))),
            ],
          ),
          const SizedBox(height: 4),
          Text("\"$review\"", style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }



  Widget _buildCredentialRow(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700))),
          Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
