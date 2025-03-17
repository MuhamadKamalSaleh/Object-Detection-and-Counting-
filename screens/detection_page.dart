// lib/screens/detection_page.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'gallery_detection.dart';
import 'real_time_detection.dart';
import 'capture_and_detect_screen.dart'; // Import the new CaptureAndDetectScreen

class DetectionPage extends StatelessWidget {
  final CameraDescription camera;

  const DetectionPage({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GalleryDetectionScreen()),
                );
              },
              icon: Icon(Icons.image),
              label: Text('Gallery Detection'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RealTimeDetectionScreen(camera: camera)),
                );
              },
              icon: Icon(Icons.videocam),
              label: Text('Real-Time Detection'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaptureAndDetectScreen(camera: camera),
                  ),
                );
              },
              icon: Icon(Icons.camera_alt),
              label: Text('Capture and Detect'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
