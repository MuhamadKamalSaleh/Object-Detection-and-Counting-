import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/screens/welcome_page.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // Fetch camera list
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: cameras.isNotEmpty
          ? WelcomePage(camera: cameras.first) // Pass the first available camera
          : Scaffold(body: Center(child: Text("No camera found!"))),
    );
  }
}
