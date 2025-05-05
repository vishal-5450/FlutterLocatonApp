import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodel/session_viewmodel.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionViewModel>(
      builder: (context, vm, child) {
        final currentDate = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now());
        final currentTime = DateFormat(
          'HH:mm:ss',
        ).format(DateTime.now());
        final latest = vm.locations.isNotEmpty ? vm.locations.last : null;

        return Scaffold(
          appBar: AppBar(title: const Text("Session Running")),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    "Time: $currentTime \n Date: $currentDate" ,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 4, color: Colors.blue),
                    ),

                    child: Center(
                      child: Text(
                        "Elapsed Time: \n ${formatDuration(vm.elapsed)}",
                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Distance Travelled: ${vm.distance.toStringAsFixed(2)} meters",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (latest != null) ...[
                    Text(
                      "Latitude: ${latest.latitude}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Longitude: ${latest.longitude}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ] else
                    const Text(
                      "Waiting for location...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop, color: Colors.white),
                    label: const Text(
                      "End Session & Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await vm.endSession();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
