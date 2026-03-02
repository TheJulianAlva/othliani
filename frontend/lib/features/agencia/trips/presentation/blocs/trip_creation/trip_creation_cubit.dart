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
import 'package:frontend/core/services/unsaved_changes_service.dart';

// --- ESTADO ---
class TripCreationState extends Equatable {
  final int currentStep; // Para el Stepper de la UI
  final String destino;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final List<ActividadItinerario> itinerario;
  final bool isSaving;

  // Nuevos campos para Datos Generales Robustos
  final String? claveBase; // Ej: MEX
  final String? selectedGuiaId; // El Principal (Jefe de expedición)
  final List<String> coGuiasIds; // Los Auxiliares (Equipo de apoyo)
  final LatLng? location; // Coordenadas del destino principal
  final String? nombreUbicacionMapa; // Rastrea el nombre autocompletado
  final bool isMultiDay; // Switch para lógica de fechas

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
    this.claveBase,
    this.selectedGuiaId,
    this.coGuiasIds = const [], // Inicializar vacía
    this.location,
    this.nombreUbicacionMapa,
    this.isMultiDay = false,
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
    String? claveBase,
    String? selectedGuiaId,
    List<String>? coGuiasIds,
    LatLng? location,
    String? nombreUbicacionMapa,
    bool? isMultiDay,
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
      claveBase: claveBase ?? this.claveBase,
      selectedGuiaId: selectedGuiaId ?? this.selectedGuiaId,
      coGuiasIds: coGuiasIds ?? this.coGuiasIds,
      location: location ?? this.location,
      nombreUbicacionMapa: nombreUbicacionMapa ?? this.nombreUbicacionMapa,
      isMultiDay: isMultiDay ?? this.isMultiDay,
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
    claveBase,
    selectedGuiaId,
    coGuiasIds,
    location,
    nombreUbicacionMapa,
    isMultiDay,
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
  final UnsavedChangesService _unsavedChangesService;
  List<Viaje> _allViajes = []; // Caché de todos los viajes para validaciones

  TripCreationCubit({
    required TripRepository repository,
    required TripLocalDataSource localDataSource,
    required UnsavedChangesService unsavedChangesService,
  }) : _repository = repository,
       _localDataSource = localDataSource,
       _unsavedChangesService = unsavedChangesService,
       super(const TripCreationState()) {
    _loadGuides(); // Cargar guías al inicializar
  }

  // --- MÉTODOS DE AUTOGUARDADO (Fase 13) ---
  void _autoSave() {
    _localDataSource.getDraft().then((existingDraft) {
      final draft = TripDraftModel(
        claveBase: state.claveBase,
        destino: state.destino,
        guiaId: state.selectedGuiaId,
        coGuiasIds: state.coGuiasIds,
        fotoPortadaUrl: state.fotoPortadaUrl,
        fechaInicio: state.fechaInicio?.toIso8601String(),
        fechaFin: state.fechaFin?.toIso8601String(),
        isMultiDay: state.isMultiDay,
        lat: state.location?.latitude,
        lng: state.location?.longitude,
        actividades:
            state.itinerario.isNotEmpty
                ? state.itinerario
                : (existingDraft?.actividades ?? []),
      );
      _localDataSource.saveDraft(draft);
      _unsavedChangesService.setDirty(true);
    });
  }

  // --- MÉTODOS DE RECUPERACIÓN ---
  Future<void> checkForDraft() async {
    final draft = await _localDataSource.getDraft();
    if (draft != null && _draftHasData(draft)) {
      emit(state.copyWith(draftFound: true, draftData: draft));
    }
  }

  /// Retorna true si el borrador tiene al menos un campo con datos relevantes.
  bool _draftHasData(TripDraftModel d) =>
      (d.destino?.isNotEmpty ?? false) ||
      (d.claveBase?.isNotEmpty ?? false) ||
      d.guiaId != null ||
      d.actividades.isNotEmpty;

  void restoreDraft() {
    final draft = state.draftData;
    if (draft == null) return;

    emit(
      state.copyWith(
        claveBase: draft.claveBase,
        destino: draft.destino ?? '',
        selectedGuiaId: draft.guiaId,
        coGuiasIds: draft.coGuiasIds,
        isMultiDay: draft.isMultiDay,
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
        fotoPortadaUrl: draft.fotoPortadaUrl,
        itinerario: draft.actividades,
        draftFound: false,
        currentStep: 0,
      ),
    );

    // Buscar fotos de nuevo si hay destino para repoblar la galería
    if (draft.destino != null && draft.destino!.length > 3) {
      debugPrint("🔄 Restaurando fotos para: ${draft.destino}");
      _repository
          .buscarFotosDestino(draft.destino!)
          .then((fotos) {
            if (fotos.isNotEmpty) {
              emit(state.copyWith(fotosCandidatas: fotos));
              // Si no había foto guardada, usar la primera nueva
              if (state.fotoPortadaUrl == null) {
                emit(state.copyWith(fotoPortadaUrl: fotos.first));
              }
            }
          })
          .catchError((e) {
            debugPrint("❌ Error restaurando fotos: $e");
          });
    }
    _unsavedChangesService.setDirty(true); // 📝 Restaurado = Trabajo pendiente
  }

  void discardDraft() {
    _localDataSource.clearDraft();
    emit(state.copyWith(draftFound: false, draftData: null));
    _unsavedChangesService.setDirty(false); // 📝 Descartado = Limpio
  }

  // Cargar guías reales del mock database
  Future<void> _loadGuides() async {
    final guiasResult = await _repository.getListaGuias();
    final viajesResult = await _repository.getListaViajes();

    guiasResult.fold(
      (failure) => {}, // Ignorar error por ahora
      (guias) {
        viajesResult.fold((failure) => {}, (viajes) {
          _allViajes = viajes;
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

    // Si el usuario escribe el destino, intentamos ver si ya hay una clave registrada
    String? posibleClave = state.claveBase;
    try {
      final viajePrevio = _allViajes.firstWhere(
        (v) => v.destino.toLowerCase() == query.trim().toLowerCase(),
      );
      if (viajePrevio.id.contains('-')) {
        posibleClave = viajePrevio.id.split('-').first;
      }
    } catch (_) {}

    emit(state.copyWith(destino: query, claveBase: posibleClave));

    // Cancelar cualquier búsqueda pendiente
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _autoSave(); // 💾
  }

  void registrarNuevaClaveMock(String clave, String destino, LatLng location) {
    final cleanClave = clave.trim().toUpperCase();
    // Creamos un viaje dummy solo para afectar el historial de claves y "guardarla" en memoria
    final fakeViaje = Viaje(
      id: '$cleanClave-00', // El "00" indica que es una clave base/plantilla
      destino: destino,
      estado: 'PLANTILLA',
      fechaInicio: DateTime.now(),
      fechaFin: DateTime.now(),
      turistas: 0,
      latitud: location.latitude,
      longitud: location.longitude,
      guiaNombre: 'N/A',
      horaInicio: '--:--',
      alertasActivas: 0,
      itinerario: const [],
    );
    _allViajes.add(fakeViaje);

    // Forzar actualización de UI si es necesario
    emit(state.copyWith());
  }

  void onClaveBaseChanged(String clave) {
    final cleanClave = clave.trim().toUpperCase();

    // Si el usuario ingresa una clave, buscamos si ya existe en el historial
    String? destinoSugerido = state.destino;
    LatLng? locationSugerida = state.location;
    bool foundExisting = false;

    try {
      final viajePrevio = _allViajes.firstWhere(
        (v) => v.id.startsWith('$cleanClave-'),
      );
      destinoSugerido = viajePrevio.destino;
      locationSugerida = LatLng(viajePrevio.latitud, viajePrevio.longitud);
      foundExisting = true;
    } catch (_) {}

    emit(
      state.copyWith(
        claveBase: cleanClave,
        destino: destinoSugerido,
        location: locationSugerida,
      ),
    );

    // ✨ ¡Importante! Si la clave ya existía, disparar también la búsqueda de fotos
    if (foundExisting &&
        destinoSugerido != null &&
        destinoSugerido.isNotEmpty) {
      _repository
          .buscarFotosDestino(destinoSugerido)
          .then((fotos) {
            if (fotos.isNotEmpty) {
              emit(state.copyWith(fotosCandidatas: fotos));
              if (state.fotoPortadaUrl == null ||
                  (state.fotoPortadaUrl?.contains('mapbox') ?? false)) {
                emit(state.copyWith(fotoPortadaUrl: fotos.first));
              }
            }
          })
          .catchError((_) {});
    }

    _autoSave();
  }

  // Validación Cruzada de Clave vs Destino
  String? get claveError {
    if (state.claveBase == null || state.claveBase!.isEmpty) return null;
    if (state.destino.isEmpty) return null;

    final cleanClave = state.claveBase!.trim().toUpperCase();
    final cleanDestino = state.destino.trim().toLowerCase();

    // 1. ¿Esta clave ya se usa para OTRO destino?
    try {
      final viajeMismaClave = _allViajes.firstWhere(
        (v) => v.id.startsWith('$cleanClave-'),
      );
      if (viajeMismaClave.destino.trim().toLowerCase() != cleanDestino) {
        return 'La clave $cleanClave ya pertenece a ${viajeMismaClave.destino}';
      }
    } catch (_) {}

    // 2. ¿Este destino ya usa OTRA clave?
    try {
      final viajeMismoDestino = _allViajes.firstWhere(
        (v) => v.destino.trim().toLowerCase() == cleanDestino,
      );
      final claveOriginal = viajeMismoDestino.id.split('-').first;
      if (claveOriginal != cleanClave) {
        return 'Este destino ya utiliza la clave $claveOriginal';
      }
    } catch (_) {}

    return null;
  }

  // Historial de claves únicas para autocompletado
  List<Map<String, String>> get clavesHistorial {
    final Map<String, String> unicas = {};
    for (final viaje in _allViajes) {
      if (viaje.id.contains('-')) {
        final clave = viaje.id.split('-').first;
        if (!unicas.containsKey(clave)) {
          unicas[clave] = viaje.destino;
        }
      }
    }
    return unicas.entries
        .map((e) => {'clave': e.key, 'destino': e.value})
        .toList();
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
  // Las horas de inicio/fin reales serán derivadas de las actividades al guardar.
  Viaje get viajeTemporal {
    final inicioDateTime = DateTime(
      state.fechaInicio!.year,
      state.fechaInicio!.month,
      state.fechaInicio!.day,
      0,
      0,
    );

    final finDateBase = state.isMultiDay ? state.fechaFin! : state.fechaInicio!;
    final finDateTime = DateTime(
      finDateBase.year,
      finDateBase.month,
      finDateBase.day,
      23,
      59,
    );

    // Generar ID iterativo
    String finalId = const Uuid().v4();
    if (state.claveBase != null && state.claveBase!.isNotEmpty) {
      final cleanClave = state.claveBase!.trim().toUpperCase();
      final conteo =
          _allViajes.where((v) => v.id.startsWith('$cleanClave-')).length;
      final iterador = (conteo + 1).toString().padLeft(2, '0');
      finalId = '$cleanClave-$iterador';
    }

    return Viaje(
      id: finalId,
      destino: state.destino,
      estado: 'PROGRAMADO',
      fechaInicio: inicioDateTime,
      fechaFin: finDateTime,
      turistas: 0,
      latitud: state.location?.latitude ?? 0.0,
      longitud: state.location?.longitude ?? 0.0,
      guiaNombre: _getNombreGuia(state.selectedGuiaId),
      horaInicio: '--:--',
      alertasActivas: 0,
      itinerario: const [],
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
      // Reemplazamos el destino completamente por lo que dice el mapa interactivo
      nuevoNombre = nombreSugerido;
      terminoBusqueda = nombreSugerido;
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
    final bool tieneNombre = state.destino.trim().isNotEmpty;
    final bool tieneUbicacion = state.location != null;
    final bool tieneGuia = state.selectedGuiaId != null;
    final bool tieneFechaInicio = state.fechaInicio != null;
    final bool tieneClave =
        state.claveBase != null && state.claveBase!.trim().isNotEmpty;
    final bool claveSinError = claveError == null;

    bool fechasValidas = true;
    if (state.isMultiDay) {
      // Multi-día: debe tener fecha fin Y fechaFin > fechaInicio
      if (state.fechaFin == null) {
        fechasValidas = false;
      } else {
        fechasValidas = state.fechaFin!.isAfter(state.fechaInicio!);
      }
    }

    return tieneNombre &&
        tieneUbicacion &&
        tieneGuia &&
        tieneFechaInicio &&
        tieneClave &&
        claveSinError &&
        fechasValidas;
  }

  void toggleMultiDay(bool value) {
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
        fechaInicio: null,
        fechaFin: null,
      ),
    );
    _autoSave();
  }

  void searchGuia(String query) => emit(state.copyWith(searchQueryGuia: query));

  /// Establece la fecha de inicio.
  /// Si la nueva fecha es posterior a fechaFin → resetea fechaFin.
  void setFechaInicio(DateTime nuevaFecha) {
    DateTime? nuevaFechaFin = state.fechaFin;
    if (state.fechaFin != null && nuevaFecha.isAfter(state.fechaFin!)) {
      nuevaFechaFin = null;
    }

    // ✅ Usar copyWith para preservar TODOS los campos (incluyendo claveBase)
    emit(state.copyWith(fechaInicio: nuevaFecha, fechaFin: nuevaFechaFin));
    _autoSave();
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
    if (state.isMultiDay) {
      if (state.fechaFin == null) return false;
      if (state.fechaFin!.isBefore(state.fechaInicio!)) return false;
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
    _unsavedChangesService.setDirty(false); // 📝 Guardado exitoso = Limpio
  }

  void seleccionarFoto(String url) {
    emit(state.copyWith(fotoPortadaUrl: url));
    _autoSave(); // 💾 Guardar selección
  }
}
