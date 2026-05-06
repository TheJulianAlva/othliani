import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/categoria_actividad.dart';

/// Modal para que la agencia cree una categoría personalizada de actividad.
/// Retorna una [CategoriaActividad] via Navigator.pop cuando el usuario guarda.
class NewCategoryModal extends StatefulWidget {
  const NewCategoryModal({super.key});

  @override
  State<NewCategoryModal> createState() => _NewCategoryModalState();
}

class _NewCategoryModalState extends State<NewCategoryModal> {
  final _nombreController = TextEditingController();
  final _duracionController = TextEditingController(text: '60');
  String _emoji = '✨';
  bool _mostrarPicker = false;

  // Colores rápidos para que la agencia elija
  static const _colores = [
    '#2196F3', // Azul
    '#4CAF50', // Verde
    '#FF9800', // Naranja
    '#9C27B0', // Morado
    '#F44336', // Rojo
    '#009688', // Teal
    '#795548', // Marrón
    '#607D8B', // Gris azul
  ];
  String _colorHex = '#2196F3';

  @override
  void dispose() {
    _nombreController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para la categoría')),
      );
      return;
    }
    final nueva = CategoriaActividad(
      id: const Uuid().v4(),
      nombre: nombre,
      emoji: _emoji,
      colorHex: _colorHex,
      duracionDefaultMinutos: int.tryParse(_duracionController.text) ?? 60,
      esPersonalizada: true,
    );
    Navigator.of(context).pop(nueva);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ───────────────────────────────────────────────
            Row(
              children: [
                const Text(
                  'Nueva categoría',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B263B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Emoji + Nombre ────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón emoji
                GestureDetector(
                  onTap: () => setState(() => _mostrarPicker = !_mostrarPicker),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(_colorHex.replaceFirst('#', '0xFF')),
                      ).withValues(alpha: 0.15),
                      border: Border.all(
                        color: Color(
                          int.parse(_colorHex.replaceFirst('#', '0xFF')),
                        ),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(_emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Campo nombre
                Expanded(
                  child: TextField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nombre (ej. Buceo, Meditación)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Emoji Picker (colapsable) ─────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _mostrarPicker ? 250 : 0,
              curve: Curves.easeInOut,
              child:
                  _mostrarPicker
                      ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: EmojiPicker(
                            onEmojiSelected: (_, emoji) {
                              setState(() {
                                _emoji = emoji.emoji;
                                _mostrarPicker = false;
                              });
                            },
                            config: const Config(
                              height: 250,
                              emojiViewConfig: EmojiViewConfig(
                                columns: 8,
                                emojiSizeMax: 28,
                              ),
                            ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // ── Color ─────────────────────────────────────────────────────
            const Text(
              'Color de la tarjeta',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children:
                  _colores.map((hex) {
                    final color = Color(
                      int.parse(hex.replaceFirst('#', '0xFF')),
                    );
                    final selected = hex == _colorHex;
                    return GestureDetector(
                      onTap: () => setState(() => _colorHex = hex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border:
                              selected
                                  ? Border.all(color: Colors.black87, width: 3)
                                  : null,
                        ),
                        child:
                            selected
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                                : null,
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Duración ──────────────────────────────────────────────────
            TextField(
              controller: _duracionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Duración por defecto (minutos)',
                suffixText: 'min',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Botón guardar ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Añadir a mis categorías'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B263B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
