import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/location_viewmodel.dart';
import '../widgets/info_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LocationViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location & Time'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InfoCard(
                    label: 'Latitude',
                    value: viewModel.position?.latitude.toStringAsFixed(5) ?? 'Loading...',
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    label: 'Longitude',
                    value: viewModel.position?.longitude.toStringAsFixed(5) ?? 'Loading...',
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    label: 'Date & Time',
                    value: viewModel.time?.substring(0, 19) ?? 'Loading...',
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    label: 'Distance Travelled (m)',
                    value: viewModel.distance.toStringAsFixed(2),
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    label: 'Time Elapsed',
                    value: viewModel.elapsedTimeFormatted,
                  ),
                ],
              ),
            ),
          ),
          if (!viewModel.permissionGranted)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Please allow location access',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.requestPermission(),
                        child: const Text('Grant Permission'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
