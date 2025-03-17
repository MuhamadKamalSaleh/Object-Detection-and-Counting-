import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/screens/api_service.dart';

class RealTimeDetectionScreen extends StatefulWidget {
  final CameraDescription camera;
  const RealTimeDetectionScreen({super.key, required this.camera});

  @override
  _RealTimeDetectionScreenState createState() => _RealTimeDetectionScreenState();
}

class _RealTimeDetectionScreenState extends State<RealTimeDetectionScreen> {
  late CameraController _controller;
  bool isProcessing = false;
  List<Map<String, dynamic>> detections = [];
  Map<String, int> objectCounts = {};

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _startDetection();
    });
  }

  void _startDetection() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!mounted || isProcessing) return;
      isProcessing = true;

      try {
        final image = await _controller.takePicture();
        final detectedObjects = await ApiService.detectObjects(image.path);

        if (!mounted) return;

        setState(() {
          detections = detectedObjects["detections"];
          objectCounts = detectedObjects["objectCounts"];
        });
      } catch (e) {
        print("Error: $e");
      } finally {
        isProcessing = false;
      }
    });
  }

  Widget _buildBoundingBox(Map<String, dynamic> detection, double scaleX, double scaleY) {
    if (detection["bbox"] == null || detection["bbox"].length != 4) return Container();

    final double left = detection["bbox"][0] * scaleX;
    final double top = detection["bbox"][1] * scaleY;
    final double width = (detection["bbox"][2] - detection["bbox"][0]) * scaleX;
    final double height = (detection["bbox"][3] - detection["bbox"][1]) * scaleY;
    
    // Calculate confidence-based color
    final double confidence = detection["confidence"];
    final Color boxColor = Color.lerp(
      Colors.red.withOpacity(0.7),
      Colors.green.withOpacity(0.7),
      confidence
    )!;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Stack(
        children: [
          // Main bounding box
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: boxColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(2),
              color: boxColor.withOpacity(0.1),
            ),
          ),
          // Label container
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: boxColor.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    detection['label'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      "${(detection['confidence'] * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectCounter() {
    if (objectCounts.isEmpty) return Container();

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Detected Objects",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: objectCounts.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${entry.key}: ${entry.value}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageSize = _controller.value.previewSize;
    if (imageSize == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Real-Time Detection")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final scaleX = screenSize.width / imageSize.height;
    final scaleY = screenSize.height / imageSize.width;

    return Scaffold(
      appBar: AppBar(title: Text("Real-Time Detection")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller),
          // Overlay for better text readability
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.srcOver,
            ),
            child: Container(),
          ),
          ...detections.map((detection) => 
            _buildBoundingBox(detection, scaleX, scaleY)
          ).toList(),
          _buildObjectCounter(),
        ],
      ),
    );
  }
}