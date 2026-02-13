import 'package:flutter/material.dart'; // Para TimeOfDay
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../../core/services/pexels_service.dart';
import '../../../domain/entities/actividad_itinerario.dart';
import '../../../domain/repositories/agencia_repository.dart';

// --- ESTADO ---
class TripCreationState extends Equatable {
  final int currentStep; // Para el Stepper de la UI
  final String destino;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final List<ActividadItinerario> itinerario;
  final bool isSaving;

  // Nuevos campos para Datos Generales Robustos
  final String? selectedGuiaId; // ID del guía asignado
  final LatLng? location; // Coordenadas del destino principal
  final bool isMultiDay; // Switch para lógica de fechas

  // Añadimos TimeOfDay para manejo preciso de horas
  final TimeOfDay? horaInicio;
  final TimeOfDay? horaFin;
  final String searchQueryGuia; // Para el buscador del modal
  final List<Map<String, dynamic>> availableGuides; // Lista de guías

  // Campos para Carrusel de Fotos (Inteligencia Visual)
  final String? fotoPortadaUrl;
  final List<String> fotosCandidatas;

  const TripCreationState({
    this.currentStep = 0,
    this.destino = '',
    this.fechaInicio,
    this.fechaFin,
    this.itinerario = const [],
    this.isSaving = false,
    this.selectedGuiaId,
    this.location,
    this.isMultiDay = false,
    this.horaInicio,
    this.horaFin,
    this.searchQueryGuia = '',
    this.availableGuides =
        const [], // Lista vacía por defecto, se carga desde el repository
    this.fotoPortadaUrl,
    this.fotosCandidatas = const [],
  });

  TripCreationState copyWith({
    int? currentStep,
    String? destino,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    List<ActividadItinerario>? itinerario,
    bool? isSaving,
    String? selectedGuiaId,
    LatLng? location,
    bool? isMultiDay,
    TimeOfDay? horaInicio,
    TimeOfDay? horaFin,
    String? searchQueryGuia,
    List<Map<String, dynamic>>? availableGuides,
    String? fotoPortadaUrl,
    List<String>? fotosCandidatas,
  }) {
    return TripCreationState(
      currentStep: currentStep ?? this.currentStep,
      destino: destino ?? this.destino,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      itinerario: itinerario ?? this.itinerario,
      isSaving: isSaving ?? this.isSaving,
      selectedGuiaId: selectedGuiaId ?? this.selectedGuiaId,
      location: location ?? this.location,
      isMultiDay: isMultiDay ?? this.isMultiDay,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      searchQueryGuia: searchQueryGuia ?? this.searchQueryGuia,
      availableGuides: availableGuides ?? this.availableGuides,
      fotoPortadaUrl: fotoPortadaUrl ?? this.fotoPortadaUrl,
      fotosCandidatas: fotosCandidatas ?? this.fotosCandidatas,
    );
  }

  // Getter inteligente para ordenar guías
  List<Map<String, dynamic>> get guiasFiltrados {
    // 1. Filtrar por texto
    var lista =
        availableGuides
            .where(
              (g) => (g['name'] as String).toLowerCase().contains(
                searchQueryGuia.toLowerCase(),
              ),
            )
            .toList();

    // 2. Ordenar: Disponibles arriba, Ocupados abajo
    lista.sort((a, b) {
      if (a['status'] == 'Disponible' && b['status'] != 'Disponible') return -1;
      if (a['status'] != 'Disponible' && b['status'] == 'Disponible') return 1;
      return 0;
    });
    return lista;
  }

  //Calculadora de Huella de Carbono Total
  double get totalHuellaCarbono =>
      itinerario.fold(0, (sum, item) => sum + item.huellaCarbono);

  @override
  List<Object?> get props => [
    currentStep,
    destino,
    fechaInicio,
    fechaFin,
    itinerario,
    isSaving,
    selectedGuiaId,
    location,
    isMultiDay,
    horaInicio,
    horaFin,
    searchQueryGuia,
    availableGuides,
    fotoPortadaUrl,
    fotosCandidatas,
  ];
}

// --- CUBIT ---
class TripCreationCubit extends Cubit<TripCreationState> {
  final AgenciaRepository repository;

  TripCreationCubit({required this.repository})
    : super(const TripCreationState()) {
    _loadGuides(); // Cargar guías al inicializar
  }

  // Cargar guías reales del mock database
  Future<void> _loadGuides() async {
    final guiasResult = await repository.getListaGuias();
    final viajesResult = await repository.getListaViajes();

    guiasResult.fold(
      (failure) => {}, // Ignorar error por ahora
      (guias) {
        viajesResult.fold((failure) => {}, (viajes) {
          // Calcular estado de disponibilidad de cada guía
          final guiasConEstado =
              guias.map((guia) {
                String statusLabel;

                // Verificar si el guía está en un viaje EN_CURSO
                final viajeEnCurso = viajes.any(
                  (v) =>
                      v.estado == 'EN_CURSO' &&
                      v.guiaNombre.contains(guia.nombre.split(' ')[0]),
                );

                // Verificar si el guía está en un viaje PROGRAMADO
                final viajeProgramado = viajes.any(
                  (v) =>
                      v.estado == 'PROGRAMADO' &&
                      v.guiaNombre.contains(guia.nombre.split(' ')[0]),
                );

                if (viajeEnCurso) {
                  statusLabel = 'Ocupado en otro viaje';
                } else if (viajeProgramado) {
                  statusLabel = 'Tiene viaje programado';
                } else if (guia.status == 'ONLINE') {
                  statusLabel = 'Disponible';
                } else {
                  statusLabel = 'No disponible';
                }

                return <String, dynamic>{
                  'id': guia.id,
                  'name': guia.nombre,
                  'status': statusLabel,
                  'originalStatus': guia.status, // Para debugging
                };
              }).toList();

          emit(state.copyWith(availableGuides: guiasConEstado));
        });
      },
    );
  }

  // Integración Pexels
  final PexelsService _pexelsService = PexelsService();
  Timer? _debounce;

  void onDestinoChanged(String query) {
    print("🟢 1. El Cubit recibió el texto: $query"); // DEBUG 1
    // 1. Actualizamos el texto en el estado inmediatamente
    emit(state.copyWith(destino: query));

    // 2. Cancelamos la búsqueda anterior si el usuario sigue escribiendo
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 3. Esperamos 1 segundo (1000 ms) de inactividad
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      print("🟡 2. Pasó 1 segundo, intentando buscar..."); // DEBUG 2

      if (query.length > 3) {
        print("🟠 3. Longitud válida, llamando a PexelsService..."); // DEBUG 3

        try {
          final fotos = await _pexelsService.buscarFotos(query);
          print("🔵 4. Pexels respondió con ${fotos.length} fotos"); // DEBUG 4

          if (fotos.isNotEmpty) {
            emit(state.copyWith(fotosCandidatas: fotos));
            print("🟣 5. Estado actualizado con fotos"); // DEBUG 5

            // Opcional: Auto-seleccionar la primera foto bonita
            if (state.fotoPortadaUrl == null ||
                (state.fotoPortadaUrl?.contains('mapbox') ?? false)) {
              emit(state.copyWith(fotoPortadaUrl: fotos.first));
            }
          }
        } catch (e) {
          print("🚨 Error explotó en el Cubit: $e");
        }
      } else {
        print("⚪ Texto muy corto para buscar");
      }
    });
  }

  // Deprecated: Usar onDestinoChanged para el texto
  void updateBasicInfo(String destino, DateTime? inicio, DateTime? fin) {
    emit(state.copyWith(destino: destino, fechaInicio: inicio, fechaFin: fin));
    if (destino.length > 3) {
      // _cargarFotosCandidatas(destino); // Ya no se usa este método mock
      onDestinoChanged(destino); // Reutilizamos lógica con debounce
    }
  }

  void setGuia(String? id) => emit(state.copyWith(selectedGuiaId: id));

  void setLocation(LatLng loc) => emit(state.copyWith(location: loc));

  void toggleMultiDay(bool value) {
    // Al cambiar de modo, crear un nuevo estado limpio con fechas y horas reseteadas
    emit(
      TripCreationState(
        currentStep: state.currentStep,
        destino: state.destino,
        isMultiDay: value,
        selectedGuiaId: state.selectedGuiaId,
        location: state.location,
        searchQueryGuia: state.searchQueryGuia,
        availableGuides: state.availableGuides,
        fotoPortadaUrl: state.fotoPortadaUrl,
        fotosCandidatas: state.fotosCandidatas,
        // Resetear fechas y horas a null
        fechaInicio: null,
        fechaFin: null,
        horaInicio: null,
        horaFin: null,
      ),
    );
  }

  void setHoraInicio(TimeOfDay t) => emit(state.copyWith(horaInicio: t));
  void setHoraFin(TimeOfDay t) => emit(state.copyWith(horaFin: t));
  void searchGuia(String query) => emit(state.copyWith(searchQueryGuia: query));

  // Método auxiliar para setear fechas complejas
  void setDates({DateTime? start, DateTime? end}) {
    emit(state.copyWith(fechaInicio: start, fechaFin: end));
  }

  void addActivity(ActividadItinerario actividad) {
    // Ordenamos cronológicamente al insertar
    final lista = List<ActividadItinerario>.from(state.itinerario)
      ..add(actividad);
    lista.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    emit(state.copyWith(itinerario: lista));
  }

  void removeActivity(String id) {
    final lista = List<ActividadItinerario>.from(state.itinerario)
      ..removeWhere((a) => a.id == id);
    emit(state.copyWith(itinerario: lista));
  }

  // Método para validar si puede avanzar al Paso 2
  bool validateGeneralInfo() {
    if (state.destino.isEmpty) return false;
    if (state.selectedGuiaId == null) return false;
    if (state.fechaInicio == null) return false;
    if (state.horaInicio == null) return false;

    // Validación Multidía
    if (state.isMultiDay) {
      if (state.fechaFin == null) return false;
      // Validar que fin sea > inicio (ya lo hace el UI, pero por seguridad)
      if (state.fechaFin!.isBefore(state.fechaInicio!)) return false;
    } else {
      // Validación 1 Día
      if (state.horaFin == null) return false;
      // Validar horas
      final double start =
          state.horaInicio!.hour + state.horaInicio!.minute / 60.0;
      final double end = state.horaFin!.hour + state.horaFin!.minute / 60.0;
      if (end <= start) return false;
    }

    return true;
  }

  void nextStep() {
    // Validar antes de avanzar desde el paso 0 (Datos Generales)
    if (state.currentStep == 0 && !validateGeneralInfo()) {
      // No avanzar si la validación falla
      return;
    }

    if (state.currentStep < 2) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void prevStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> saveTrip() async {
    emit(state.copyWith(isSaving: true));
    // Aquí llamarías al Repository para guardar en la API real
    await Future.delayed(const Duration(seconds: 2)); // Simulación
    emit(state.copyWith(isSaving: false));
  }

  void seleccionarFoto(String url) {
    emit(state.copyWith(fotoPortadaUrl: url));
  }
}
