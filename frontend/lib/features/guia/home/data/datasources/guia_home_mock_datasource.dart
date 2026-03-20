import 'package:frontend/features/guia/trips/data/models/ActividadItinerarioModel.dart';
import '../../domain/entities/agencia_home_data.dart';
import '../../domain/entities/personal_home_data.dart';
import 'guia_home_remote_datasource.dart';
export 'guia_home_remote_datasource.dart'; // Exportado para que el locator de GitHub lo encuentre sin modificarlo

// IMPORTANTE: Importamos el modelo desde la carpeta de trips para seguir la arquitectura
class GuiaHomeMockDataSource implements GuiaHomeRemoteDataSource {
  @override
  Future<AgenciaHomeData> getAgenciaHomeData(String folio) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return AgenciaHomeData(
      nombreViaje: 'Tour Teotihuacán 2026',
      folio: folio,
      destino: 'Teotihuacán, Estado de México',
      totalParticipantes: 24,
      geocercaRadio: '300 m · Zona Arqueológica',
      participantes: const [
        Participante(
          nombre: 'María García',
          estado: EstadoParticipante.sincronizado,
        ),
        Participante(
          nombre: 'Carlos López',
          estado: EstadoParticipante.sincronizado,
        ),
        Participante(
          nombre: 'Ana Martínez',
          estado: EstadoParticipante.offline,
        ),
        Participante(
          nombre: 'Roberto Silva',
          estado: EstadoParticipante.sincronizado,
        ),
        Participante(
          nombre: 'Sofía Ramírez',
          estado: EstadoParticipante.alerta,
        ),
        Participante(
          nombre: 'Luis Hernández',
          estado: EstadoParticipante.sincronizado,
        ),
        Participante(
          nombre: 'Paola Torres',
          estado: EstadoParticipante.offline,
        ),
      ],
      historialAlertas: const [
        AlertaHistorial(
          descripcion: 'Ana Martínez salió de geocerca',
          hora: '09:42',
        ),
        AlertaHistorial(
          descripcion: 'Sofía Ramírez: batería crítica (<10%)',
          hora: '10:15',
        ),
        AlertaHistorial(
          descripcion: 'Paola Torres sin señal GPS',
          hora: '11:03',
        ),
      ],
    );
  }

  @override
  Future<PersonalHomeData> getPersonalHomeData(String nombreGuia) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return PersonalHomeData(
      nombreGuia: nombreGuia,
      nombreViaje: 'Ruta Mazunte – Costa Oaxaqueña',
      destino: 'Puerto Escondido, Oaxaca',
      horaInicio: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        8,
        0,
      ),
      participantes: 12,
      kmRecorridos: 14.3,
      minActivos: 187,
      altitudActualM: 42,
      huellaCarbono: 3.7,
      geocercaMetros: 200,
      contactos: const [
        ContactoEmergencia(
          nombre: 'Elena Morales',
          relacion: 'Esposa',
          telefono: '722 100 2030',
        ),
        ContactoEmergencia(
          nombre: 'Javier Cruz',
          relacion: 'Hermano',
          telefono: '55 8800 1122',
        ),
        ContactoEmergencia(
          nombre: 'SEDENA Región',
          relacion: 'Autoridad',
          telefono: '800 900 0000',
        ),
      ],
      // CAMBIO CLAVE: Usamos ActividadItinerarioModel para incluir descripción y punto de reunión
      actividades: [
        // DÍA 1 (Hoy)
        ActividadItinerarioModel(
          nombre: 'Salida del hotel Barcelo',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            8,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            8,
            30,
          ),
          completada: true,
          descripcion:
              'Reunión en el lobby para el pase de lista inicial y entrega de pulseras de identificación.',
          puntoReunion: 'Lobby Hotel Selina Mazunte',
        ),
        ActividadItinerarioModel(
          nombre: 'Snorkel en Punta Zicatela',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            9,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            11,
            0,
          ),
          completada: true,
          descripcion:
              'Actividad de nado con tortugas. Es obligatorio el uso de chaleco salvavidas y equipo de snorkel.',
          puntoReunion: 'Muelle principal de Zicatela',
        ),
        ActividadItinerarioModel(
          nombre: 'Almuerzo en Restaurante Playa',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            12,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            13,
            30,
          ),
          completada: false,
          descripcion:
              'Menú degustación de mariscos locales. Favor de avisar por alergias a mariscos.',
          puntoReunion: 'Restaurante "El Galeón" (Frente a la playa)',
        ),
        ActividadItinerarioModel(
          nombre: 'Visita Barra de Navidad',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            14,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            16,
            0,
          ),
          completada: false,
          descripcion:
              'Caminata guiada por la reserva natural y tiempo libre para toma de fotografías.',
          puntoReunion: 'Entrada de la Reserva Natural',
        ),
        ActividadItinerarioModel(
          nombre: 'Taller de conservación',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            16,
            30,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            17,
            30,
          ),
          completada: false,
          descripcion:
              'Plática educativa sobre la protección de tortugas marinas.',
          puntoReunion: 'Centro Mexicano de la Tortuga',
        ),
        ActividadItinerarioModel(
          nombre: 'Tiempo libre para compras',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            17,
            30,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            18,
            30,
          ),
          completada: false,
          descripcion:
              'Recorrido por las tiendas locales de recuerdos y artesanías.',
          puntoReunion: 'Andador turístico',
        ),
        ActividadItinerarioModel(
          nombre: 'Cena en la playa',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            19,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            20,
            30,
          ),
          completada: false,
          descripcion: 'Cena al aire libre con vista al mar.',
          puntoReunion: 'Terraza del Hotel',
        ),
        ActividadItinerarioModel(
          nombre: 'Caminata nocturna',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            21,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            22,
            0,
          ),
          completada: false,
          descripcion: 'Recorrido para observar fauna nocturna en la costa.',
          puntoReunion: 'Muelle principal',
        ),
        ActividadItinerarioModel(
          nombre: 'Cierre de actividades (D1)',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            22,
            30,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            23,
            0,
          ),
          completada: false,
          descripcion:
              'Breve reunión para revisar la agenda del día siguiente.',
          puntoReunion: 'Lobby del Hotel',
        ),
        // DÍA 2 (Mañana)
        ActividadItinerarioModel(
          nombre: 'Día libre en la bahía',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            9,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            14,
            0,
          ),
          completada: false,
          descripcion:
              'Tiempo libre para explorar la bahía, compras locales y relajación.',
          puntoReunion: 'Bahía principal',
        ),
        ActividadItinerarioModel(
          nombre: 'Taller de artesanías',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            16,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            18,
            0,
          ),
          completada: false,
          descripcion:
              'Taller interactivo creando artesanías locales con materiales reciclados.',
          puntoReunion: 'Centro Comunitario',
        ),
        ActividadItinerarioModel(
          nombre: 'Cena de especialidades oaxaqueñas',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            19,
            30,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            21,
            30,
          ),
          completada: false,
          descripcion:
              'Degustación de platillos tradicionales típicos de la región.',
          puntoReunion: 'Restaurante "Los Magueyes"',
        ),
        // DÍA 3
        ActividadItinerarioModel(
          nombre: 'Tour en bote por los manglares',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 2,
            7,
            30,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 2,
            10,
            30,
          ),
          completada: false,
          descripcion:
              'Avistamiento de aves y cocodrilos en su hábitat natural.',
          puntoReunion: 'Muelle de la laguna',
        ),
        ActividadItinerarioModel(
          nombre: 'Almuerzo campestre',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 2,
            13,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 2,
            14,
            30,
          ),
          completada: false,
          descripcion: 'Comida tipo picnic en un área reservada.',
          puntoReunion: 'Área de picnic Las Palmas',
        ),
        ActividadItinerarioModel(
          nombre: 'Tarde de fogata y leyendas',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 2,
            19,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 2,
            21,
            30,
          ),
          completada: false,
          descripcion:
              'Reunión al atardecer en la playa con fogata, bombones y leyendas locales.',
          puntoReunion: 'Playa principal, zona sur',
        ),
        // DÍA 4
        ActividadItinerarioModel(
          nombre: 'Caminata hacia el Mirador',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 3,
            6,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 3,
            9,
            0,
          ),
          completada: false,
          descripcion:
              'Senderismo ligero tempranero para ver el amanecer desde el punto más alto de la costa.',
          puntoReunion: 'Lobby del Hotel',
        ),
        ActividadItinerarioModel(
          nombre: 'Desayuno de despedida',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 3,
            9,
            30,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 3,
            11,
            0,
          ),
          completada: false,
          descripcion: 'Desayuno especial de fin de tour.',
          puntoReunion: 'Restaurante del Hotel',
        ),
        ActividadItinerarioModel(
          nombre: 'Regreso a Ciudad de Origen',
          horaInicio: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 3,
            12,
            0,
          ),
          horaFin: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 3,
            15,
            0,
          ),
          completada: false,
          descripcion:
              'Traslado al aeropuerto o terminal de autobuses para el regreso.',
          puntoReunion: 'Lobby del Hotel',
        ),
      ],
      listaTuristas: [
        const Turista(
          id: 't_001',
          nombre: 'María García',
          viajeId: 'v_mazunte',
          status: 'OK',
          bateria: 0.92,
          enCampo: true,
        ),
        const Turista(
          id: 't_002',
          nombre: 'Carlos López',
          viajeId: 'v_mazunte',
          status: 'OK',
          bateria: 0.85,
          enCampo: true,
        ),
        const Turista(
          id: 't_003',
          nombre: 'Ana Martínez',
          viajeId: 'v_mazunte',
          status: 'OFFLINE',
          bateria: 0.15,
          enCampo: false,
        ),
        const Turista(
          id: 't_004',
          nombre: 'Roberto Silva',
          viajeId: 'v_mazunte',
          status: 'OK',
          bateria: 0.78,
          enCampo: true,
        ),
        const Turista(
          id: 't_005',
          nombre: 'Sofía Ramírez',
          viajeId: 'v_mazunte',
          status: 'ADVERTENCIA',
          bateria: 0.08,
          enCampo: true,
          vulnerabilidad: NivelVulnerabilidad.critica,
        ),
        const Turista(
          id: 't_006',
          nombre: 'Luis Hernández',
          viajeId: 'v_mazunte',
          status: 'OK',
          bateria: 0.95,
          enCampo: true,
        ),
        const Turista(
          id: 't_007',
          nombre: 'Paola Torres',
          viajeId: 'v_mazunte',
          status: 'OFFLINE',
          bateria: 0.0,
          enCampo: false,
        ),
        const Turista(
          id: 't_008',
          nombre: 'Fernando Castillo',
          viajeId: 'v_mazunte',
          status: 'OK',
          bateria: 0.67,
          enCampo: true,
        ),
        const Turista(
          id: 't_009',
          nombre: 'Diana Reyes',
          viajeId: 'v_mazunte',
          status: 'OK',
          bateria: 0.88,
          enCampo: true,
        ),
        const Turista(
          id: 't_010',
          nombre: 'Alejandro Magno',
          viajeId: 'v_mazunte',
          status: 'OK',
          bateria: 0.72,
          enCampo: true,
        ),
        const Turista(
          id: 't_011',
          nombre: 'Beatriz Pinzón',
          viajeId: 'v_mazunte',
          status: 'ADVERTENCIA',
          bateria: 0.30,
          enCampo: true,
          vulnerabilidad: NivelVulnerabilidad.critica,
        ),
        const Turista(
          id: 't_012',
          nombre: 'Gabriel García',
          viajeId: 'v_mazunte',
          status: 'OK',
          bateria: 0.55,
          enCampo: true,
        ),
      ],
    );
  }
}
