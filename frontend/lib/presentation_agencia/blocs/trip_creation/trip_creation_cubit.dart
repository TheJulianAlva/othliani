import 'package:flutter/material.dart'; // Para TimeOfDay
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/actividad_itinerario.dart';

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

  // Listas simuladas para los selectores (En app real vendrían de otro Bloc)
  final List<Map<String, dynamic>> availableGuides;

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
    this.availableGuides = const [
      {'id': 'gui-01', 'name': 'Marcos R.', 'status': 'Disponible'},
      {'id': 'gui-02', 'name': 'Ana G.', 'status': 'Ocupado'},
      {'id': 'gui-03', 'name': 'Pedro S.', 'status': 'Disponible'},
      {'id': 'gui-04', 'name': 'Sofia L.', 'status': 'Disponible'},
      {'id': 'gui-05', 'name': 'Carlos M.', 'status': 'Ocupado'},
    ],
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
      availableGuides: availableGuides,
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
  ];
}

// --- CUBIT ---
class TripCreationCubit extends Cubit<TripCreationState> {
  TripCreationCubit() : super(const TripCreationState());

  void updateBasicInfo(String destino, DateTime? inicio, DateTime? fin) {
    emit(state.copyWith(destino: destino, fechaInicio: inicio, fechaFin: fin));
  }

  void setGuia(String? id) => emit(state.copyWith(selectedGuiaId: id));

  void setLocation(LatLng loc) => emit(state.copyWith(location: loc));

  void toggleMultiDay(bool value) => emit(state.copyWith(isMultiDay: value));

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

  void nextStep() {
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
}
