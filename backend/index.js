const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);

// Configuración de Socket.io
const io = new Server(server, {
  cors: { origin: '*' } // Ajustar en producción
});

// Objeto para llevar el control de qué viaje está ocupado
const canalOcupado = {};

io.on('connection', (socket) => {
  console.log('Un usuario se conectó:', socket.id);

  // 1. Unirse a la sala del viaje (ej. "viaje_GTO-4")
  socket.on('joinTrip', (tripId) => {
    socket.join(tripId);
    console.log(`Socket ${socket.id} se unió al viaje ${tripId}`);
  });

  // NUEVO: Alguien intenta presionar el botón
  socket.on('solicitarCanal', (tripId) => {
    if (!canalOcupado[tripId]) {
      // El canal está libre, se lo asignamos a este socket
      canalOcupado[tripId] = socket.id;
      // Le avisamos al que presionó que SÍ puede hablar
      socket.emit('canalConcedido');
      // Le avisamos a TODOS LOS DEMÁS que el canal se bloqueó
      socket.broadcast.to(tripId).emit('estadoCanal', { ocupado: true });
    } else {
      // Alguien más ya está hablando, le denegamos el permiso
      socket.emit('canalDenegado');
    }
  });

  // NUEVO: Alguien suelta el botón
  socket.on('liberarCanal', (tripId) => {
    if (canalOcupado[tripId] === socket.id) {
      canalOcupado[tripId] = null; // Liberamos el canal
      // Avisamos a toda la sala que ya pueden volver a hablar
      io.to(tripId).emit('estadoCanal', { ocupado: false });
    }
  });

  // 2. Escuchar el audio entrante y retransmitirlo a los demás en la sala
  socket.on('sendAudio', (data) => {
    socket.broadcast.to(data.tripId).emit('receiveAudio', data);
  });

  // NUEVO: Streaming de audio PCM en vivo (ráfagas de bytes)
  socket.on('audioStream', (data) => {
    socket.broadcast.to(data.tripId).emit('audioStream', data.chunk);
  });

  // Si alguien se desconecta mientras hablaba, liberamos su canal por seguridad
  socket.on('disconnect', () => {
    console.log('Usuario desconectado:', socket.id);
    for (const tripId in canalOcupado) {
      if (canalOcupado[tripId] === socket.id) {
        canalOcupado[tripId] = null;
        io.to(tripId).emit('estadoCanal', { ocupado: false });
      }
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
});
