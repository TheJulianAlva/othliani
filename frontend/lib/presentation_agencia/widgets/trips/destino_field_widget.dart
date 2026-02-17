import 'package:flutter/material.dart';

class DestinoFieldWidget extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool hasPhotos;
  final InputDecoration decoration;

  const DestinoFieldWidget({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.hasPhotos,
    required this.decoration,
  });

  @override
  State<DestinoFieldWidget> createState() => _DestinoFieldWidgetState();
}

class _DestinoFieldWidgetState extends State<DestinoFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant DestinoFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el estado cambia externamente (ej: desde el mapa) y es diferente
    // a lo que tiene el controlador, actualizamos el texto.
    // Importante: Checar que no sea el mismo texto para evitar loops o mover el cursor raro.
    if (widget.initialValue != _controller.text) {
      // Solo actualizamos si la diferencia es significativa (ej: autocompletado)
      // Para evitar pelear con el cursor mientras escribes, idealmente comparamos
      // si el cambio vino de afuera. Como aquí "widget.initialValue" viene del bloque,
      // asumimos que cualquier cambio en 'initialValue' que no coincida con el controller
      // debe ser reflejado (ej: selección en mapa).

      // Un hack común es mover el cursor al final si cambiamos el texto programáticamente
      _controller.value = _controller.value.copyWith(
        text: widget.initialValue,
        selection: TextSelection.collapsed(offset: widget.initialValue.length),
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller, // Usamos controller en vez de initialValue
      decoration: widget.decoration.copyWith(
        suffixIcon:
            widget.hasPhotos
                ? const Icon(Icons.photo_library, color: Colors.green)
                : null,
      ),
      onChanged: widget.onChanged,
    );
  }
}
