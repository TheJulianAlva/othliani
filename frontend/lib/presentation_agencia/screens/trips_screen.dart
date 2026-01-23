import 'package:flutter/material.dart';
import '../widgets/trips/trips_toolbar.dart';
import '../widgets/trips/trips_datagrid.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          const TripsToolbar(),

          // DataGrid
          const Expanded(child: TripsDatagrid()),
        ],
      ),
    );
  }
}
