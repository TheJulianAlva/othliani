import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ContactoConfianza — entidad ligera (sin base de datos)
// ─────────────────────────────────────────────────────────────────────────────
class ContactoConfianza {
  final String nombre;
  final String telefono;
  final String relacion; // "Mamá", "Amigo", etc.

  const ContactoConfianza({
    required this.nombre,
    required this.telefono,
    this.relacion = '',
  });

  ContactoConfianza copyWith({
    String? nombre,
    String? telefono,
    String? relacion,
  }) => ContactoConfianza(
    nombre: nombre ?? this.nombre,
    telefono: telefono ?? this.telefono,
    relacion: relacion ?? this.relacion,
  );

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'telefono': telefono,
    'relacion': relacion,
  };

  factory ContactoConfianza.fromMap(Map<String, dynamic> m) =>
      ContactoConfianza(
        nombre: m['nombre'] as String? ?? '',
        telefono: m['telefono'] as String? ?? '',
        relacion: m['relacion'] as String? ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ContactosConfianzaWidget
//
// Uso standalone (con botón final):
//   ContactosConfianzaWidget(
//     showFinalizarButton: true,
//     onFinalizar: () => context.go(RoutesGuia.homePersonal),
//   )
//
// Uso embebido en Stepper (sin botón):
//   ContactosConfianzaWidget(
//     contactos: state.contactos,
//     onChanged: (lista) => setState(() => _contactos = lista),
//   )
// ─────────────────────────────────────────────────────────────────────────────
class ContactosConfianzaWidget extends StatefulWidget {
  /// Lista inicial de contactos (opcional; si null se usa la lista interna).
  final List<ContactoConfianza>? contactos;

  /// Callback al modificar la lista; si null el widget gestiona su propio estado.
  final void Function(List<ContactoConfianza>)? onChanged;

  /// Muestra el botón "Publicar y Activar Protección" al pie.
  final bool showFinalizarButton;

  /// Callback al pulsar el botón finalizar.
  final VoidCallback? onFinalizar;

  const ContactosConfianzaWidget({
    super.key,
    this.contactos,
    this.onChanged,
    this.showFinalizarButton = false,
    this.onFinalizar,
  });

  @override
  State<ContactosConfianzaWidget> createState() =>
      _ContactosConfianzaWidgetState();
}

class _ContactosConfianzaWidgetState extends State<ContactosConfianzaWidget> {
  // Estado interno (solo activo si no se pasa lista externa)
  late List<ContactoConfianza> _contactos;

  static const int _limiteMaximo = 3;

  @override
  void initState() {
    super.initState();
    _contactos =
        widget.contactos != null
            ? List<ContactoConfianza>.from(widget.contactos!)
            : [
              const ContactoConfianza(
                nombre: 'Mamá',
                telefono: '+52 5512345678',
                relacion: 'Familiar',
              ),
            ];
  }

  @override
  void didUpdateWidget(ContactosConfianzaWidget old) {
    super.didUpdateWidget(old);
    // Si el padre controla la lista, sincroniza al recibir cambios
    if (widget.contactos != null && widget.contactos != old.contactos) {
      _contactos = List<ContactoConfianza>.from(widget.contactos!);
    }
  }

  List<ContactoConfianza> get _lista => widget.contactos ?? _contactos;

  void _notificar(List<ContactoConfianza> nueva) {
    if (widget.onChanged != null) {
      widget.onChanged!(nueva);
    } else {
      setState(() => _contactos = nueva);
    }
  }

  // ── Diálogo de captura ────────────────────────────────────────────────────
  Future<void> _abrirDialogo({ContactoConfianza? editando}) async {
    final nombreC = TextEditingController(text: editando?.nombre ?? '');
    final telC = TextEditingController(text: editando?.telefono ?? '');
    final relacionC = TextEditingController(text: editando?.relacion ?? '');

    final resultado = await showDialog<ContactoConfianza>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  editando == null ? 'Nuevo contacto' : 'Editar contacto',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CampoDialogo(
                  controller: nombreC,
                  label: 'Nombre',
                  icono: Icons.badge_rounded,
                ),
                const SizedBox(height: 10),
                _CampoDialogo(
                  controller: telC,
                  label: 'Teléfono / WhatsApp',
                  icono: Icons.phone_rounded,
                  tipo: TextInputType.phone,
                  formato: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  ],
                ),
                const SizedBox(height: 10),
                _CampoDialogo(
                  controller: relacionC,
                  label: 'Relación (opcional)',
                  icono: Icons.favorite_border_rounded,
                  hint: 'Ej. Mamá, Amigo, Pareja',
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (nombreC.text.trim().isEmpty) return; // validación mínima
                  Navigator.pop(
                    ctx,
                    ContactoConfianza(
                      nombre: nombreC.text.trim(),
                      telefono: telC.text.trim(),
                      relacion: relacionC.text.trim(),
                    ),
                  );
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );

    if (resultado == null) return;

    final nueva = List<ContactoConfianza>.from(_lista);
    if (editando != null) {
      final idx = nueva.indexWhere(
        (c) => c.nombre == editando.nombre && c.telefono == editando.telefono,
      );
      if (idx >= 0) nueva[idx] = resultado;
    } else {
      nueva.add(resultado);
    }
    _notificar(nueva);
  }

  void _eliminar(int idx) {
    final nueva = List<ContactoConfianza>.from(_lista)..removeAt(idx);
    _notificar(nueva);
  }

  // ── Bottom sheet de confirmación ─────────────────────────────────────────
  void _mostrarConfirmacion() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 38,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Expedición Protegida!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'El viaje se guardó localmente. OhtliAni monitoreará tu seguridad '
                  'incluso sin internet y alertará a tu red de confianza si activas el SOS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop(); // cierra el sheet
                      widget.onFinalizar?.call();
                    },
                    child: const Text(
                      'IR AL DASHBOARD',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final lista = _lista;
    final puedeAgregar = lista.length < _limiteMaximo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Encabezado ──────────────────────────────────────────────────────
        Text(
          'Red de Seguridad Personal',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Estas personas recibirán una alerta inteligente y tu ubicación exacta '
          'si activas el SOS o sales de la geocerca.',
          style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
        ),
        const SizedBox(height: 14),

        // ── Badge de capacidad ──────────────────────────────────────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${lista.length} / $_limiteMaximo contactos SOS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Indicador ISO 31000
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ISO 31000 ✓',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Lista de contactos ──────────────────────────────────────────────
        // shrinkWrap + NeverScrollable para no competir con el scroll del Stepper
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lista.length,
          itemBuilder:
              (ctx, i) => _TarjetaContacto(
                contacto: lista[i],
                onEditar: () => _abrirDialogo(editando: lista[i]),
                onEliminar: () => _eliminar(i),
              ),
        ),

        // ── Botón añadir ────────────────────────────────────────────────────
        if (puedeAgregar) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _abrirDialogo(),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: const Text('Añadir contacto de confianza'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withAlpha(120)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Máximo de contactos alcanzado. '
                    'Elimina uno para agregar otro.',
                    style: TextStyle(fontSize: 11, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],

        // ── Botón final (modo standalone) ───────────────────────────────────
        if (widget.showFinalizarButton) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _mostrarConfirmacion,
              icon: const Icon(Icons.shield_rounded),
              label: const Text(
                'PUBLICAR Y ACTIVAR PROTECCIÓN',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subwidgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────

class _TarjetaContacto extends StatelessWidget {
  final ContactoConfianza contacto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaContacto({
    required this.contacto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.primary.withAlpha(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.primary.withAlpha(35)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: 20,
          child: Text(
            contacto.nombre.isNotEmpty ? contacto.nombre[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        title: Text(
          contacto.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contacto.relacion.isNotEmpty)
              Text(
                contacto.relacion,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(
              contacto.telefono.isNotEmpty
                  ? contacto.telefono
                  : 'Sin teléfono registrado',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 18),
              color: Colors.grey.shade600,
              onPressed: onEditar,
              tooltip: 'Editar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              color: Colors.redAccent,
              onPressed: onEliminar,
              tooltip: 'Eliminar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoDialogo extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final String? hint;
  final TextInputType? tipo;
  final List<TextInputFormatter>? formato;

  const _CampoDialogo({
    required this.controller,
    required this.label,
    required this.icono,
    this.hint,
    this.tipo,
    this.formato,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: tipo,
    inputFormatters: formato,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icono, size: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );
}
