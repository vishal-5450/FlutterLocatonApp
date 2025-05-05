import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/session.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String formatDuration(Duration duration) {
    return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Past Sessions")),
      body: FutureBuilder<List<Session>>(
        future: DatabaseService().getAllSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No sessions found."));
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final start = DateFormat(
                'yyyy-MM-dd HH:mm',
              ).format(session.startTime);
              return Container(
                decoration: BoxDecoration(
                  color: Colors.blue, // Background color of the tile
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue, // Border color
                    width: 2, // Border width
                  ),
                ),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    "Session on $start",
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  subtitle: Text(
                    "Duration: ${formatDuration(session.elapsedTime)}\nDistance: ${session.distance.toStringAsFixed(2)} m",
                    style: TextStyle(fontSize: 18.0, color: Colors.white70),
                  ),
                  onTap: () {
                    // handle tap if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
