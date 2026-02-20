import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';
import 'package:frontend/features/guia/auth/domain/usecases/logout_guia_usecase.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';

// ────────────────────────────────────────────────────────────────────────────
// PANTALLA DE PERFIL Y CONFIGURACIÓN DEL GUÍA
// Espejo de la ProfileScreen del turista, adaptada al dominio del guía.
// ────────────────────────────────────────────────────────────────────────────

const _azulPrimario = Color(0xFF1A237E);
const _azulSecundario = Color(0xFF3D5AF1);

class GuiaProfileScreen extends StatefulWidget {
  const GuiaProfileScreen({super.key});

  @override
  State<GuiaProfileScreen> createState() => _GuiaProfileScreenState();
}

class _GuiaProfileScreenState extends State<GuiaProfileScreen> {
  GuiaUserModel? _user;
  bool _cargando = true;

  // Configuración local (mock para el MVP)
  bool _notificacionesActivas = true;
  bool _modoOscuro = false;
  String _idiomaSeleccionado = 'Español';

  final _idiomas = ['Español', 'English', 'Français'];

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('CACHED_GUIA_USER');
    if (jsonStr != null) {
      final model = GuiaUserModel.fromJson(json.decode(jsonStr));
      if (mounted) {
        setState(() {
          _user = model;
          _cargando = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  // ── Editar nombre ─────────────────────────────────────────────────────────
  void _mostrarEdicionPerfil() {
    final ctrl = TextEditingController(text: _user?.name ?? '');
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Editar perfil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _user = _user?.copyWithName(ctrl.text.trim());
                  });
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil actualizado (mock)')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulSecundario,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  // ── Cerrar sesión ─────────────────────────────────────────────────────────
  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );
    if (confirmar != true || !mounted) return;

    final logoutUseCase = sl<LogoutGuiaUseCase>();
    await logoutUseCase(NoParams());
    if (!mounted) return;
    context.go(RoutesGuia.login);
  }

  // ── Eliminar cuenta ───────────────────────────────────────────────────────
  void _eliminarCuenta() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función disponible en producción')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final nombre = _user?.name ?? 'Guía';
    final email = _user?.email ?? '–';
    final esAgencia = (_user?.permissionLevel ?? 1) == 2;
    final iniciales =
        nombre
            .split(' ')
            .take(2)
            .map((p) => p.isNotEmpty ? p[0] : '')
            .join()
            .toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: _azulPrimario,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar y datos ─────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor:
                            esAgencia
                                ? _azulSecundario
                                : const Color(0xFFE65100),
                        child: Text(
                          iniciales,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _mostrarEdicionPerfil,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color:
                                esAgencia
                                    ? _azulSecundario
                                    : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (esAgencia
                              ? _azulSecundario
                              : const Color(0xFFE65100))
                          .withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      esAgencia
                          ? '🏢 Guía de Agencia'
                          : '🧭 Guía Independiente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            esAgencia
                                ? _azulSecundario
                                : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Sección: Cuenta ────────────────────────────────────────
            _SeccionTitulo('Cuenta'),
            const SizedBox(height: 8),
            _TarjetaOpciones(
              opciones: [
                _OpcionItem(
                  icono: Icons.person_outline,
                  texto: 'Editar perfil',
                  onTap: _mostrarEdicionPerfil,
                ),
                _OpcionItem(
                  icono: Icons.lock_outline,
                  texto: 'Cambiar contraseña',
                  onTap:
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función disponible en producción'),
                        ),
                      ),
                ),
                _OpcionItem(
                  icono: Icons.badge_outlined,
                  texto: 'Mis certificaciones',
                  onTap:
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función disponible en producción'),
                        ),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Sección: Configuración ─────────────────────────────────
            _SeccionTitulo('Configuración'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  // Idioma
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text('Idioma', style: TextStyle(fontSize: 13)),
                        ),
                        DropdownButton<String>(
                          value: _idiomaSeleccionado,
                          underline: const SizedBox(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1A1A2E),
                          ),
                          items:
                              _idiomas
                                  .map(
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text(i),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _idiomaSeleccionado = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),

                  // Tema
                  SwitchListTile.adaptive(
                    secondary: const Icon(
                      Icons.dark_mode_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    title: const Text(
                      'Tema oscuro',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: _modoOscuro,
                    activeColor: _azulSecundario,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (v) => setState(() => _modoOscuro = v),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),

                  // Notificaciones
                  SwitchListTile.adaptive(
                    secondary: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    title: const Text(
                      'Notificaciones',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: _notificacionesActivas,
                    activeColor: _azulSecundario,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged:
                        (v) => setState(() => _notificacionesActivas = v),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),

                  // Accesibilidad
                  ListTile(
                    leading: const Icon(
                      Icons.accessibility_new_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    title: const Text(
                      'Accesibilidad',
                      style: TextStyle(fontSize: 13),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey,
                    ),
                    onTap:
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función disponible en producción'),
                          ),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Sección: Soporte ───────────────────────────────────────
            _SeccionTitulo('Soporte'),
            const SizedBox(height: 8),
            _TarjetaOpciones(
              opciones: [
                _OpcionItem(
                  icono: Icons.help_outline,
                  texto: 'Centro de ayuda',
                  onTap:
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función disponible en producción'),
                        ),
                      ),
                ),
                _OpcionItem(
                  icono: Icons.policy_outlined,
                  texto: 'Términos y privacidad',
                  onTap:
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función disponible en producción'),
                        ),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Versión ────────────────────────────────────────────────
            Center(
              child: Text(
                'OhtliAni Guía v1.0.0 (mock)',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),

            // ── Cerrar sesión ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _cerrarSesion,
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Eliminar cuenta ────────────────────────────────────────
            Center(
              child: TextButton(
                onPressed: _eliminarCuenta,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                ),
                child: const Text(
                  'Eliminar cuenta',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  const _SeccionTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: Color(0xFF1A1A2E),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _OpcionItem {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;
  const _OpcionItem({
    required this.icono,
    required this.texto,
    required this.onTap,
  });
}

class _TarjetaOpciones extends StatelessWidget {
  final List<_OpcionItem> opciones;
  const _TarjetaOpciones({required this.opciones});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: opciones.length,
        separatorBuilder:
            (_, __) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (_, i) {
          final o = opciones[i];
          return ListTile(
            leading: Icon(o.icono, size: 20, color: Colors.grey.shade600),
            title: Text(o.texto, style: const TextStyle(fontSize: 13)),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.grey,
            ),
            onTap: o.onTap,
          );
        },
      ),
    );
  }
}

// ── Extensión para copiar con nuevo nombre ────────────────────────────────────
extension _GuiaUserModelX on GuiaUserModel {
  GuiaUserModel copyWithName(String nombre) => GuiaUserModel(
    id: id,
    name: nombre,
    email: email,
    phone: phone,
    emergencyContact: emergencyContact,
    permissionLevel: permissionLevel,
    authStatus: authStatus,
  );
}
