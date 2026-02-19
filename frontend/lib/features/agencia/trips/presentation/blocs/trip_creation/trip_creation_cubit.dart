import 'package:flutter/material.dart'; // Para TimeOfDay
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
// import '../../../core/services/pexels_service.dart'; // ELIMINADO: Clean Architecture
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart'; // ✨ Import necesario
import 'package:frontend/features/agencia/trips/domain/repositories/trip_repository.dart';
import 'package:frontend/features/agencia/trips/data/datasources/trip_local_data_source.dart'; // 💾 Persistencia
import 'package:frontend/features/agencia/trips/data/models/trip_draft_model.dart'; // 💾 Modelo Borrador
import 'package:uuid/uuid.dart';

// --- ESTADO ---
class TripCreationState extends Equatable {
  final int currentStep; // Para el Stepper de la UI
  final String destino;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final List<ActividadItinerario> itinerario;
  final bool isSaving;

  // Nuevos campos para Datos Generales Robustos
  final String? selectedGuiaId; // El Principal (Jefe de expedición)
  final List<String> coGuiasIds; // Los Auxiliares (Equipo de apoyo)
  final LatLng? location; // Coordenadas del destino principal
  final String? nombreUbicacionMapa; // Rastrea el nombre autocompletado
  final bool isMultiDay; // Switch para lógica de fechas

  // Añadimos TimeOfDay para manejo preciso de horas
  final TimeOfDay? horaInicio;
  final TimeOfDay? horaFin;
  final String searchQueryGuia; // Para el buscador del modal
  final List<Map<String, dynamic>> availableGuides; // Lista de guías

  // Campos para Carrusel de Fotos (Inteligencia Visual)
  final String? fotoPortadaUrl;
  final List<String> fotosCandidatas;

  // 💾 Persistencia
  final bool draftFound;
  final TripDraftModel? draftData;

  const TripCreationState({
    this.currentStep = 0,
    this.destino = '',
    this.fechaInicio,
    this.fechaFin,
    this.itinerario = const [],
    this.isSaving = false,
    this.selectedGuiaId,
    this.coGuiasIds = const [], // Inicializar vacía
    this.location,
    this.nombreUbicacionMapa,
    this.isMultiDay = false,
    this.horaInicio,
    this.horaFin,
    this.searchQueryGuia = '',
    this.availableGuides =
        const [], // Lista vacía por defecto, se carga desde el repository
    this.fotoPortadaUrl,
    this.fotosCandidatas = const [],
    this.draftFound = false,
    this.draftData,
  });

  TripCreationState copyWith({
    int? currentStep,
    String? destino,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    List<ActividadItinerario>? itinerario,
    bool? isSaving,
    String? selectedGuiaId,
    List<String>? coGuiasIds,
    LatLng? location,
    String? nombreUbicacionMapa,
    bool? isMultiDay,
    TimeOfDay? horaInicio,
    TimeOfDay? horaFin,
    String? searchQueryGuia,
    List<Map<String, dynamic>>? availableGuides,
    String? fotoPortadaUrl,
    List<String>? fotosCandidatas,
    bool? draftFound,
    TripDraftModel? draftData,
  }) {
    return TripCreationState(
      currentStep: currentStep ?? this.currentStep,
      destino: destino ?? this.destino,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      itinerario: itinerario ?? this.itinerario,
      isSaving: isSaving ?? this.isSaving,
      selectedGuiaId: selectedGuiaId ?? this.selectedGuiaId,
      coGuiasIds: coGuiasIds ?? this.coGuiasIds,
      location: location ?? this.location,
      nombreUbicacionMapa: nombreUbicacionMapa ?? this.nombreUbicacionMapa,
      isMultiDay: isMultiDay ?? this.isMultiDay,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      searchQueryGuia: searchQueryGuia ?? this.searchQueryGuia,
      availableGuides: availableGuides ?? this.availableGuides,
      fotoPortadaUrl: fotoPortadaUrl ?? this.fotoPortadaUrl,
      fotosCandidatas: fotosCandidatas ?? this.fotosCandidatas,
      draftFound: draftFound ?? this.draftFound,
      draftData: draftData ?? this.draftData,
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
    coGuiasIds,
    location,
    nombreUbicacionMapa,
    isMultiDay,
    horaInicio,
    horaFin,
    searchQueryGuia,
    availableGuides,
    fotoPortadaUrl,
    fotosCandidatas,
    draftFound,
    draftData,
  ];
}

// --- CUBIT ---
class TripCreationCubit extends Cubit<TripCreationState> {
  final TripRepository _repository;
  final TripLocalDataSource _localDataSource; // 💾 Inyección

  TripCreationCubit({
    required TripRepository repository,
    required TripLocalDataSource localDataSource,
  }) : _repository = repository,
       _localDataSource = localDataSource,
       super(const TripCreationState()) {
    _loadGuides(); // Cargar guías al inicializar
  }

  // --- MÉTODOS DE AUTOGUARDADO (Fase 13) ---
  void _autoSave() {
    final draft = TripDraftModel(
      destino: state.destino,
      guiaId: state.selectedGuiaId,
      fechaInicio: state.fechaInicio?.toIso8601String(),
      fechaFin: state.fechaFin?.toIso8601String(),
      lat: state.location?.latitude,
      lng: state.location?.longitude,
      actividades: [], // Paso 1 no tiene actividades aún
    );
    _localDataSource.saveDraft(draft);
    // print("💾 Auto-guardado Paso 1: ${state.destino}");
  }

  // --- MÉTODOS DE RECUPERACIÓN ---
  Future<void> checkForDraft() async {
    final draft = await _localDataSource.getDraft();
    if (draft != null && (draft.destino?.isNotEmpty ?? false)) {
      emit(state.copyWith(draftFound: true, draftData: draft));
    }
  }

  void restoreDraft() {
    final draft = state.draftData;
    if (draft == null) return;

    emit(
      state.copyWith(
        destino: draft.destino ?? '',
        selectedGuiaId: draft.guiaId,
        fechaInicio:
            draft.fechaInicio != null
                ? DateTime.parse(draft.fechaInicio!)
                : null,
        fechaFin:
            draft.fechaFin != null ? DateTime.parse(draft.fechaFin!) : null,
        location:
            (draft.lat != null && draft.lng != null)
                ? LatLng(draft.lat!, draft.lng!)
                : null,
        draftFound: false, // Ya restaurado, apagamos la bandera
        currentStep: 0, // Volvemos al inicio para que vea los datos
      ),
    );

    // Buscar fotos de nuevo si hay destino
    if (draft.destino != null) {
      // _buscarFotos(draft.destino!); // Assuming this method exists or will be added
    }
  }

  void discardDraft() {
    _localDataSource.clearDraft();
    emit(state.copyWith(draftFound: false, draftData: null));
  }

  // Cargar guías reales del mock database
  Future<void> _loadGuides() async {
    final guiasResult = await _repository.getListaGuias();
    final viajesResult = await _repository.getListaViajes();

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

  // Integración Pexels (ELIMINADA: Usamos Repository)
  // final PexelsService _pexelsService = PexelsService();
  Timer? _debounce;

  void onDestinoChanged(String query) {
    debugPrint("🟢 Usuario escribió: $query");
    // Solo actualizamos el texto, NO buscamos fotos
    // Las fotos solo se buscan desde el mapa
    emit(state.copyWith(destino: query));

    // Cancelar cualquier búsqueda pendiente
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _autoSave(); // 💾
  }

  // Deprecated: Usar onDestinoChanged para el texto
  void updateBasicInfo(String destino, DateTime? inicio, DateTime? fin) {
    emit(state.copyWith(destino: destino, fechaInicio: inicio, fechaFin: fin));
    if (destino.length > 3) {
      // _cargarFotosCandidatas(destino); // Ya no se usa este método mock
      onDestinoChanged(destino); // Reutilizamos lógica con debounce
    }
  }

  void setGuia(String? id) {
    List<String> currentCoGuias = List.from(state.coGuiasIds);
    if (id != null && currentCoGuias.contains(id)) {
      currentCoGuias.remove(id); // Lo sacamos de auxiliares si ahora es jefe
    }
    emit(state.copyWith(selectedGuiaId: id, coGuiasIds: currentCoGuias));
    _autoSave(); // 💾
  }

  /// Agregar o Quitar un Co-Guía
  void toggleCoGuia(String guiaId) {
    // Regla de Oro: El principal no puede ser auxiliar
    if (state.selectedGuiaId == guiaId) return;

    final currentList = List<String>.from(state.coGuiasIds);
    if (currentList.contains(guiaId)) {
      currentList.remove(guiaId); // Si ya está, lo quitamos
    } else {
      currentList.add(guiaId); // Si no está, lo agregamos
    }
    emit(state.copyWith(coGuiasIds: currentList));
    _autoSave(); // 💾
  }

  void setLocation(LatLng loc) => emit(state.copyWith(location: loc));

  // Método maestro mejorado: Ubicación + Autocompletado + Fotos

  // ✨ COMPUTE TEMPORAL TRIP (Para pasar a Itinerary Builder)
  Viaje get viajeTemporal {
    // Combinar Fecha + Hora para crear DateTime precisos
    final inicioDateTime = DateTime(
      state.fechaInicio!.year,
      state.fechaInicio!.month,
      state.fechaInicio!.day,
      state.horaInicio!.hour,
      state.horaInicio!.minute,
    );

    final finDateBase = state.isMultiDay ? state.fechaFin! : state.fechaInicio!;
    final finDateTime = DateTime(
      finDateBase.year,
      finDateBase.month,
      finDateBase.day,
      state.horaFin!.hour,
      state.horaFin!.minute,
    );

    return Viaje(
      id: const Uuid().v4(), // Generamos ID temporal nuevo cada vez
      destino: state.destino,
      estado: 'PROGRAMADO', // Estado inicial
      fechaInicio: inicioDateTime,
      fechaFin: finDateTime,
      turistas: 0, // Aún no asignados en este flujo
      latitud: state.location?.latitude ?? 0.0,
      longitud: state.location?.longitude ?? 0.0,
      guiaNombre: _getNombreGuia(
        state.selectedGuiaId,
      ), // Helper para sacar nombre
      horaInicio: _formatTimeOfDay(
        state.horaInicio,
      ), // String legacy, pero útil
      alertasActivas: 0,
      itinerario: const [], // Vacío al iniciar
    );
  }

  String _getNombreGuia(String? id) {
    if (id == null) return 'Sin asignar';
    final guia = state.availableGuides.firstWhere(
      (g) => g['id'] == id,
      orElse: () => {'name': 'Desconocido'},
    );
    return guia['name'] as String;
  }

  void setLocationAndSearchPhotos(LatLng loc, {String? nombreSugerido}) {
    String nuevoNombre = state.destino;
    String terminoBusqueda = state.destino;

    if (nombreSugerido != null && nombreSugerido.isNotEmpty) {
      if (state.destino.trim().isEmpty) {
        // Caso A: Campo vacío -> Usar nombre del mapa directamente
        nuevoNombre = nombreSugerido;
        terminoBusqueda = nombreSugerido;
      } else if (state.nombreUbicacionMapa != null) {
        // Caso B: Ya hay una ubicación previa del mapa
        // Buscar y reemplazar el nombre anterior en CUALQUIER parte del texto

        final nombreAnterior = state.nombreUbicacionMapa!;

        // Verificar si el texto contiene el nombre anterior
        if (state.destino.contains(nombreAnterior)) {
          // Reemplazar el nombre anterior por el nuevo
          nuevoNombre = state.destino.replaceAll(
            nombreAnterior,
            nombreSugerido,
          );
          terminoBusqueda = nombreSugerido;
        } else {
          // El usuario editó el texto y quitó el nombre anterior
          // Agregar el nuevo nombre entre paréntesis
          nuevoNombre = "${state.destino} ($nombreSugerido)";
          terminoBusqueda = nombreSugerido;
        }
      } else {
        // Caso C: Primera vez que selecciona del mapa y ya escribió algo
        // Agregar ubicación entre paréntesis
        nuevoNombre = "${state.destino} ($nombreSugerido)";
        terminoBusqueda = nombreSugerido;
      }
    }

    // Actualizamos el estado
    emit(
      state.copyWith(
        location: loc,
        destino: nuevoNombre,
        nombreUbicacionMapa: nombreSugerido,
      ),
    );

    // Buscar fotos solo con el nombre de la ubicación
    if (terminoBusqueda.length > 3) {
      debugPrint("🔍 Buscando fotos para: $terminoBusqueda");

      _repository
          .buscarFotosDestino(terminoBusqueda)
          .then((fotos) {
            if (fotos.isNotEmpty) {
              debugPrint("📸 Encontradas ${fotos.length} fotos");
              emit(state.copyWith(fotosCandidatas: fotos));
              if (state.fotoPortadaUrl == null ||
                  (state.fotoPortadaUrl?.contains('mapbox') ?? false)) {
                emit(state.copyWith(fotoPortadaUrl: fotos.first));
              }
            }
          })
          .catchError((e) {
            debugPrint("❌ Error buscando fotos desde mapa: $e");
          });
    }
    _autoSave(); // 💾
  }

  // VALIDACIÓN EN TIEMPO REAL (Getters)
  bool get isStep1Valid {
    // Reglas de Negocio Obligatorias
    final bool tieneNombre = state.destino.trim().isNotEmpty;
    final bool tieneUbicacion = state.location != null;
    final bool tieneGuia = state.selectedGuiaId != null;
    final bool tieneFechaInicio = state.fechaInicio != null;
    final bool tieneHoraInicio = state.horaInicio != null;

    // Validación condicional de fechas
    bool fechasValidas = true;
    if (state.isMultiDay) {
      // Si es multidía, DEBE tener fecha fin Y hora fin
      if (state.fechaFin == null || state.horaFin == null) {
        fechasValidas = false;
      } else {
        // ✨ NUEVO: Validar mínimo 2 horas entre inicio y fin (con fechas reales)
        final inicio = DateTime(
          state.fechaInicio!.year,
          state.fechaInicio!.month,
          state.fechaInicio!.day,
          state.horaInicio!.hour,
          state.horaInicio!.minute,
        );
        final fin = DateTime(
          state.fechaFin!.year,
          state.fechaFin!.month,
          state.fechaFin!.day,
          state.horaFin!.hour,
          state.horaFin!.minute,
        );
        fechasValidas = fin.difference(inicio).inMinutes >= 120;
      }
    } else {
      // Si es un día, DEBE tener hora fin Y al menos 2 horas de diferencia
      if (state.horaFin == null || state.horaInicio == null) {
        fechasValidas = false;
      } else {
        final inicioMin =
            state.horaInicio!.hour * 60 + state.horaInicio!.minute;
        final finMin = state.horaFin!.hour * 60 + state.horaFin!.minute;
        // ✨ NUEVO: mínimo 120 minutos de diferencia
        fechasValidas = (finMin - inicioMin) >= 120;
      }
    }

    return tieneNombre &&
        tieneUbicacion &&
        tieneGuia &&
        tieneFechaInicio &&
        tieneHoraInicio &&
        fechasValidas;
  }

  void toggleMultiDay(bool value) {
    // Al cambiar de modo, crear un nuevo estado limpio con fechas y horas reseteadas
    emit(
      TripCreationState(
        currentStep: state.currentStep,
        destino: state.destino,
        isMultiDay: value,
        selectedGuiaId: state.selectedGuiaId,
        coGuiasIds: state.coGuiasIds,
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

  /// Establece la fecha de inicio con validaciones inteligentes:
  /// - Si la nueva fecha es hoy y la horaInicio ya pasó → resetea horaInicio
  /// - Si la nueva fecha es posterior a fechaFin → resetea fechaFin y horaFin
  void setFechaInicio(DateTime nuevaFecha) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final nuevaFechaSinHora = DateTime(
      nuevaFecha.year,
      nuevaFecha.month,
      nuevaFecha.day,
    );

    // ¿La hora de inicio ya pasó si el viaje es hoy?
    TimeOfDay? nuevaHoraInicio = state.horaInicio;
    if (nuevaFechaSinHora == hoy && state.horaInicio != null) {
      final horaActualEnMinutos = ahora.hour * 60 + ahora.minute;
      final horaGuardadaEnMinutos =
          state.horaInicio!.hour * 60 + state.horaInicio!.minute;
      if (horaGuardadaEnMinutos <= horaActualEnMinutos) {
        nuevaHoraInicio = null; // Resetear hora inválida
      }
    }

    // ¿La nueva fecha de inicio es posterior a la fecha de fin?
    DateTime? nuevaFechaFin = state.fechaFin;
    TimeOfDay? nuevaHoraFin = state.horaFin;
    if (state.fechaFin != null && nuevaFecha.isAfter(state.fechaFin!)) {
      nuevaFechaFin = null;
      nuevaHoraFin = null;
    }

    emit(
      TripCreationState(
        currentStep: state.currentStep,
        destino: state.destino,
        isMultiDay: state.isMultiDay,
        selectedGuiaId: state.selectedGuiaId,
        coGuiasIds: state.coGuiasIds,
        location: state.location,
        nombreUbicacionMapa: state.nombreUbicacionMapa,
        searchQueryGuia: state.searchQueryGuia,
        availableGuides: state.availableGuides,
        fotoPortadaUrl: state.fotoPortadaUrl,
        fotosCandidatas: state.fotosCandidatas,
        itinerario: state.itinerario,
        isSaving: state.isSaving,
        fechaInicio: nuevaFecha,
        fechaFin: nuevaFechaFin,
        horaInicio: nuevaHoraInicio,
        horaFin: nuevaHoraFin,
      ),
    );
  }

  /// Establece la fecha de fin (sin lógica especial, la UI ya valida que sea > inicio)
  void setFechaFin(DateTime nuevaFecha) {
    emit(state.copyWith(fechaFin: nuevaFecha));
    _autoSave(); // 💾
  }

  // Método legacy mantenido por compatibilidad
  void setDates({DateTime? start, DateTime? end}) {
    if (start != null) setFechaInicio(start);
    if (end != null) setFechaFin(end);
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
      if (state.fechaFin == null || state.horaFin == null) return false;
      // Validar que fin sea > inicio (ya lo hace el UI, pero por seguridad)
      if (state.fechaFin!.isBefore(state.fechaInicio!)) return false;
      // ✨ NUEVO: Mínimo 2 horas entre inicio y fin (con fechas reales)
      final inicio = DateTime(
        state.fechaInicio!.year,
        state.fechaInicio!.month,
        state.fechaInicio!.day,
        state.horaInicio!.hour,
        state.horaInicio!.minute,
      );
      final fin = DateTime(
        state.fechaFin!.year,
        state.fechaFin!.month,
        state.fechaFin!.day,
        state.horaFin!.hour,
        state.horaFin!.minute,
      );
      if (fin.difference(inicio).inMinutes < 120) return false;
    } else {
      // Validación 1 Día
      if (state.horaFin == null) return false;
      // Validar horas
      final double start =
          state.horaInicio!.hour + state.horaInicio!.minute / 60.0;
      final double end = state.horaFin!.hour + state.horaFin!.minute / 60.0;
      if (end <= start) return false;
      // ✨ NUEVO: Mínimo 2 horas de diferencia
      if ((end - start) < 2.0) return false;
    }

    return true;
  }

  void nextStep() {
    // Validar antes de avanzar desde el paso 0 (Datos Generales)
    if (state.currentStep == 0 && !isStep1Valid) {
      // No avanzar si la validación falla
      return;
    }

    if (state.currentStep < 1) {
      // Solo hay paso 0 y 1 ahora
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void prevStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  // Ir a un paso específico
  void goToStep(int step) {
    if (step >= 0 && step <= 1) {
      emit(state.copyWith(currentStep: step));
    }
  }

  Future<void> saveTrip() async {
    emit(state.copyWith(isSaving: true));

    // ✅ AHORA: Usamos el Repositorio para guardar
    // Primero, convertimos el estado a una entidad Viaje (simplificado por ahora)
    // En el futuro, haremos un mapper real.

    /* 
    final nuevoViaje = Viaje(
      id: const Uuid().v4(),
      destino: state.destino,
      encargado: state.selectedGuiaId ?? "Sin Asignar",
      estado: "PROGRAMADO",
      // ... más campos
    );
    */

    // Llamada abstracta al repositorio
    // await repository.crearViaje(nuevoViaje);

    // Simulamos guardado por ahora hasta tener el mapper completo
    await Future.delayed(const Duration(seconds: 2));

    emit(state.copyWith(isSaving: false));
  }

  void seleccionarFoto(String url) {
    emit(state.copyWith(fotoPortadaUrl: url));
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return "--:--";
    final h = time.hour;
    final m = time.minute.toString().padLeft(2, '0');
    final periodo = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return "$h12:$m $periodo";
  }
}
