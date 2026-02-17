import 'package:flutter/material.dart';

class SubscriptionSettings extends StatelessWidget {
  const SubscriptionSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suscripción y Licencias',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Plan Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.star,
                          color: Colors.indigo.shade700,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enterprise Tier 2',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Próximo cobro: 01/Feb/2026',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Descargar Facturas'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Mejorar Plan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Licenses Usage
          const Text(
            'Licencias de Guías Activas',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('12 utilizadas'),
              Text(
                '15 disponibles',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 12 / 15,
            minHeight: 12,
            backgroundColor: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            valueColor: AlwaysStoppedAnimation<Color>(
              (12 / 15) > 0.9 ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          if ((12 / 15) > 0.8)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '¡Estás cerca del límite! Mejora tu plan para añadir más guías.',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 40),
          // Payment Method Placeholder
          const Text(
            'Método de Pago',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.credit_card, size: 30),
            title: const Text('Visa terminada en 4242'),
            subtitle: const Text('Expira 12/28'),
            trailing: TextButton(onPressed: () {}, child: const Text('Editar')),
          ),
        ],
      ),
    );
  }
}
