import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/api_service.dart';
import 'package:image_picker/image_picker.dart';

class GalleryDetectionScreen extends StatefulWidget {
  const GalleryDetectionScreen({super.key});

  @override
  _GalleryDetectionScreenState createState() => _GalleryDetectionScreenState();
}

class _GalleryDetectionScreenState extends State<GalleryDetectionScreen> {
  File? _image;
  List<Map<String, dynamic>> detections = [];
  Map<String, int> objectCounts = {};
  Size? _originalImageSize;
  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pickImageFromGallery();
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _processImage(File(pickedFile.path));
    }
  }

  Future<void> _processImage(File image) async {
    // Get the original image dimensions
    final decodedImage = await decodeImageFromList(image.readAsBytesSync());
    setState(() {
      _image = image;
      detections = [];
      objectCounts = {};
      _originalImageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    });

    final processedImage = await _removeBackground(image);
    _detectObjects(processedImage);
  }

  Future<File> _removeBackground(File image) async {
    return image;
  }

  Future<void> _detectObjects(File image) async {
    final detectedObjects = await ApiService.detectObjects(image.path);
    setState(() {
      detections = detectedObjects["detections"];
      objectCounts = detectedObjects["objectCounts"];
    });
  }

  Future<void> _goBackToMainPage() async {
    setState(() {
      _image = null;
      detections = [];
      objectCounts = {};
      _originalImageSize = null;
    });
  }

  Size _getScaledSize(BuildContext context, BoxConstraints constraints) {
    if (_originalImageSize == null) return Size.zero;

    final double screenWidth = constraints.maxWidth;
    final double screenHeight = constraints.maxHeight;
    final double imageAspectRatio = _originalImageSize!.width / _originalImageSize!.height;
    final double screenAspectRatio = screenWidth / screenHeight;

    late double scaledWidth;
    late double scaledHeight;

    if (imageAspectRatio > screenAspectRatio) {
      // Image is wider than screen
      scaledWidth = screenWidth;
      scaledHeight = screenWidth / imageAspectRatio;
    } else {
      // Image is taller than screen
      scaledHeight = screenHeight;
      scaledWidth = screenHeight * imageAspectRatio;
    }

    return Size(scaledWidth, scaledHeight);
  }

  Widget _buildBoundingBox(Map<String, dynamic> detection, Size scaledSize) {
    final double scaleX = scaledSize.width / _originalImageSize!.width;
    final double scaleY = scaledSize.height / _originalImageSize!.height;

    final double left = detection["bbox"][0] * scaleX;
    final double top = detection["bbox"][1] * scaleY;
    final double width = (detection["bbox"][2] - detection["bbox"][0]) * scaleX;
    final double height = (detection["bbox"][3] - detection["bbox"][1]) * scaleY;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery & Camera Detection"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImageFromGallery,
          ),
        ],
      ),
      body: _image == null
          ? Center(
              child: ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: const Text("Open Gallery"),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final scaledSize = _getScaledSize(context, constraints);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: scaledSize.width,
                        height: scaledSize.height,
                        child: Stack(
                          key: _imageKey,
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _image!,
                              fit: BoxFit.contain,
                            ),
                            if (_originalImageSize != null)
                              ...detections.map((detection) => 
                                _buildBoundingBox(detection, scaledSize)
                              ).toList(),
                          ],
                        ),
                      ),
                      if (objectCounts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Detected Objects:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...objectCounts.entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        "${entry.key}: ${entry.value}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}