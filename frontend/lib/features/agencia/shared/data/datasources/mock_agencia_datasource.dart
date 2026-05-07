import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';
import 'package:frontend/features/agencia/users/domain/entities/guia.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';
import 'package:frontend/features/agencia/shared/domain/entities/alerta.dart';
import 'package:frontend/features/agencia/audit/domain/entities/log_auditoria.dart';

class MockAgenciaDataSource {
  static final MockAgenciaDataSource _instance =
      MockAgenciaDataSource._internal();
  factory MockAgenciaDataSource() => _instance;

  // --- 1. LISTA DE GUÍAS (Usando Entity Guia) ---
  final List<Guia> _guias = [
    // 🔵 GUÍAS EN_RUTA (3) - Viajes activos EN_CURSO
    const Guia(
      id: 'G-01',
      nombre: 'Marcos Ruiz',
      status: 'EN_VIAJE',
      rol: 'Guía Líder',
      diasTrabajoMes: 15,
      csat: 4.5,
      totalReviews: 28,
      proxViaje: 'Nevado de Toluca',
    ),
    const Guia(
      id: 'G-02',
      nombre: 'Pedro Sánchez',
      status: 'EN_VIAJE',
      rol: 'Guía Senior',
      diasTrabajoMes: 12,
      csat: 4.2,
      totalReviews: 15,
      proxViaje: 'Chignahuapan',
    ),
    const Guia(
      id: 'G-03',
      nombre: 'Ana Paula G.',
      status: 'EN_VIAJE',
      rol: 'Coordinadora',
      diasTrabajoMes: 10,
      csat: 4.9,
      totalReviews: 42,
      proxViaje: 'Taxco',
    ),

    // 📅 GUÍAS CON VIAJES PROGRAMADOS (4)
    const Guia(
      id: 'G-04',
      nombre: 'Carlos Vega',
      status: 'ONLINE',
    ),

    const Guia(
      id: 'G-05',
      nombre: 'Luisa Lane',
      status: 'ONLINE',
    ),

    const Guia(
      id: 'G-06',
      nombre: 'Roberto Gómez',
      status: 'ONLINE',
    ),

    const Guia(
      id: 'G-07',
      nombre: 'María López',
      status: 'ONLINE',
    ),


    // ✅ GUÍAS DISPONIBLES (2) - ONLINE sin viajes
    const Guia(
      id: 'G-08',
      nombre: 'Jorge T.',
      status: 'ONLINE',
    ),

    const Guia(
      id: 'G-09',
      nombre: 'Elena M.',
      status: 'ONLINE',
    ),


    // ⚫ GUÍA OFFLINE (1)
    const Guia(
      id: 'G-10',
      nombre: 'Sofia R.',
      status: 'OFFLINE',
    ),

  ];

  // --- 2. LISTA DE VIAJES (Usando Entity Viaje con fechas dinámicas) ---
  // Definimos "HOY" para calcular todo relativo a este momento
  final DateTime _hoy = DateTime.now();

  // Usamos 'late' para inicializar con _hoy
  late final List<Viaje> _viajes;

  MockAgenciaDataSource._internal() {
    // Inicializamos viajes con fechas dinámicas
    _viajes = [
      // 🟢 Viajes EN CURSO - VIAJES CORTOS (Mismo día, 6-8 horas)
      Viaje(
        id: 'MEX-01',
        destino: 'Centro Histórico CDMX',
        estado: 'EN_CURSO',
        // Inició hace 2 horas, termina en 4 horas (6 horas total)
        fechaInicio: _hoy.subtract(const Duration(hours: 2)),
        fechaFin: _hoy.add(const Duration(hours: 4)),
        turistas: 15,
        latitud: 19.4326,
        longitud: -99.1332,
        guiaNombre: 'Marcos Ruiz',
        horaInicio: '09:00 AM',
        alertasActivas: 1,
        tipoViaje: TipoViaje.agencia,
        coGuiasIds: ['G-02', 'G-03'], // Pedro Sánchez y Ana Paula como co-guías
        tipoGrupo: TipoGrupo.familiar,
      ),
      Viaje(
        id: 'MEX-02',
        destino: 'Zona Montañosa - Desierto de los Leones',
        estado: 'EN_CURSO',
        // Inició hace 3 horas, termina en 5 horas (8 horas total)
        fechaInicio: _hoy.subtract(const Duration(hours: 3)),
        fechaFin: _hoy.add(const Duration(hours: 5)),
        turistas: 8,
        latitud: 19.3117,
        longitud: -99.3147,
        guiaNombre: 'Pedro Sánchez',
        horaInicio: '08:30 AM',
        alertasActivas: 2,
        tipoViaje: TipoViaje.personal, // B2C: guía independiente
        contactosConfianza: [
          ContactoConfianza(
            nombre: 'María Sánchez', // esposa
            telefono: '+52 55 9876 5432',
          ),
          ContactoConfianza(
            nombre: 'Carlos Sánchez', // hermano
            telefono: '+52 55 1111 2222',
          ),
        ],
        tipoGrupo: TipoGrupo.aventuraAdultos,
      ),
      Viaje(
        id: 'MEX-03',
        destino: 'Teotihuacán',
        estado: 'EN_CURSO',
        // Inició hace 4 horas, termina en 3 horas (7 horas total)
        fechaInicio: _hoy.subtract(const Duration(hours: 4)),
        fechaFin: _hoy.add(const Duration(hours: 3)),
        turistas: 40,
        latitud: 19.6925,
        longitud: -98.8439,
        guiaNombre: 'Ana Paula G.',
        horaInicio: '07:00 AM',
        alertasActivas: 1, // Luis P. alejado
        tipoViaje: TipoViaje.agencia,
        coGuiasIds: ['G-08'], // Jorge T. como co-guía de espera
        tipoGrupo: TipoGrupo.escolar,
      ),

      // 🔵 Viajes PROGRAMADOS - VIAJES LARGOS (Multi-día, 2-3 días)
      Viaje(
        id: 'TOL-01',
        destino: 'Nevado de Toluca (Campamento)',
        estado: 'PROGRAMADO',
        // Empieza mañana a las 8 AM, termina pasado mañana a las 6 PM (3 días)
        fechaInicio: DateTime(_hoy.year, _hoy.month, _hoy.day + 1, 8, 0),
        fechaFin: DateTime(_hoy.year, _hoy.month, _hoy.day + 3, 18, 0),
        turistas: 12,
        latitud: 19.108,
        longitud: -99.759,
        guiaNombre: 'Carlos Vega',
        horaInicio: 'Mañana 06:00 AM',
        alertasActivas: 0,
      ),
      Viaje(
        id: 'VBR-01',
        destino: 'Valle de Bravo (Fin de Semana)',
        estado: 'PROGRAMADO',
        // Empieza en 2 días a las 9 AM, termina en 4 días a las 5 PM (2 días)
        fechaInicio: DateTime(_hoy.year, _hoy.month, _hoy.day + 2, 9, 0),
        fechaFin: DateTime(_hoy.year, _hoy.month, _hoy.day + 4, 17, 0),
        turistas: 8,
        latitud: 19.192,
        longitud: -100.131,
        guiaNombre: 'Luisa Lane',
        horaInicio: 'En 2 días',
        alertasActivas: 0,
      ),
      Viaje(
        id: 'XOC-01',
        destino: 'Xochimilco',
        estado: 'PROGRAMADO',
        // Viaje corto programado: En 5 días, 6 horas
        fechaInicio: DateTime(_hoy.year, _hoy.month, _hoy.day + 5, 10, 0),
        fechaFin: DateTime(_hoy.year, _hoy.month, _hoy.day + 5, 16, 0),
        turistas: 20,
        latitud: 19.295,
        longitud: -99.099,
        guiaNombre: 'Roberto Gómez',
        horaInicio: 'Sábado 10:00 AM',
        alertasActivas: 0,
      ),
      Viaje(
        id: 'TEP-01',
        destino: 'Tepoztlán',
        estado: 'PROGRAMADO',
        // Viaje corto programado: En 6 días, 7 horas
        fechaInicio: DateTime(_hoy.year, _hoy.month, _hoy.day + 6, 8, 0),
        fechaFin: DateTime(_hoy.year, _hoy.month, _hoy.day + 6, 15, 0),
        turistas: 10,
        latitud: 18.986,
        longitud: -99.100,
        guiaNombre: 'María López',
        horaInicio: 'Domingo 08:00 AM',
        alertasActivas: 0,
      ),
      Viaje(
        id: 'TAX-01',
        destino: 'Taxco (Expedición)',
        estado: 'PROGRAMADO',
        // Viaje largo programado: En 7 días, 3 días de duración
        fechaInicio: DateTime(_hoy.year, _hoy.month, _hoy.day + 7, 7, 0),
        fechaFin: DateTime(_hoy.year, _hoy.month, _hoy.day + 10, 19, 0),
        turistas: 15,
        latitud: 18.556,
        longitud: -99.605,
        guiaNombre: 'Sin asignar',
        horaInicio: 'Próxima semana',
        alertasActivas: 0,
      ),

      // ⚫ Viajes FINALIZADOS - Fechas PASADAS
      Viaje(
        id: 'SUM-01',
        destino: 'Cañón del Sumidero',
        estado: 'FINALIZADO',
        // Empezó ayer a las 7 AM, terminó ayer a las 8 PM (13 horas)
        fechaInicio: DateTime(_hoy.year, _hoy.month, _hoy.day - 1, 7, 0),
        fechaFin: DateTime(_hoy.year, _hoy.month, _hoy.day - 1, 20, 0),
        turistas: 25,
        latitud: 16.835,
        longitud: -93.033,
        guiaNombre: 'Jorge Ramírez',
        horaInicio: 'Hace 3 horas',
        alertasActivas: 0, // Sin incidentes
      ),
    ];
  }

  // --- 3. LISTA DE TURISTAS (Población Real) ---
  final List<Turista> _turistas = [
    // --- Grupo Viaje 204 (15 pax) ---
    // Turista Problemático (SOS)
    const Turista(
      id: 'T-01',
      nombre: 'Ana Gómez',
      viajeId: 'MEX-01',
      status: 'SOS',
      bateria: 0.15,
      enCampo: true,
    ),
    // Turistas Normales
    const Turista(
      id: 'T-02',
      nombre: 'Juan Pérez',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.90,
      enCampo: true,
    ),
    const Turista(
      id: 'T-03',
      nombre: 'Carla M.',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.85,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04',
      nombre: 'Luis R.',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.88,
      enCampo: true,
    ),
    // Rellenos para completar los 15 del viaje 204
    const Turista(
      id: 'T-04-5',
      nombre: 'Turista 204-5',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-6',
      nombre: 'Turista 204-6',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-7',
      nombre: 'Turista 204-7',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-8',
      nombre: 'Turista 204-8',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-9',
      nombre: 'Turista 204-9',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-10',
      nombre: 'Turista 204-10',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-11',
      nombre: 'Turista 204-11',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-12',
      nombre: 'Turista 204-12',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-13',
      nombre: 'Turista 204-13',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-14',
      nombre: 'Turista 204-14',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-15',
      nombre: 'Turista 204-15',
      viajeId: 'MEX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),

    // --- Grupo Viaje 205 (8 pax) - Zona Montañosa ---
    const Turista(
      id: 'T-205-01',
      nombre: 'Roberto Sánchez',
      viajeId: 'MEX-02',
      status: 'OK',
      bateria: 0.25,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-02',
      nombre: 'María López',
      viajeId: 'MEX-02',
      status: 'OK',
      bateria: 0.30,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-03',
      nombre: 'Carlos Mendoza',
      viajeId: 'MEX-02',
      status: 'OK',
      bateria: 0.40,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-04',
      nombre: 'Laura Fernández',
      viajeId: 'MEX-02',
      status: 'OK',
      bateria: 0.35,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-05',
      nombre: 'Diego Torres',
      viajeId: 'MEX-02',
      status: 'OK',
      bateria: 0.28,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-06',
      nombre: 'Patricia Ruiz',
      viajeId: 'MEX-02',
      status: 'OK',
      bateria: 0.32,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-07',
      nombre: 'Fernando García',
      viajeId: 'MEX-02',
      status: 'OK',
      bateria: 0.27,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-08',
      nombre: 'Sofía Morales',
      viajeId: 'MEX-02',
      status: 'ADVERTENCIA', // ← CORREGIDO: Para que salga amarillo
      bateria: 0.22,
      enCampo: true,
    ),

    // --- Grupo Viaje 110 (40 pax) ---
    // Turista con Advertencia (Alejamiento)
    const Turista(
      id: 'T-110-01',
      nombre: 'Luis P.',
      viajeId: 'MEX-03',
      status: 'ADVERTENCIA',
      bateria: 0.30,
      enCampo: true,
    ),
    // Relleno
    const Turista(
      id: 'T-110-2',
      nombre: 'Turista 110-2',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-3',
      nombre: 'Turista 110-3',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-4',
      nombre: 'Turista 110-4',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-5',
      nombre: 'Turista 110-5',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-6',
      nombre: 'Turista 110-6',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-7',
      nombre: 'Turista 110-7',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-8',
      nombre: 'Turista 110-8',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-9',
      nombre: 'Turista 110-9',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-10',
      nombre: 'Turista 110-10',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-11',
      nombre: 'Turista 110-11',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-12',
      nombre: 'Turista 110-12',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-13',
      nombre: 'Turista 110-13',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-14',
      nombre: 'Turista 110-14',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-15',
      nombre: 'Turista 110-15',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-16',
      nombre: 'Turista 110-16',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-17',
      nombre: 'Turista 110-17',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-18',
      nombre: 'Turista 110-18',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-19',
      nombre: 'Turista 110-19',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-20',
      nombre: 'Turista 110-20',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-21',
      nombre: 'Turista 110-21',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-22',
      nombre: 'Turista 110-22',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-23',
      nombre: 'Turista 110-23',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-24',
      nombre: 'Turista 110-24',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-25',
      nombre: 'Turista 110-25',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-26',
      nombre: 'Turista 110-26',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-27',
      nombre: 'Turista 110-27',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-28',
      nombre: 'Turista 110-28',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-29',
      nombre: 'Turista 110-29',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-30',
      nombre: 'Turista 110-30',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-31',
      nombre: 'Turista 110-31',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-32',
      nombre: 'Turista 110-32',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-33',
      nombre: 'Turista 110-33',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-34',
      nombre: 'Turista 110-34',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-35',
      nombre: 'Turista 110-35',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-36',
      nombre: 'Turista 110-36',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-37',
      nombre: 'Turista 110-37',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-38',
      nombre: 'Turista 110-38',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-39',
      nombre: 'Turista 110-39',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-40',
      nombre: 'Turista 110-40',
      viajeId: 'MEX-03',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),

    // --- Turistas Offline (Sin red, pero en campo) ---
    // COMENTADO PARA CUADRAR KPI: Suman 3 extra y dan 66 en vez de 63.
    /*
    const Turista(
      id: 'T-OFF-1',
      nombre: 'Pepe L.',
      viajeId: 'MEX-01',
      status: 'OFFLINE',
      bateria: 0.50,
      enCampo: true,
    ),
    const Turista(
      id: 'T-OFF-2',
      nombre: 'Maria S.',
      viajeId: 'MEX-03',
      status: 'OFFLINE',
      bateria: 0.40,
      enCampo: true,
    ),
    const Turista(
      id: 'T-OFF-3',
      nombre: 'Jose K.',
      viajeId: 'MEX-03',
      status: 'OFFLINE',
      bateria: 0.20,
      enCampo: true,
    ),
    */

    // --- Grupo Viaje 305: Nevado de Toluca (12 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-305-01',
      nombre: 'Roberto Martínez',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 1.0,
      enCampo: false,
      // Datos de logística
      tipoSangre: 'O+',
      alergias: 'Penicilina',
      condicionesMedicas: 'Ninguna',
      contactoEmergenciaNombre: 'María Martínez',
      contactoEmergenciaParentesco: 'Esposa',
      contactoEmergenciaTelefono: '+52 55 1234 5678',
      appInstalada: true,
      pagoCompletado: true,
      responsivaFirmada: true,
    ),
    const Turista(
      id: 'T-305-02',
      nombre: 'Sandra López',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.98,
      enCampo: false,
      // Datos de logística
      tipoSangre: 'A+',
      alergias: 'Ninguna',
      condicionesMedicas: 'Asma leve',
      contactoEmergenciaNombre: 'Carlos López',
      contactoEmergenciaParentesco: 'Hermano',
      contactoEmergenciaTelefono: '+52 55 9876 5432',
      appInstalada: true,
      pagoCompletado: true,
      responsivaFirmada: false,
    ),
    const Turista(
      id: 'T-305-03',
      nombre: 'Miguel Ángel Torres',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-04',
      nombre: 'Patricia Hernández',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-05',
      nombre: 'Fernando García',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-06',
      nombre: 'Laura Ramírez',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-07',
      nombre: 'Javier Sánchez',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.85,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-08',
      nombre: 'Gabriela Morales',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-09',
      nombre: 'Ricardo Flores',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-10',
      nombre: 'Daniela Castro',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-11',
      nombre: 'Alberto Mendoza',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-12',
      nombre: 'Verónica Silva',
      viajeId: 'TOL-01',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),

    // --- Grupo Viaje 306: Valle de Bravo (8 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-306-01',
      nombre: 'Andrés Gutiérrez',
      viajeId: 'VBR-01',
      status: 'OK',
      bateria: 1.0,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-02',
      nombre: 'Carolina Vargas',
      viajeId: 'VBR-01',
      status: 'OK',
      bateria: 0.96,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-03',
      nombre: 'Diego Rojas',
      viajeId: 'VBR-01',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-04',
      nombre: 'Mariana Ortiz',
      viajeId: 'VBR-01',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-05',
      nombre: 'Pablo Reyes',
      viajeId: 'VBR-01',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-06',
      nombre: 'Sofía Jiménez',
      viajeId: 'VBR-01',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-07',
      nombre: 'Héctor Medina',
      viajeId: 'VBR-01',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-08',
      nombre: 'Valeria Cruz',
      viajeId: 'VBR-01',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),

    // --- Grupo Viaje 307: Xochimilco (20 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-307-01',
      nombre: 'Alejandro Ruiz',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 1.0,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-02',
      nombre: 'Beatriz Navarro',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.97,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-03',
      nombre: 'César Domínguez',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-04',
      nombre: 'Diana Peña',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-05',
      nombre: 'Eduardo Vega',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-06',
      nombre: 'Fernanda Ríos',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-07',
      nombre: 'Gustavo Paredes',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-08',
      nombre: 'Helena Campos',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-09',
      nombre: 'Ignacio Salazar',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.86,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-10',
      nombre: 'Julia Cortés',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-11',
      nombre: 'Kevin Aguilar',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-12',
      nombre: 'Liliana Fuentes',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-13',
      nombre: 'Manuel Estrada',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-14',
      nombre: 'Natalia Herrera',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.96,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-15',
      nombre: 'Óscar Delgado',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.85,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-16',
      nombre: 'Paola Montes',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-17',
      nombre: 'Raúl Castillo',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-18',
      nombre: 'Silvia Ramos',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-19',
      nombre: 'Tomás Ibarra',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-20',
      nombre: 'Úrsula Molina',
      viajeId: 'XOC-01',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),

    // --- Grupo Viaje 308: Tepoztlán (10 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-308-01',
      nombre: 'Vicente Acosta',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 1.0,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-02',
      nombre: 'Wendy Pacheco',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-03',
      nombre: 'Xavier Núñez',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-04',
      nombre: 'Yolanda Bravo',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-05',
      nombre: 'Zacarías León',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-06',
      nombre: 'Adriana Ponce',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-07',
      nombre: 'Bruno Valdez',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-08',
      nombre: 'Claudia Soto',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-09',
      nombre: 'Damián Lara',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-10',
      nombre: 'Elisa Cabrera',
      viajeId: 'TEP-01',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),

    // --- Grupo Viaje 309: Taxco (15 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-309-01',
      nombre: 'Fabián Guerrero',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 1.0,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-02',
      nombre: 'Gloria Sandoval',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.96,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-03',
      nombre: 'Hugo Cervantes',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-04',
      nombre: 'Irene Maldonado',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-05',
      nombre: 'Jorge Espinoza',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-06',
      nombre: 'Karina Velázquez',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-07',
      nombre: 'Leonardo Ávila',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-08',
      nombre: 'Mónica Gallegos',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-09',
      nombre: 'Nicolás Zamora',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.85,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-10',
      nombre: 'Olivia Carrillo',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-11',
      nombre: 'Pedro Alvarado',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-12',
      nombre: 'Quintana Barrios',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.86,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-13',
      nombre: 'Rodrigo Cárdenas',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-14',
      nombre: 'Susana Ochoa',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.95,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-15',
      nombre: 'Teodoro Marín',
      viajeId: 'TAX-01',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),

    // --- Grupo Viaje 401: Cañón del Sumidero (25 pax) - FINALIZADO ---
    const Turista(
      id: 'T-401-01',
      nombre: 'Ulises Mendoza',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.75,
      enCampo: false,
      // Datos de auditoría
      incidentesCount: 0,
      asistio: true,
      notasGuia: 'Excelente participante, completó la ruta sin problemas.',
      calificacion: 5.0,
    ),
    const Turista(
      id: 'T-401-02',
      nombre: 'Vanessa Robles',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.68,
      enCampo: false,
      // Datos de auditoría
      incidentesCount: 1,
      asistio: true,
      notasGuia:
          'Tuvo una alerta de alejamiento menor, pero se reintegró rápidamente al grupo.',
      calificacion: 4.5,
    ),
    const Turista(
      id: 'T-401-03',
      nombre: 'Walter Figueroa',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.72,
      enCampo: false,
      // Datos de auditoría
      incidentesCount: 0,
      asistio: false,
      notasGuia: 'No se presentó al viaje (No-Show).',
      calificacion: null,
    ),
    const Turista(
      id: 'T-401-04',
      nombre: 'Ximena Padilla',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.65,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-05',
      nombre: 'Yair Contreras',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.70,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-06',
      nombre: 'Zoe Santana',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.78,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-07',
      nombre: 'Aarón Villegas',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.63,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-08',
      nombre: 'Brenda Osorio',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.69,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-09',
      nombre: 'Cristian Mejía',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.74,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-10',
      nombre: 'Dulce Arellano',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.67,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-11',
      nombre: 'Emilio Becerra',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.71,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-12',
      nombre: 'Fátima Solís',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.76,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-13',
      nombre: 'Germán Trejo',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.64,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-14',
      nombre: 'Hilda Quintero',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.70,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-15',
      nombre: 'Iván Camacho',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.73,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-16',
      nombre: 'Jazmín Duarte',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.66,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-17',
      nombre: 'Kaleb Serrano',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.69,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-18',
      nombre: 'Lorena Valdés',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.75,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-19',
      nombre: 'Mateo Rangel',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.62,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-20',
      nombre: 'Nora Esquivel',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.68,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-21',
      nombre: 'Omar Galván',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.71,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-22',
      nombre: 'Perla Salinas',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.77,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-23',
      nombre: 'Quetzal Ibáñez',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.65,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-24',
      nombre: 'Ramiro Cordero',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.70,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-25',
      nombre: 'Sarai Montoya',
      viajeId: 'SUM-01',
      status: 'OK',
      bateria: 0.74,
      enCampo: false,
    ),
  ];

  // --- 4. LISTA DE ALERTAS (Usando Entity Alerta) ---
  final List<Alerta> _alertas = [
    Alerta(
      id: 'A-01',
      viajeId: 'MEX-01',
      nombreTurista: 'Ana G.',
      turistaId: 'T-01', // ← NUEVO: ID del turista
      tipo: 'PANICO',
      hora: DateTime.now().subtract(const Duration(minutes: 5)),
      esCritica: true,
      mensaje: 'PÁNICO - Turista Ana G. activó SOS',
    ),
    Alerta(
      id: 'A-02',
      viajeId: 'MEX-03',
      nombreTurista: 'Luis P.',
      turistaId: 'T-110-01', // ← CORREGIDO: ID real de Luis P.
      tipo: 'LEJANIA',
      hora: DateTime.now().subtract(const Duration(minutes: 15)),
      esCritica: false,
      mensaje: 'ALEJAMIENTO - Luis P. fuera de rango (50m)',
    ),
    Alerta(
      id: 'A-03',
      viajeId: 'MEX-02',
      nombreTurista: 'Sofía Morales',
      turistaId: 'T-205-08', // ← CORREGIDO: ID real de Sofía Morales
      tipo: 'BATERIA',
      hora: DateTime.now().subtract(const Duration(hours: 1)),
      esCritica: false,
      mensaje: 'BATERÍA BAJA - Sofía M. tiene 22% de batería',
    ),
    Alerta(
      id: 'A-04',
      viajeId: 'MEX-02',
      nombreTurista: 'Guía: Pedro S.',
      turistaId: null, // ← NUEVO: null porque es alerta del guía, no turista
      tipo: 'CONECTIVIDAD',
      hora: DateTime.now().subtract(const Duration(hours: 5)),
      esCritica: true,
      mensaje: 'PÉRDIDA DE CONEXIÓN - Guía sin señal por 10 minutos',
    ),
    // Alerta INFO - Sincronización automática
    Alerta(
      id: 'A-05',
      viajeId: 'MEX-03',
      nombreTurista: 'Sistema',
      turistaId: null, // ← NUEVO: null porque es alerta de sistema
      tipo: 'SINCRONIZACION',
      hora: DateTime.now().subtract(const Duration(minutes: 40)),
      esCritica: false,
      mensaje: 'Sincronización automática de itinerarios completada',
    ),
    // Alerta INFO - Modificación de geocerca
    Alerta(
      id: 'A-06',
      viajeId: 'MEX-01',
      nombreTurista: 'Admin Juan',
      turistaId: null, // ← NUEVO: null porque es alerta de sistema
      tipo: 'MODIFICACION',
      hora: DateTime.now().subtract(const Duration(hours: 2)),
      esCritica: false,
      mensaje: 'Modificación de Geocerca en Viaje #MEX-01',
    ),
  ];

  // --- MÉTODOS API SIMULADOS ---

  // Obtener Datos Completos para el Dashboard (Calculados)
  Future<Map<String, dynamic>> getDashboardFullData() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Latencia

    // CÁLCULOS REALES BASADOS EN LAS LISTAS
    final viajesActivos = _viajes.where((v) => v.estado == 'EN_CURSO').toList();
    final viajesProgramados =
        _viajes.where((v) => v.estado == 'PROGRAMADO').length;

    // Contamos turistas reales cuyo status 'enCampo' es true
    final turistasEnCampo = _turistas.where((t) => t.enCampo).length;

    // Contamos turistas que tienen status OFFLINE
    final turistasSinRed = _turistas.where((t) => t.status == 'OFFLINE').length;

    // Contamos guías offline
    final guiasOffline = _guias.where((g) => g.status == 'OFFLINE').length;
    final guiasTotal = _guias.length;

    // Contamos alertas (basándonos en status SOS/ADVERTENCIA de turistas)
    final alertasCriticas = _alertas.where((a) => a.esCritica).length;

    return {
      // Data para KPIs
      'stats': {
        'viajes_activos': viajesActivos.length,
        'viajes_prog': viajesProgramados,

        'turistas_campo': turistasEnCampo,
        'turistas_sin_red': turistasSinRed,

        'alertas_criticas': alertasCriticas,

        'guias_total': guiasTotal,
        'guias_offline': guiasOffline,
      },
      // Listas completas para pintar mapas y tablas
      'active_trips': _viajes, // ← TODOS los viajes para que el mapa filtre
      'alertas_recientes': _alertas,
    };
  }

  // Método de búsqueda universal para autocomplete
  Future<List<Map<String, dynamic>>> searchAll(String query) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simular latencia

    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    // PRIORIDAD 1: Buscar en viajes PRIMERO (por ID exacto o destino)
    for (final viaje in _viajes) {
      // Coincidencia exacta de ID tiene máxima prioridad
      if (viaje.id == query ||
          viaje.id.toLowerCase().contains(lowerQuery) ||
          viaje.destino.toLowerCase().contains(lowerQuery)) {
        results.add({
          'type': 'trip',
          'id': viaje.id,
          'destino': viaje.destino,
          'estado': viaje.estado,
          'turistas': viaje.turistas,
        });
      }
    }

    // PRIORIDAD 2: Buscar en guías
    for (final guia in _guias) {
      if (guia.nombre.toLowerCase().contains(lowerQuery) ||
          guia.id.toLowerCase().contains(lowerQuery)) {
        // Determinar estado del viaje asignado
        String? viajeEstado;
        if (guia.status == 'EN_VIAJE') {
          // Buscar el viaje asignado a este guía
          final viajeAsignado =
              _viajes.where((v) {
                return v.guiaNombre.contains(guia.nombre.split(' ')[0]);
              }).firstOrNull;

          viajeEstado = viajeAsignado?.estado;
        }

        results.add({
          'type': 'guide',
          'id': guia.id,
          'nombre': guia.nombre,
          'status': guia.status,
          'rol': guia.rol,
          'viajeEstado': viajeEstado, // Nuevo campo
        });
      }
    }

    // PRIORIDAD 3: Buscar en turistas
    // Solo buscar por NOMBRE, no por ID (los IDs son T-01, T-02, etc. y causan falsos positivos)
    for (final turista in _turistas) {
      if (turista.nombre.toLowerCase().contains(lowerQuery)) {
        results.add({
          'type': 'tourist',
          'id': turista.id,
          'nombre': turista.nombre,
          'viajeId': turista.viajeId,
          'status': turista.status,
        });
      }
    }

    // Limitar resultados de forma balanceada: máximo 5 de cada tipo
    final trips = results.where((r) => r['type'] == 'trip').take(5).toList();
    final guides = results.where((r) => r['type'] == 'guide').take(5).toList();
    final tourists =
        results.where((r) => r['type'] == 'tourist').take(5).toList();

    // Combinar manteniendo prioridad: trips, guides, tourists
    final balancedResults = [...trips, ...guides, ...tourists];

    return balancedResults.take(15).toList();
  }

  // --- MÉTODOS API SIMULADOS (CRUD) ---

  // 1. Para Pantalla "Gestión de Viajes"
  Future<List<Viaje>> getAllViajes() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _viajes;
  }

  // 2. Para Pantalla "Detalle de Viaje" (Busca por ID)
  Future<Viaje?> getViajeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _viajes.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  // 3. Para Pantalla "Usuarios"
  Future<List<Guia>> getAllGuias() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _guias;
  }

  // --- 4. LISTA DE LOGS (Auditoría) ---
  final List<LogAuditoria> _logs = [
    LogAuditoria(
      id: 'LOG-9021',
      fecha: DateTime.now().subtract(const Duration(minutes: 2)),
      nivel: 'CRITICO',
      actor: 'Sistema',
      accion: 'Detectado patrón de pánico en Turista T-01 (Ana G.)',
      ip: '192.168.1.10',
      metadata: {
        'bpm': 140,
        'velocidad': '12 km/h',
        'bateria': '15%',
        'coords': '19.4326, -99.1332',
        'dispositivo': 'Android SM-G990',
        'alert_id': 'ALT-9921',
        'distance': '120m',
        'threshold': '50m',
      },
      relatedRoute: '/viajes/204?alert_focus=T-01',
    ),
    LogAuditoria(
      id: 'LOG-9020',
      fecha: DateTime.now().subtract(const Duration(minutes: 15)),
      nivel: 'ADVERTENCIA',
      actor: 'Guía: Marcos R.',
      accion: 'Reporte de alejamiento temporal (falsa alarma)',
      ip: 'App Móvil (4G)',
      metadata: {
        'device_id': 'ANDROID-X82',
        'signal_strength': '45%',
        'last_known_loc': 'Checkpoint 2',
        'duration': '120s',
      },
      relatedRoute: '/viajes/204',
    ),
    LogAuditoria(
      id: 'LOG-9019',
      fecha: DateTime.now().subtract(const Duration(hours: 1)),
      nivel: 'INFO',
      actor: 'Admin: Juan',
      accion: 'Modificación de Geocerca en Viaje #MEX-01',
      ip: '10.0.0.5',
      metadata: {
        'previous_value': '50m',
        'new_value': '20m',
        'reason': 'Niebla reportada',
        'timestamp_server':
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      },
      relatedRoute: '/viajes/204',
    ),
    LogAuditoria(
      id: 'LOG-9018',
      fecha: DateTime.now().subtract(const Duration(hours: 2)),
      nivel: 'INFO',
      actor: 'Sistema',
      accion: 'Sincronización automática de itinerarios completada',
      ip: 'Server CronJob',
      metadata: {'trips_synced': 12, 'duration_ms': 3420, 'status': 'success'},
    ),
    LogAuditoria(
      id: 'LOG-9017',
      fecha: DateTime.now().subtract(const Duration(hours: 5)),
      nivel: 'CRITICO',
      actor: 'Guía: Pedro S.',
      accion: 'Pérdida total de conexión por 10 minutos',
      ip: 'App Móvil (Offline)',
      metadata: {
        'device_id': 'IOS-P42',
        'signal_strength': '0%',
        'last_known_loc': 'Zona Montañosa',
        'offline_duration': '600s',
        'battery_level': '22%',
      },
      relatedRoute: '/viajes/205',
    ),
  ];

  // 4. Para Pantalla "Auditoría"
  Future<List<LogAuditoria>> getAuditLogs() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _logs; // Retorna la lista ordenada por defecto
  }

  // 5. Get Turistas by Viaje ID
  Future<List<Turista>> getTuristasByViajeId(String viajeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _turistas.where((t) => t.viajeId == viajeId).toList();
  }

  // 6. Get Alertas by Viaje ID
  Future<List<Alerta>> getAlertasByViajeId(String viajeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _alertas.where((a) => a.viajeId == viajeId).toList();
  }

  // 6.1. Get Recent Alertas (sorted by timestamp, most recent first)
  Future<List<Alerta>> getRecentAlertas({int limit = 3}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sortedAlertas = List<Alerta>.from(_alertas);
    sortedAlertas.sort(
      (a, b) => b.hora.compareTo(a.hora),
    ); // Más reciente primero
    return sortedAlertas.take(limit).toList();
  }

  // 7. Simulate Trip Cancellation/Deletion
  Future<bool> simularDeleteViaje(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would make a DELETE request to the API
    // For the mock, we return true to simulate success
    // You could also remove the trip from _viajes list if you want to persist the change
    return true;
  }

  // 8. Get All Turistas (for User Management section)
  Future<List<Turista>> getAllTuristas() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _turistas;
  }

  // ✨ FASE 12: Transactional Save - Simulation
  Future<void> addViaje(Viaje viaje) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular red
    // Insertar al inicio para que aparezca primero en la lista
    _viajes.insert(0, viaje);
    // ignore: avoid_print
    print(
      "💾 VIAJE GUARDADO: ${viaje.destino} con ${viaje.itinerario.length} actividades.",
    );
  }
}
