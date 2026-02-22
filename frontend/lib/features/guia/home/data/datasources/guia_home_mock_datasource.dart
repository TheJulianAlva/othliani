import '../../domain/entities/agencia_home_data.dart';
import '../../domain/entities/personal_home_data.dart';

abstract class GuiaHomeRemoteDataSource {
  Future<AgenciaHomeData> getAgenciaHomeData(String folio);
  Future<PersonalHomeData> getPersonalHomeData(String nombreGuia);
}

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
      horaInicio: '08:00 AM',
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
      actividades: const [
        ActividadItinerario(
          nombre: 'Salida del hotel',
          horaInicio: '08:00',
          horaFin: '08:30',
          completada: true,
        ),
        ActividadItinerario(
          nombre: 'Snorkel en Punta Zicatela',
          horaInicio: '09:00',
          horaFin: '11:00',
          completada: true,
        ),
        ActividadItinerario(
          nombre: 'Almuerzo en Restaurante Playa',
          horaInicio: '12:00',
          horaFin: '13:30',
          completada: false,
        ),
        ActividadItinerario(
          nombre: 'Visita Barra de Navidad',
          horaInicio: '14:00',
          horaFin: '16:00',
          completada: false,
        ),
      ],
    );
  }
}
