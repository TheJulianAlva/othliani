// Modo demo para presentación en vivo.
// Cambiar a false para restaurar el comportamiento normal de producción.
const bool kDemoMode = true;

// URL del servidor Railway (se actualiza después del deploy en Fase 2)
const String kDemoServerUrl = 'https://othliani-production.up.railway.app';

// ID del viaje demo compartido entre App Turista y App Guía
const String kDemoTripId = 'demo-trip-cancun-2026';

// Nombre del turista demo (para el evento de pánico)
const String kDemoTuristaNombre = 'Ana Martínez';

// Canal unicast privado entre guía y el turista que activó el pánico
const String kDemoPanicChannelId = 'demo-direct-guia-ana';
