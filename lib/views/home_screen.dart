import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../viewmodel/session_viewmodel.dart';
import 'session_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/bg.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Location Tracker", style: TextStyle(fontSize: 28.0, color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            Container(color: Colors.black45), // Optional overlay for contrast
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Start New Session"),
                    onPressed: () {
                      final vm = context.read<SessionViewModel>();
                      vm.startNewSession();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SessionScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Continue Last Session"),
                    onPressed: () async {
                      final vm = context.read<SessionViewModel>();
                      final sessions = await vm.getAllSessions();
                      if (sessions.isNotEmpty) {
                        vm.continueSession(sessions.first);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SessionScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No previous session found."),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.history),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.blue[100]
                    ),
                    label: const Text("View Past Sessions", style: TextStyle(
                      color: Colors.black,
                    ),),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
