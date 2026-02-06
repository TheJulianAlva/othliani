import '../../domain/entities/viaje.dart';
import '../../domain/entities/guia.dart';
import '../../domain/entities/turista.dart';
import '../../domain/entities/alerta.dart';
import '../../domain/entities/log_auditoria.dart';
import 'mock_models.dart'; // Keep for backward compatibility during transition

class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  // --- 1. LISTA DE GUÍAS (Usando Entity Guia) ---
  final List<Guia> _guias = [
    const Guia(
      id: 'G-01',
      nombre: 'Marcos Ruiz',
      status: 'EN_RUTA',
      viajesAsignados: 1,
    ),
    const Guia(
      id: 'G-02',
      nombre: 'Ana Paula G.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-03',
      nombre: 'Pedro Sánchez',
      status: 'EN_RUTA',
      viajesAsignados: 1,
    ),
    const Guia(
      id: 'G-04',
      nombre: 'Luisa Lane',
      status: 'OFFLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-05',
      nombre: 'Carlos V.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-06',
      nombre: 'Sofia R.',
      status: 'EN_RUTA',
      viajesAsignados: 1,
    ),
    const Guia(
      id: 'G-07',
      nombre: 'Jorge T.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-08',
      nombre: 'Mariana L.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-09',
      nombre: 'Roberto C.',
      status: 'EN_RUTA',
      viajesAsignados: 1,
    ),
    const Guia(
      id: 'G-10',
      nombre: 'Elena M.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
  ];

  // --- 2. LISTA DE VIAJES (Usando Entity Viaje) ---
  final List<Viaje> _viajes = [
    // Viajes Activos (En Curso)
    const Viaje(
      id: '204',
      destino: 'Centro Histórico CDMX',
      estado: 'EN_CURSO',
      turistas: 15,
      latitud: 19.4326,
      longitud: -99.1332,
      guiaNombre: 'Marcos Ruiz',
      horaInicio: '09:00 AM',
      alertasActivas: 1, // Ana G. en pánico
    ),
    const Viaje(
      id: '205',
      destino: 'Zona Montañosa - Desierto de los Leones',
      estado: 'EN_CURSO',
      turistas: 8,
      latitud: 19.3117,
      longitud: -99.3147,
      guiaNombre: 'Pedro Sánchez',
      horaInicio: '08:30 AM',
      alertasActivas: 2, // Batería baja + Conectividad
    ),
    const Viaje(
      id: '110',
      destino: 'Teotihuacán',
      estado: 'EN_CURSO',
      turistas: 40,
      latitud: 19.6925,
      longitud: -98.8439,
      guiaNombre: 'Ana Torres',
      horaInicio: '07:00 AM',
      alertasActivas: 1, // Luis P. alejado
    ),

    // Viajes Futuros
    const Viaje(
      id: '305',
      destino: 'Nevado de Toluca',
      estado: 'PROGRAMADO',
      turistas: 12,
      latitud: 19.108,
      longitud: -99.759,
      guiaNombre: 'Carlos Vega',
      horaInicio: 'Mañana 06:00 AM',
      alertasActivas: 0,
    ),
    const Viaje(
      id: '306',
      destino: 'Valle de Bravo',
      estado: 'PROGRAMADO',
      turistas: 8,
      latitud: 19.192,
      longitud: -100.131,
      guiaNombre: 'Luisa Lane',
      horaInicio: 'En 2 días',
      alertasActivas: 0,
    ),
    const Viaje(
      id: '307',
      destino: 'Xochimilco',
      estado: 'PROGRAMADO',
      turistas: 20,
      latitud: 19.295,
      longitud: -99.099,
      guiaNombre: 'Roberto Gómez',
      horaInicio: 'Sábado 10:00 AM',
      alertasActivas: 0,
    ),
    const Viaje(
      id: '308',
      destino: 'Tepoztlán',
      estado: 'PROGRAMADO',
      turistas: 10,
      latitud: 18.986,
      longitud: -99.100,
      guiaNombre: 'María López',
      horaInicio: 'Domingo 08:00 AM',
      alertasActivas: 0,
    ),
    const Viaje(
      id: '309',
      destino: 'Taxco',
      estado: 'PROGRAMADO',
      turistas: 15,
      latitud: 18.556,
      longitud: -99.605,
      guiaNombre: 'Sin asignar',
      horaInicio: 'Próxima semana',
      alertasActivas: 0,
    ),

    // Viajes Pasados
    const Viaje(
      id: '401',
      destino: 'Cañón del Sumidero',
      estado: 'FINALIZADO',
      turistas: 25,
      latitud: 16.835,
      longitud: -93.033,
      guiaNombre: 'Jorge Ramírez',
      horaInicio: 'Hace 3 horas',
      alertasActivas: 0, // Sin incidentes
    ),
  ];

  // --- 3. LISTA DE TURISTAS (Población Real) ---
  final List<Turista> _turistas = [
    // --- Grupo Viaje 204 (15 pax) ---
    // Turista Problemático (SOS)
    const Turista(
      id: 'T-01',
      nombre: 'Ana Gómez',
      viajeId: '204',
      status: 'SOS',
      bateria: 0.15,
      enCampo: true,
    ),
    // Turistas Normales
    const Turista(
      id: 'T-02',
      nombre: 'Juan Pérez',
      viajeId: '204',
      status: 'OK',
      bateria: 0.90,
      enCampo: true,
    ),
    const Turista(
      id: 'T-03',
      nombre: 'Carla M.',
      viajeId: '204',
      status: 'OK',
      bateria: 0.85,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04',
      nombre: 'Luis R.',
      viajeId: '204',
      status: 'OK',
      bateria: 0.88,
      enCampo: true,
    ),
    // Rellenos para completar los 15 del viaje 204
    const Turista(
      id: 'T-04-5',
      nombre: 'Turista 204-5',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-6',
      nombre: 'Turista 204-6',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-7',
      nombre: 'Turista 204-7',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-8',
      nombre: 'Turista 204-8',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-9',
      nombre: 'Turista 204-9',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-10',
      nombre: 'Turista 204-10',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-11',
      nombre: 'Turista 204-11',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-12',
      nombre: 'Turista 204-12',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-13',
      nombre: 'Turista 204-13',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-14',
      nombre: 'Turista 204-14',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-15',
      nombre: 'Turista 204-15',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),

    // --- Grupo Viaje 205 (8 pax) - Zona Montañosa ---
    const Turista(
      id: 'T-205-01',
      nombre: 'Roberto Sánchez',
      viajeId: '205',
      status: 'OK',
      bateria: 0.25,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-02',
      nombre: 'María López',
      viajeId: '205',
      status: 'OK',
      bateria: 0.30,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-03',
      nombre: 'Carlos Mendoza',
      viajeId: '205',
      status: 'OK',
      bateria: 0.40,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-04',
      nombre: 'Laura Fernández',
      viajeId: '205',
      status: 'OK',
      bateria: 0.35,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-05',
      nombre: 'Diego Torres',
      viajeId: '205',
      status: 'OK',
      bateria: 0.28,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-06',
      nombre: 'Patricia Ruiz',
      viajeId: '205',
      status: 'OK',
      bateria: 0.32,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-07',
      nombre: 'Fernando García',
      viajeId: '205',
      status: 'OK',
      bateria: 0.27,
      enCampo: true,
    ),
    const Turista(
      id: 'T-205-08',
      nombre: 'Sofía Morales',
      viajeId: '205',
      status: 'OK',
      bateria: 0.22,
      enCampo: true,
    ),

    // --- Grupo Viaje 110 (40 pax) ---
    // Turista con Advertencia (Alejamiento)
    const Turista(
      id: 'T-110-01',
      nombre: 'Luis P.',
      viajeId: '110',
      status: 'ADVERTENCIA',
      bateria: 0.30,
      enCampo: true,
    ),
    // Relleno
    const Turista(
      id: 'T-110-2',
      nombre: 'Turista 110-2',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-3',
      nombre: 'Turista 110-3',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-4',
      nombre: 'Turista 110-4',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-5',
      nombre: 'Turista 110-5',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-6',
      nombre: 'Turista 110-6',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-7',
      nombre: 'Turista 110-7',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-8',
      nombre: 'Turista 110-8',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-9',
      nombre: 'Turista 110-9',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-10',
      nombre: 'Turista 110-10',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-11',
      nombre: 'Turista 110-11',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-12',
      nombre: 'Turista 110-12',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-13',
      nombre: 'Turista 110-13',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-14',
      nombre: 'Turista 110-14',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-15',
      nombre: 'Turista 110-15',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-16',
      nombre: 'Turista 110-16',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-17',
      nombre: 'Turista 110-17',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-18',
      nombre: 'Turista 110-18',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-19',
      nombre: 'Turista 110-19',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-20',
      nombre: 'Turista 110-20',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-21',
      nombre: 'Turista 110-21',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-22',
      nombre: 'Turista 110-22',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-23',
      nombre: 'Turista 110-23',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-24',
      nombre: 'Turista 110-24',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-25',
      nombre: 'Turista 110-25',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-26',
      nombre: 'Turista 110-26',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-27',
      nombre: 'Turista 110-27',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-28',
      nombre: 'Turista 110-28',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-29',
      nombre: 'Turista 110-29',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-30',
      nombre: 'Turista 110-30',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-31',
      nombre: 'Turista 110-31',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-32',
      nombre: 'Turista 110-32',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-33',
      nombre: 'Turista 110-33',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-34',
      nombre: 'Turista 110-34',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-35',
      nombre: 'Turista 110-35',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-36',
      nombre: 'Turista 110-36',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-37',
      nombre: 'Turista 110-37',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-38',
      nombre: 'Turista 110-38',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-39',
      nombre: 'Turista 110-39',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-40',
      nombre: 'Turista 110-40',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),

    // --- Turistas Offline (Sin red, pero en campo) ---
    const Turista(
      id: 'T-OFF-1',
      nombre: 'Pepe L.',
      viajeId: '204',
      status: 'OFFLINE',
      bateria: 0.50,
      enCampo: true,
    ),
    const Turista(
      id: 'T-OFF-2',
      nombre: 'Maria S.',
      viajeId: '110',
      status: 'OFFLINE',
      bateria: 0.40,
      enCampo: true,
    ),
    const Turista(
      id: 'T-OFF-3',
      nombre: 'Jose K.',
      viajeId: '110',
      status: 'OFFLINE',
      bateria: 0.20,
      enCampo: true,
    ),

    // --- Grupo Viaje 305: Nevado de Toluca (12 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-305-01',
      nombre: 'Roberto Martínez',
      viajeId: '305',
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
      viajeId: '305',
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
      viajeId: '305',
      status: 'OK',
      bateria: 0.95,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-04',
      nombre: 'Patricia Hernández',
      viajeId: '305',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-05',
      nombre: 'Fernando García',
      viajeId: '305',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-06',
      nombre: 'Laura Ramírez',
      viajeId: '305',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-07',
      nombre: 'Javier Sánchez',
      viajeId: '305',
      status: 'OK',
      bateria: 0.85,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-08',
      nombre: 'Gabriela Morales',
      viajeId: '305',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-09',
      nombre: 'Ricardo Flores',
      viajeId: '305',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-10',
      nombre: 'Daniela Castro',
      viajeId: '305',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-11',
      nombre: 'Alberto Mendoza',
      viajeId: '305',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-305-12',
      nombre: 'Verónica Silva',
      viajeId: '305',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),

    // --- Grupo Viaje 306: Valle de Bravo (8 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-306-01',
      nombre: 'Andrés Gutiérrez',
      viajeId: '306',
      status: 'OK',
      bateria: 1.0,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-02',
      nombre: 'Carolina Vargas',
      viajeId: '306',
      status: 'OK',
      bateria: 0.96,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-03',
      nombre: 'Diego Rojas',
      viajeId: '306',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-04',
      nombre: 'Mariana Ortiz',
      viajeId: '306',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-05',
      nombre: 'Pablo Reyes',
      viajeId: '306',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-06',
      nombre: 'Sofía Jiménez',
      viajeId: '306',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-07',
      nombre: 'Héctor Medina',
      viajeId: '306',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-306-08',
      nombre: 'Valeria Cruz',
      viajeId: '306',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),

    // --- Grupo Viaje 307: Xochimilco (20 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-307-01',
      nombre: 'Alejandro Ruiz',
      viajeId: '307',
      status: 'OK',
      bateria: 1.0,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-02',
      nombre: 'Beatriz Navarro',
      viajeId: '307',
      status: 'OK',
      bateria: 0.97,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-03',
      nombre: 'César Domínguez',
      viajeId: '307',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-04',
      nombre: 'Diana Peña',
      viajeId: '307',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-05',
      nombre: 'Eduardo Vega',
      viajeId: '307',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-06',
      nombre: 'Fernanda Ríos',
      viajeId: '307',
      status: 'OK',
      bateria: 0.95,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-07',
      nombre: 'Gustavo Paredes',
      viajeId: '307',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-08',
      nombre: 'Helena Campos',
      viajeId: '307',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-09',
      nombre: 'Ignacio Salazar',
      viajeId: '307',
      status: 'OK',
      bateria: 0.86,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-10',
      nombre: 'Julia Cortés',
      viajeId: '307',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-11',
      nombre: 'Kevin Aguilar',
      viajeId: '307',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-12',
      nombre: 'Liliana Fuentes',
      viajeId: '307',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-13',
      nombre: 'Manuel Estrada',
      viajeId: '307',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-14',
      nombre: 'Natalia Herrera',
      viajeId: '307',
      status: 'OK',
      bateria: 0.96,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-15',
      nombre: 'Óscar Delgado',
      viajeId: '307',
      status: 'OK',
      bateria: 0.85,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-16',
      nombre: 'Paola Montes',
      viajeId: '307',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-17',
      nombre: 'Raúl Castillo',
      viajeId: '307',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-18',
      nombre: 'Silvia Ramos',
      viajeId: '307',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-19',
      nombre: 'Tomás Ibarra',
      viajeId: '307',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-307-20',
      nombre: 'Úrsula Molina',
      viajeId: '307',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),

    // --- Grupo Viaje 308: Tepoztlán (10 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-308-01',
      nombre: 'Vicente Acosta',
      viajeId: '308',
      status: 'OK',
      bateria: 1.0,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-02',
      nombre: 'Wendy Pacheco',
      viajeId: '308',
      status: 'OK',
      bateria: 0.95,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-03',
      nombre: 'Xavier Núñez',
      viajeId: '308',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-04',
      nombre: 'Yolanda Bravo',
      viajeId: '308',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-05',
      nombre: 'Zacarías León',
      viajeId: '308',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-06',
      nombre: 'Adriana Ponce',
      viajeId: '308',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-07',
      nombre: 'Bruno Valdez',
      viajeId: '308',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-08',
      nombre: 'Claudia Soto',
      viajeId: '308',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-09',
      nombre: 'Damián Lara',
      viajeId: '308',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-308-10',
      nombre: 'Elisa Cabrera',
      viajeId: '308',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),

    // --- Grupo Viaje 309: Taxco (15 pax) - PROGRAMADO ---
    const Turista(
      id: 'T-309-01',
      nombre: 'Fabián Guerrero',
      viajeId: '309',
      status: 'OK',
      bateria: 1.0,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-02',
      nombre: 'Gloria Sandoval',
      viajeId: '309',
      status: 'OK',
      bateria: 0.96,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-03',
      nombre: 'Hugo Cervantes',
      viajeId: '309',
      status: 'OK',
      bateria: 0.92,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-04',
      nombre: 'Irene Maldonado',
      viajeId: '309',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-05',
      nombre: 'Jorge Espinoza',
      viajeId: '309',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-06',
      nombre: 'Karina Velázquez',
      viajeId: '309',
      status: 'OK',
      bateria: 0.94,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-07',
      nombre: 'Leonardo Ávila',
      viajeId: '309',
      status: 'OK',
      bateria: 0.87,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-08',
      nombre: 'Mónica Gallegos',
      viajeId: '309',
      status: 'OK',
      bateria: 0.91,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-09',
      nombre: 'Nicolás Zamora',
      viajeId: '309',
      status: 'OK',
      bateria: 0.85,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-10',
      nombre: 'Olivia Carrillo',
      viajeId: '309',
      status: 'OK',
      bateria: 0.89,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-11',
      nombre: 'Pedro Alvarado',
      viajeId: '309',
      status: 'OK',
      bateria: 0.93,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-12',
      nombre: 'Quintana Barrios',
      viajeId: '309',
      status: 'OK',
      bateria: 0.86,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-13',
      nombre: 'Rodrigo Cárdenas',
      viajeId: '309',
      status: 'OK',
      bateria: 0.90,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-14',
      nombre: 'Susana Ochoa',
      viajeId: '309',
      status: 'OK',
      bateria: 0.95,
      enCampo: false,
    ),
    const Turista(
      id: 'T-309-15',
      nombre: 'Teodoro Marín',
      viajeId: '309',
      status: 'OK',
      bateria: 0.88,
      enCampo: false,
    ),

    // --- Grupo Viaje 401: Cañón del Sumidero (25 pax) - FINALIZADO ---
    const Turista(
      id: 'T-401-01',
      nombre: 'Ulises Mendoza',
      viajeId: '401',
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
      viajeId: '401',
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
      viajeId: '401',
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
      viajeId: '401',
      status: 'OK',
      bateria: 0.65,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-05',
      nombre: 'Yair Contreras',
      viajeId: '401',
      status: 'OK',
      bateria: 0.70,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-06',
      nombre: 'Zoe Santana',
      viajeId: '401',
      status: 'OK',
      bateria: 0.78,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-07',
      nombre: 'Aarón Villegas',
      viajeId: '401',
      status: 'OK',
      bateria: 0.63,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-08',
      nombre: 'Brenda Osorio',
      viajeId: '401',
      status: 'OK',
      bateria: 0.69,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-09',
      nombre: 'Cristian Mejía',
      viajeId: '401',
      status: 'OK',
      bateria: 0.74,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-10',
      nombre: 'Dulce Arellano',
      viajeId: '401',
      status: 'OK',
      bateria: 0.67,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-11',
      nombre: 'Emilio Becerra',
      viajeId: '401',
      status: 'OK',
      bateria: 0.71,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-12',
      nombre: 'Fátima Solís',
      viajeId: '401',
      status: 'OK',
      bateria: 0.76,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-13',
      nombre: 'Germán Trejo',
      viajeId: '401',
      status: 'OK',
      bateria: 0.64,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-14',
      nombre: 'Hilda Quintero',
      viajeId: '401',
      status: 'OK',
      bateria: 0.70,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-15',
      nombre: 'Iván Camacho',
      viajeId: '401',
      status: 'OK',
      bateria: 0.73,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-16',
      nombre: 'Jazmín Duarte',
      viajeId: '401',
      status: 'OK',
      bateria: 0.66,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-17',
      nombre: 'Kaleb Serrano',
      viajeId: '401',
      status: 'OK',
      bateria: 0.69,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-18',
      nombre: 'Lorena Valdés',
      viajeId: '401',
      status: 'OK',
      bateria: 0.75,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-19',
      nombre: 'Mateo Rangel',
      viajeId: '401',
      status: 'OK',
      bateria: 0.62,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-20',
      nombre: 'Nora Esquivel',
      viajeId: '401',
      status: 'OK',
      bateria: 0.68,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-21',
      nombre: 'Omar Galván',
      viajeId: '401',
      status: 'OK',
      bateria: 0.71,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-22',
      nombre: 'Perla Salinas',
      viajeId: '401',
      status: 'OK',
      bateria: 0.77,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-23',
      nombre: 'Quetzal Ibáñez',
      viajeId: '401',
      status: 'OK',
      bateria: 0.65,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-24',
      nombre: 'Ramiro Cordero',
      viajeId: '401',
      status: 'OK',
      bateria: 0.70,
      enCampo: false,
    ),
    const Turista(
      id: 'T-401-25',
      nombre: 'Sarai Montoya',
      viajeId: '401',
      status: 'OK',
      bateria: 0.74,
      enCampo: false,
    ),
  ];

  // --- 4. LISTA DE ALERTAS (Usando Entity Alerta) ---
  final List<Alerta> _alertas = [
    Alerta(
      id: 'A-01',
      viajeId: '204',
      nombreTurista: 'Ana G.',
      tipo: 'PANICO',
      hora: DateTime.now().subtract(const Duration(minutes: 5)),
      esCritica: true,
      mensaje: 'PÁNICO - Turista Ana G. activó SOS',
    ),
    Alerta(
      id: 'A-02',
      viajeId: '110',
      nombreTurista: 'Luis P.',
      tipo: 'LEJANIA',
      hora: DateTime.now().subtract(const Duration(minutes: 15)),
      esCritica: false,
      mensaje: 'ALEJAMIENTO - Luis P. fuera de rango (50m)',
    ),
    Alerta(
      id: 'A-03',
      viajeId: '205',
      nombreTurista: 'Sofía Morales',
      tipo: 'BATERIA',
      hora: DateTime.now().subtract(const Duration(hours: 1)),
      esCritica: false,
      mensaje: 'BATERÍA BAJA - Sofía M. tiene 22% de batería',
    ),
    Alerta(
      id: 'A-04',
      viajeId: '205',
      nombreTurista: 'Guía: Pedro S.',
      tipo: 'CONECTIVIDAD',
      hora: DateTime.now().subtract(const Duration(hours: 5)),
      esCritica: true,
      mensaje: 'PÉRDIDA DE CONEXIÓN - Guía sin señal por 10 minutos',
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
      accion: 'Modificación de Geocerca en Viaje #204',
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

  // Legacy getters for backward compatibility (will be removed)
  List<MockAlerta> get alertas =>
      _alertas
          .map(
            (a) => MockAlerta(
              id: a.id,
              idViaje: a.viajeId,
              nombreTurista: a.nombreTurista,
              tipo: a.tipo == 'PANICO' ? TipoAlerta.PANICO : TipoAlerta.LEJANIA,
              hora: a.hora,
              esCritica: a.esCritica,
              mensaje: a.mensaje,
            ),
          )
          .toList();

  List<MockViaje> get viajes =>
      _viajes
          .map(
            (v) => MockViaje(
              id: v.id,
              destino: v.destino,
              estado:
                  v.estado == 'EN_CURSO'
                      ? EstadoViaje.EN_CURSO
                      : v.estado == 'PROGRAMADO'
                      ? EstadoViaje.PROGRAMADO
                      : EstadoViaje.FINALIZADO,
              turistasTotales: v.turistas,
              idGuia: 'g1',
              latitudActual: v.latitud,
              longitudActual: v.longitud,
            ),
          )
          .toList();
}
