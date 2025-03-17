import 'package:flutter/material.dart';

class AppColors {
  static const Color oxfordBlue = Color(0xFF002147);
  static const Color tan = Color(0xFFD2B48C);
  static const Color lightTan = Color(0xFFE6D5BC);
  static const Color darkBlue = Color(0xFF001A38);
}

class FeaturesPage extends StatelessWidget {
  final List<FeatureItem> features = [
    FeatureItem(
      title: 'Real-Time Object Detection',
      description: 'Detect multiple objects simultaneously with high accuracy using advanced AI algorithms',
      icon: Icons.camera,
      comingSoon: true,
    ),
    FeatureItem(
      title: 'Precise Object Counting',
      description: 'Automatically count detected objects with detailed statistics and reporting',
      icon: Icons.format_list_numbered,
      comingSoon: true,
    ),
    FeatureItem(
      title: 'Custom Object Classes',
      description: 'Define and train custom object classes for specific detection needs',
      icon: Icons.category,
      comingSoon: true,
    ),
    FeatureItem(
      title: 'Export & Share Results',
      description: 'Export detection results in multiple formats and share with team members',
      icon: Icons.share,
      comingSoon: true,
    ),
    FeatureItem(
      title: 'Analytics Dashboard',
      description: 'Comprehensive dashboard with detection history and performance metrics',
      icon: Icons.analytics,
      comingSoon: true,
    ),
    FeatureItem(
      title: 'Batch Processing',
      description: 'Process multiple images or video frames simultaneously',
      icon: Icons.batch_prediction,
      comingSoon: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.oxfordBlue,
        title: Text(
          'Upcoming Features',
          style: TextStyle(
            color: AppColors.lightTan,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: AppColors.oxfordBlue,
            child: Column(
              children: [
                Icon(
                  Icons.upcoming,
                  size: 50,
                  color: AppColors.tan,
                ),
                SizedBox(height: 16),
                Text(
                  'Exciting Features Coming Soon',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTan,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'We\'re working hard to bring you these powerful capabilities',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.tan,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return _buildFeatureCard(features[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(FeatureItem feature) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.tan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightTan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature.icon,
                size: 30,
                color: AppColors.oxfordBlue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          feature.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.oxfordBlue,
                          ),
                        ),
                      ),
                      if (feature.comingSoon)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tan,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Coming Soon',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.oxfordBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    feature.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
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

class FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final bool comingSoon;

  FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    this.comingSoon = false,
  });
}