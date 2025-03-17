import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'api_service.dart';

class CaptureAndDetectScreen extends StatefulWidget {
  final CameraDescription camera;

  const CaptureAndDetectScreen({super.key, required this.camera});

  @override
  _CaptureAndDetectScreenState createState() => _CaptureAndDetectScreenState();
}

class _CaptureAndDetectScreenState extends State<CaptureAndDetectScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  File? _capturedImage;
  List<dynamic> _detections = [];
  Map<String, int> _objectCounts = {};
  bool _isLoading = false;
  Size? _originalImageSize;
  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndDetect() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _detections = [];
      _objectCounts = {};
    });

    try {
      final image = await _controller.takePicture();
      final imageFile = File(image.path);
      
      // Get original image dimensions
      final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
      
      setState(() {
        _capturedImage = imageFile;
        _originalImageSize = Size(
          decodedImage.width.toDouble(),
          decodedImage.height.toDouble()
        );
      });

      final response = await ApiService.detectObjects(imageFile.path);

      if (response.containsKey("detections")) {
        setState(() {
          _detections = response["detections"] ?? [];
          _objectCounts = Map<String, int>.from(response["objectCounts"] ?? {});
        });
      }
    } catch (e) {
      print("Error capturing image or running detection: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Size _getScaledSize(BoxConstraints constraints) {
    if (_originalImageSize == null) return Size.zero;

    final double screenWidth = constraints.maxWidth;
    final double screenHeight = constraints.maxHeight;
    final double imageAspectRatio = _originalImageSize!.width / _originalImageSize!.height;
    final double screenAspectRatio = screenWidth / screenHeight;

    late double scaledWidth;
    late double scaledHeight;

    if (imageAspectRatio > screenAspectRatio) {
      scaledWidth = screenWidth;
      scaledHeight = screenWidth / imageAspectRatio;
    } else {
      scaledHeight = screenHeight;
      scaledWidth = screenHeight * imageAspectRatio;
    }

    return Size(scaledWidth, scaledHeight);
  }

  Widget _buildBoundingBox(Map<String, dynamic> detection, Size scaledSize) {
    if (_originalImageSize == null) return Container();

    final double scaleX = scaledSize.width / _originalImageSize!.width;
    final double scaleY = scaledSize.height / _originalImageSize!.height;

    final List<dynamic> bbox = detection['bbox'];
    final double left = bbox[0] * scaleX;
    final double top = bbox[1] * scaleY;
    final double width = (bbox[2] - bbox[0]) * scaleX;
    final double height = (bbox[3] - bbox[1]) * scaleY;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                "${detection['label']} (${(detection['confidence'] * 100).toStringAsFixed(1)}%)",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectCounts() {
    if (_objectCounts.isEmpty) return Container();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Detected Objects:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...(_objectCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  "${entry.key}: ${entry.value}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              );
            })),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture and Detect'),
      ),
      body: _capturedImage == null
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final scaledSize = _getScaledSize(constraints);
                return Stack(
                  children: [
                    Center(
                      child: Container(
                        width: scaledSize.width,
                        height: scaledSize.height,
                        child: Stack(
                          key: _imageKey,
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _capturedImage!,
                              fit: BoxFit.contain,
                            ),
                            if (_originalImageSize != null)
                              ..._detections.map((detection) =>
                                _buildBoundingBox(detection, scaledSize)
                              ).toList(),
                          ],
                        ),
                      ),
                    ),
                    _buildObjectCounts(),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _captureAndDetect,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.camera),
      ),
    );
  }
}