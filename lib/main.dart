import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'viewmodel/session_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const PermissionCheckScreen(),
    );
  }
}

class PermissionCheckScreen extends StatefulWidget {
  const PermissionCheckScreen({super.key});

  @override
  State<PermissionCheckScreen> createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      setState(() {
        _locationGranted = true;
      });
    } else if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.location.request();
      setState(() {
        _locationGranted = result.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_locationGranted) {
      return const HomeScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Permission Required")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "This app needs location permission to function.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Retry Permission"),
              onPressed: _checkPermission,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              label: const Text("Exit App"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 500), () {
                  SystemNavigator.pop();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
