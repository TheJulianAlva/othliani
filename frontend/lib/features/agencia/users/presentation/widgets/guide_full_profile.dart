import 'package:flutter/material.dart';
import '../../domain/entities/guia.dart';

class GuideFullProfile extends StatelessWidget {
  final Guia guia;

  const GuideFullProfile({super.key, required this.guia});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header del Perfil
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFF0F4F8),
                child: Text("CR", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(guia.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F))),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: Colors.blue, size: 20),
                      ],
                    ),
                    Text("ID: ${guia.id} • ${guia.rol} Senior • Desde 2021", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildHeaderStat("Desempeño", "4.8 ★", Colors.orange),
                        const SizedBox(width: 16),
                        _buildHeaderStat("Últimos 3 Viajes", "V-100, V-082, V-075", Colors.blueGrey),
                      ],
                    ),
                  ],
                ),
              ),
              // Medallas
              _buildBadge("Top 10% Mensual", Colors.orange.shade700, Colors.orange.shade50, Icons.emoji_events_outlined),
              const SizedBox(width: 12),
              _buildBadge("Cero Retrasos (90d)", Colors.green.shade700, Colors.green.shade50, Icons.timer_outlined),
              const SizedBox(width: 24),
              FilledButton.icon(
                icon: const Icon(Icons.message_outlined, size: 18),
                label: const Text("Contactar"),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3B6F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Grid Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna Izquierda
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildLeftCard("PERFIL OPERATIVO", [
                      _buildSectionTitle("Idiomas Dominados"),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildChip("Español (Nativo)", Colors.blue.shade700, Colors.blue.shade50),
                          _buildChip("Inglés (Avanzado)", Colors.blue.shade700, Colors.blue.shade50),
                          _buildChip("Francés (Básico)", Colors.blue.shade700, Colors.blue.shade50),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle("Especialidades"),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildChip("Ecoturismo", Colors.blueGrey, Colors.blueGrey.shade50),
                          _buildChip("Alta Montaña", Colors.blueGrey, Colors.blueGrey.shade50),
                          _buildChip("Grupos > 40 pax", Colors.blueGrey, Colors.blueGrey.shade50),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle("Certificaciones Clave"),
                      _buildCertItem("NOM-09-TUR-2002", "Exp. 12 Sep 2027", Colors.green),
                      _buildCertItem("Licencia Transporte Fed.", "Vence en 14 días", Colors.orange, isAlert: true),
                    ]),
                    const SizedBox(height: 24),
                    _buildLeftCard("RESUMEN FINANCIERO (MARZO)", [
                      Row(
                        children: [
                          Expanded(
                            child: _buildFinancialItem("Pagado este mes", "\$12,450.00", "4 Viajes liquidados", Colors.blue.shade700),
                          ),
                          Expanded(
                            child: _buildFinancialItem("Saldo Pendiente", "\$3,200.00", "1 Viaje por pagar (V-100)", Colors.orange.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Registrar Pago / Anticipo"),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Columna Derecha
              Expanded(
                flex: 6,
                child: _buildRightCard("RENDIMIENTO OPERATIVO (ÚLTIMOS 12 VIAJES)", [
                  // Simulación de gráfico de barras con múltiples barras por mes
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildMonthlyGroup("Diciembre", [0.8, 0.9, 0.7], Colors.green),
                        _buildMonthlyGroup("Enero", [0.9, 1.0, 0.85], Colors.green),
                        _buildMonthlyGroup("Febrero", [0.7, 0.8, 0.6], Colors.orange),
                        _buildMonthlyGroup("Marzo (Act.)", [0.95, 0.9, 0.0], Colors.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem("Exitoso", Colors.green),
                      _buildLegendItem("Inc. Menor", Colors.orange),
                      _buildLegendItem("Inc. Mayor", Colors.red.shade400),
                      const Spacer(),
                      const Text("Tasa de Éxito: 82%", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text("Últimas Evaluaciones Cualitativas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildReviewItem("V-100 • Grutas de Tolantongo", 5.0, "El guía Carlos mantuvo el control total del grupo. Comunicación excelente y solventó el retraso del desayuno muy bien. Sumamente recomendado para viajes VIP."),
                  _buildReviewItem("V-082 • Chignahuapan", 4.0, "El viaje estuvo bien, pero la llanta ponchada nos quitó mucho tiempo. El guía Carlos fue muy amable y nos mantuvo relajados."),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildBadge(String text, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildLeftCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_ind_outlined, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRightCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChip(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildCertItem(String name, String status, Color color, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(isAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Text(status, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, String amount, String subtitle, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(amount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMonthlyGroup(String month, List<double> values, Color color) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: values.map((v) => _buildBar(v, color)).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(month, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBar(double heightFactor, Color color) {
    if (heightFactor == 0) {
      return Container(
        width: 24,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 4,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
      );
    }
    return Container(
      width: 24,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 150 * heightFactor,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String title, double stars, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < stars ? Colors.orange : Colors.grey.shade300))),
            ],
          ),
          const SizedBox(height: 8),
          Text("\"$comment\"", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
