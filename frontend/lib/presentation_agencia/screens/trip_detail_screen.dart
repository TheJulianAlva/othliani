import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/trip_detail/trip_control_panel.dart';
import '../widgets/trip_detail/trip_map_viewer.dart';
import '../widgets/trip_detail/trip_passenger_list.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusUser =
          GoRouterState.of(context).uri.queryParameters['focus_user'];
      if (focusUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.my_location, color: Colors.white),
                const SizedBox(width: 12),
                Text('📍 Focalizando mapa en: $focusUser'),
              ],
            ),
            backgroundColor: Colors.blue.shade800,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                'VIAJE #${widget.tripId}: EXPEDICIÓN NEVADO DE TOLUCA',
                style: const TextStyle(
                  color: Color(0xFF0F4C75),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green),
              ),
              child: const Text(
                'EN CURSO', // Shortened
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.timer, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            const Text(
              '04:30 hrs', // Shortened
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {},
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Control Panel (Left - 20%)
          const Expanded(flex: 20, child: TripControlPanel()),

          // Divider
          VerticalDivider(width: 1, color: Colors.grey.shade300),

          // 2. Map Viewer (Center - 55%)
          const Expanded(flex: 55, child: TripMapViewer()),

          // Divider
          VerticalDivider(width: 1, color: Colors.grey.shade300),

          // 3. Passenger List (Right - 25%)
          const Expanded(flex: 25, child: TripPassengerList()),
        ],
      ),
    );
  }
}
