import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- MODELOS DE DATOS ---
class Persona {
  final String id;
  final String nombre;
  Persona({required this.id, required this.nombre});

  // ✨ Convertir a JSON
  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre};
  
  // ✨ Leer desde JSON
  factory Persona.fromJson(Map<String, dynamic> json) => Persona(id: json['id'], nombre: json['nombre']);
}

class Gasto {
  final String id;
  final String concepto;
  final double montoTotal;
  final Persona quienPago;
  
  Gasto({required this.id, required this.concepto, required this.montoTotal, required this.quienPago});

  // ✨ Convertir a JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'concepto': concepto,
    'montoTotal': montoTotal,
    'quienPago': quienPago.toJson(),
  };

  // ✨ Leer desde JSON
  factory Gasto.fromJson(Map<String, dynamic> json) => Gasto(
    id: json['id'],
    concepto: json['concepto'],
    montoTotal: json['montoTotal'],
    quienPago: Persona.fromJson(json['quienPago']),
  );
}

class Deuda {
  final Persona deudor;
  final Persona acreedor;
  final double monto;
  Deuda({required this.deudor, required this.acreedor, required this.monto});
}

// --- PANTALLA PRINCIPAL ---
class DivisorGastosScreen extends StatefulWidget {
  const DivisorGastosScreen({super.key});

  @override
  State<DivisorGastosScreen> createState() => _DivisorGastosScreenState();
}

class _DivisorGastosScreenState extends State<DivisorGastosScreen> {
  // 1. Dejamos solo a "Tú" como valor por defecto. Los demás se cargarán de la memoria.
  List<Persona> _grupo = [
    Persona(id: '1', nombre: 'Tú'),
  ];
  
  List<Gasto> _gastos = [];
  List<Deuda> _saldosCalculados = [];

  // Controladores para el formulario de nuevo gasto
  final TextEditingController _conceptoController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _nuevaPersonaController = TextEditingController(); // ✨ Nuevo controlador
  Persona? _personaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarHistorial(); 
  }

  // --- ✨ NUEVO: MAGIA DE MEMORIA LOCAL ---

  // Leer del disco duro
  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar Grupo (Amigos)
    final String? grupoJson = prefs.getString('historial_grupo');
    if (grupoJson != null) {
      final List<dynamic> grupoDecodificado = jsonDecode(grupoJson);
      _grupo = grupoDecodificado.map((item) => Persona.fromJson(item)).toList();
    }

    // Cargar Gastos
    final String? gastosJson = prefs.getString('historial_gastos');
    if (gastosJson != null) {
      final List<dynamic> listaDecodificada = jsonDecode(gastosJson);
      _gastos = listaDecodificada.map((item) => Gasto.fromJson(item)).toList();
    }

    setState(() {
      _personaSeleccionada = _grupo.isNotEmpty ? _grupo.first : null;
    });
    _calcularSaldos(); 
  }

  // Guardar en el disco duro
  Future<void> _guardarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    // Guardar Gastos
    final String gastosCodificados = jsonEncode(_gastos.map((g) => g.toJson()).toList());
    await prefs.setString('historial_gastos', gastosCodificados);
    
    // ✨ Guardar Grupo
    final String grupoCodificado = jsonEncode(_grupo.map((p) => p.toJson()).toList());
    await prefs.setString('historial_grupo', grupoCodificado);
  }

  // Borrar todo (Ideal para cuando termina el viaje)
  Future<void> _limpiarCuentas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('historial_gastos');
    await prefs.remove('historial_grupo'); // ✨ También borramos el grupo al reiniciar
    setState(() {
      _gastos.clear();
      _saldosCalculados.clear();
      _grupo = [Persona(id: '1', nombre: 'Tú')]; // Volvemos al estado base
      _personaSeleccionada = _grupo.first;
    });
  }

  // 2. EL ALGORITMO MÁGICO (Quién le debe a quién)
  void _calcularSaldos() {
    if (_grupo.isEmpty || _gastos.isEmpty) {
      setState(() => _saldosCalculados = []);
      return;
    }

    // A. Calcular cuánto pagó cada quien y cuánto debió haber pagado
    Map<String, double> balances = {};
    for (var persona in _grupo) {
      balances[persona.id] = 0.0; // Inicializamos en 0
    }

    for (var gasto in _gastos) {
      double parteIgual = gasto.montoTotal / _grupo.length; // División equitativa
      
      for (var persona in _grupo) {
        if (persona.id == gasto.quienPago.id) {
          // Si pagó, le sumamos lo que puso menos su parte
          balances[persona.id] = balances[persona.id]! + (gasto.montoTotal - parteIgual);
        } else {
          // Si no pagó, se le resta su parte
          balances[persona.id] = balances[persona.id]! - parteIgual;
        }
      }
    }

    // B. Emparejar a los que deben con los que les deben
    List<Deuda> nuevasDeudas = [];
    List<MapEntry<String, double>> deudores = balances.entries.where((e) => e.value < -0.01).toList();
    List<MapEntry<String, double>> acreedores = balances.entries.where((e) => e.value > 0.01).toList();

    int i = 0, j = 0;
    while (i < deudores.length && j < acreedores.length) {
      double montoDeuda = deudores[i].value.abs();
      double montoAcredor = acreedores[j].value;

      double pago = montoDeuda < montoAcredor ? montoDeuda : montoAcredor;

      Persona pDeudor = _grupo.firstWhere((p) => p.id == deudores[i].key);
      Persona pAcreedor = _grupo.firstWhere((p) => p.id == acreedores[j].key);

      nuevasDeudas.add(Deuda(deudor: pDeudor, acreedor: pAcreedor, monto: pago));

      // Actualizar los saldos restantes
      deudores[i] = MapEntry(deudores[i].key, deudores[i].value + pago);
      acreedores[j] = MapEntry(acreedores[j].key, acreedores[j].value - pago);

      if (deudores[i].value.abs() < 0.01) i++;
      if (acreedores[j].value < 0.01) j++;
    }

    setState(() {
      _saldosCalculados = nuevasDeudas;
    });
  }

  // --- ✨ NUEVA FUNCIÓN: AÑADIR PERSONA ---
  void _mostrarDialogoNuevaPersona() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Viajero'),
          content: TextField(
            controller: _nuevaPersonaController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre del amigo(a)',
              hintText: 'Ej. Carlos, Ana...',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nuevaPersonaController.text.isNotEmpty) {
                  final nuevaPersona = Persona(
                    id: DateTime.now().toString(), // Generamos un ID único rápido
                    nombre: _nuevaPersonaController.text.trim(),
                  );
                  
                  setState(() {
                    _grupo.add(nuevaPersona);
                  });
                  
                  _guardarHistorial(); // Guardamos el nuevo amigo en memoria
                  _nuevaPersonaController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  // 3. Diálogo para añadir un gasto
  void _mostrarDialogoNuevoGasto() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Añadir Gasto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _conceptoController,
                    decoration: const InputDecoration(labelText: 'Concepto (Ej. Cena, Taxi)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _montoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Monto Total', prefixText: '\$'),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Persona>(
                    initialValue: _personaSeleccionada,
                    decoration: const InputDecoration(labelText: '¿Quién pagó?'),
                    items: _grupo.map((p) => DropdownMenuItem(value: p, child: Text(p.nombre))).toList(),
                    onChanged: (val) {
                      setDialogState(() => _personaSeleccionada = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_conceptoController.text.isNotEmpty && _montoController.text.isNotEmpty) {
                      final nuevoGasto = Gasto(
                        id: DateTime.now().toString(),
                        concepto: _conceptoController.text,
                        montoTotal: double.parse(_montoController.text),
                        quienPago: _personaSeleccionada!,
                      );
                      setState(() {
                        _gastos.insert(0, nuevoGasto);
                        _calcularSaldos();
                      });
                      
                      _guardarHistorial(); // ✨ GUARDA AUTOMÁTICAMENTE EN MEMORIA
                      
                      _conceptoController.clear();
                      _montoController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cuentas Claras'),
          actions: [
            // ✨ Botón para añadir un nuevo amigo
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: 'Añadir Viajero',
              onPressed: _mostrarDialogoNuevaPersona,
            ),
            // ✨ Botón para limpiar todas las cuentas
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Reiniciar Cuentas',
              onPressed: () {
                // Pequeña confirmación antes de borrar todo
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Reiniciar viaje?'),
                    content: const Text('Esto borrará todos los gastos y amigos actuales. ¿Estás seguro?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () {
                          _limpiarCuentas();
                          Navigator.pop(ctx);
                        }, 
                        child: const Text('Sí, borrar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: 'Gastos'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Saldos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- PESTAÑA 1: LISTA DE GASTOS ---
            _gastos.isEmpty
                ? const Center(child: Text('No hay gastos registrados aún.\n¡Añade el primero!', textAlign: TextAlign.center))
                : ListView.builder(
                    itemCount: _gastos.length,
                    itemBuilder: (context, index) {
                      final gasto = _gastos[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: const Icon(Icons.receipt, color: Colors.orange),
                        ),
                        title: Text(gasto.concepto, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Pagó: ${gasto.quienPago.nombre}'),
                        trailing: Text('\$${gasto.montoTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      );
                    },
                  ),

            // --- PESTAÑA 2: SALDOS (QUIÉN DEBE A QUIÉN) ---
            _saldosCalculados.isEmpty
                ? const Center(child: Text('Todos están a mano. ¡Genial!'))
                : ListView.builder(
                    itemCount: _saldosCalculados.length,
                    itemBuilder: (context, index) {
                      final deuda = _saldosCalculados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(deuda.deudor.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                                  const Text('le debe a', style: TextStyle(color: Colors.grey)),
                                  Text(deuda.acreedor.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                                ],
                              ),
                              Text(
                                '\$${deuda.monto.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _mostrarDialogoNuevoGasto,
          icon: const Icon(Icons.add),
          label: const Text('Gasto'),
          backgroundColor: Colors.orange,
        ),
      ),
    );
  }
}
