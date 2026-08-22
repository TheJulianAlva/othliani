const { createServer } = require('http');
const { Server } = require('socket.io');

const httpServer = createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Veltur Demo Server OK');
});

const io = new Server(httpServer, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

io.on('connection', (socket) => {
  console.log(`[+] ${socket.id} conectado`);

  // Unirse al canal del viaje demo
  socket.on('joinTrip', (tripId) => {
    socket.join(tripId);
    console.log(`    ${socket.id} unido a viaje: ${tripId}`);
  });

  // Acto 2: Turista presiona pánico → se reenvía a todos en el viaje
  socket.on('turista_panico', (data) => {
    console.log(`[!] PÁNICO de "${data.nombre}" en viaje ${data.tripId}`);
    io.to(data.tripId).emit('turista_panico', data);
  });

  // Acto 3: Guía solicita canal de voz → se le concede y se notifica a los demás
  socket.on('solicitarCanal', (tripId) => {
    console.log(`[🎙] Canal solicitado en viaje ${tripId}`);
    socket.emit('canalConcedido');
    socket.to(tripId).emit('estadoCanal', { ocupado: true });
  });

  // Acto 3: Guía transmite chunks de audio PCM → se reenvían a todos menos al emisor
  socket.on('audioStream', (data) => {
    socket.to(data.tripId).emit('audioStream', data.chunk);
  });

  // Acto 3: Guía suelta el canal
  socket.on('liberarCanal', (tripId) => {
    console.log(`[🔇] Canal liberado en viaje ${tripId}`);
    socket.emit('canalLiberado');
    socket.to(tripId).emit('estadoCanal', { ocupado: false });
  });

  socket.on('disconnect', () => {
    console.log(`[-] ${socket.id} desconectado`);
  });
});

const PORT = process.env.PORT || 3000;
httpServer.listen(PORT, () => {
  console.log(`Veltur Demo Server escuchando en puerto ${PORT}`);
});
