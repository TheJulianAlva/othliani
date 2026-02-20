import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_onboarding_cubit.dart';

class GuiaOnboardingScreen extends StatelessWidget {
  const GuiaOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GuiaOnboardingCubit>(),
      child: const _GuiaOnboardingView(),
    );
  }
}

class _GuiaOnboardingView extends StatefulWidget {
  const _GuiaOnboardingView();

  @override
  State<_GuiaOnboardingView> createState() => _GuiaOnboardingViewState();
}

class _GuiaOnboardingViewState extends State<_GuiaOnboardingView> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  static const List<_PaginaOnboarding> _paginas = [
    _PaginaOnboarding(
      icono: Icons.explore,
      titulo: 'Bienvenido a OthliAni Guía',
      descripcion:
          'Tu compañero digital para gestionar y enriquecer cada experiencia turística que lideras.',
      colorIcono: Color(0xFF4355B9),
    ),
    _PaginaOnboarding(
      icono: Icons.map_outlined,
      titulo: 'Gestiona tus itinerarios',
      descripcion:
          'Accede a los itinerarios de cada viaje en tiempo real, con actividades, horarios y ubicaciones al alcance de tu mano.',
      colorIcono: Color(0xFF2E7D32),
    ),
    _PaginaOnboarding(
      icono: Icons.group_outlined,
      titulo: 'Conecta con tus participantes',
      descripcion:
          'Comunícate con el grupo, revisa la lista de participantes y atiende sus necesidades desde un solo lugar.',
      colorIcono: Color(0xFF00838F),
    ),
    _PaginaOnboarding(
      icono: Icons.notifications_outlined,
      titulo: 'Alertas y actualizaciones',
      descripcion:
          'Recibe notificaciones importantes sobre cambios en el itinerario o mensajes de la agencia en tiempo real.',
      colorIcono: Color(0xFFE65100),
    ),
  ];

  void _irASiguiente(BuildContext context) {
    if (_paginaActual < _paginas.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<GuiaOnboardingCubit>().completeOnboarding();
    }
  }

  void _omitir(BuildContext context) {
    context.read<GuiaOnboardingCubit>().completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esUltimaPagina = _paginaActual == _paginas.length - 1;

    return BlocListener<GuiaOnboardingCubit, GuiaOnboardingState>(
      listener: (context, state) {
        if (state is GuiaOnboardingCompleted) {
          context.go(RoutesGuia.login);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Botón omitir en la parte superior
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: esUltimaPagina ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: esUltimaPagina ? null : () => _omitir(context),
                      child: const Text('Omitir'),
                    ),
                  ),
                ),
              ),

              // Páginas de onboarding
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _paginas.length,
                  onPageChanged: (index) {
                    setState(() => _paginaActual = index);
                  },
                  itemBuilder: (context, index) {
                    return _PaginaOnboardingWidget(pagina: _paginas[index]);
                  },
                ),
              ),

              // Indicadores + botón siguiente
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicadores de página
                    Row(
                      children: List.generate(
                        _paginas.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          width: _paginaActual == index ? 24 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color:
                                _paginaActual == index
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                    ),

                    // Botón siguiente / finalizar
                    BlocBuilder<GuiaOnboardingCubit, GuiaOnboardingState>(
                      builder: (context, state) {
                        if (state is GuiaOnboardingLoading) {
                          return const SizedBox(
                            width: 56,
                            height: 56,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          );
                        }
                        return ElevatedButton(
                          onPressed: () => _irASiguiente(context),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                          ),
                          child: Icon(
                            esUltimaPagina ? Icons.check : Icons.arrow_forward,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Datos de cada página ─────────────────────────────────────────────────────

class _PaginaOnboarding {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color colorIcono;

  const _PaginaOnboarding({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.colorIcono,
  });
}

// ── Widget de cada página ─────────────────────────────────────────────────────

class _PaginaOnboardingWidget extends StatelessWidget {
  final _PaginaOnboarding pagina;

  const _PaginaOnboardingWidget({required this.pagina});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustración con icono
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: pagina.colorIcono.withAlpha(25),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(pagina.icono, size: 100, color: pagina.colorIcono),
          ),
          const SizedBox(height: 40),
          // Título
          Text(
            pagina.titulo,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Descripción
          Text(
            pagina.descripcion,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
