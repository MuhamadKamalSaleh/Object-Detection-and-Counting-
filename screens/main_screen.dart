import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/capture_and_detect_screen.dart';
import 'package:frontend/screens/gallery_detection.dart';
import 'package:frontend/screens/real_time_detection.dart';
import 'features_page.dart';
import 'settings_page.dart';

class AppColors {
  static const Color oxfordBlue = Color(0xFF002147);
  static const Color tan = Color(0xFFD2B48C);
  static const Color lightTan = Color(0xFFE6D5BC);
  static const Color darkBlue = Color(0xFF001A38);
}

class MainScreen extends StatefulWidget {
  final CameraDescription camera;
  const MainScreen({super.key, required this.camera});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      FeaturesPage(),
      DetectionPage(camera: widget.camera),
      SettingsPage(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.oxfordBlue,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          'Object Detection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Features',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Detect',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.oxfordBlue,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: _onPageChanged,
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
              },
              backgroundColor: AppColors.oxfordBlue,
              child: Icon(
                Icons.camera,
                color: AppColors.tan,
                size: 28,
              ),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
    );
  }
}

class DetectionPage extends StatelessWidget {
  final CameraDescription camera;

  const DetectionPage({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return _buildDetectionButton(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildDetectionButton(BuildContext context, int index) {
    final List<Map<String, dynamic>> buttonData = [
      {
        'icon': Icons.videocam,
        'label': 'Realtime Detection',
        'color': AppColors.oxfordBlue,
        'screen': RealTimeDetectionScreen(camera: camera),
      },
      {
        'icon': Icons.photo_library,
        'label': 'Gallery Detection',
        'color': AppColors.tan,
        'screen': GalleryDetectionScreen(),
      },
      {
        'icon': Icons.camera,
        'label': 'Capture & Detect',
        'color': AppColors.oxfordBlue,
        'screen': CaptureAndDetectScreen(camera: camera),
      },
      {
        'icon': Icons.video_collection,
        'label': 'Video Detection',
        'color': AppColors.tan,
        'screen': Container(), // Placeholder for video detection
      },
    ];

    final data = buttonData[index];
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => data['screen'],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: data['color'],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: data['color'].withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data['icon'],
              size: 40,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              data['label'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}