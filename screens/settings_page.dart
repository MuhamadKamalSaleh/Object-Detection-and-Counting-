import 'package:flutter/material.dart';

class AppColors {
  static const Color oxfordBlue = Color(0xFF002147);
  static const Color tan = Color(0xFFD2B48C);
  static const Color lightTan = Color(0xFFE6D5BC);
  static const Color darkBlue = Color(0xFF001A38);
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  double fontSize = 16.0;
  String selectedLanguage = 'English';
  bool isBiometricEnabled = false;

  final List<String> languages = ['English', 'Kurdish', 'Arabic', 'Turkish'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBlue : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.oxfordBlue,
        title: Text(
          "Settings",
          style: TextStyle(
            color: AppColors.lightTan,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            _buildSettingsSection(),
            _buildPreferencesSection(),
            _buildSecuritySection(),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      color: AppColors.oxfordBlue,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.tan, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  backgroundColor: AppColors.lightTan,
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.tan,
                child: IconButton(
                  icon: Icon(Icons.edit, size: 18, color: AppColors.oxfordBlue),
                  onPressed: () {
                    // TODO: Implement edit profile functionality
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            "John Doe",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTan,
            ),
          ),
          Text(
            "john.doe@example.com",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.tan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return _buildSection(
      "App Settings",
      [
        SettingTile(
          icon: Icons.dark_mode,
          title: "Dark Mode",
          trailing: Switch(
            value: isDarkMode,
            onChanged: (value) => setState(() => isDarkMode = value),
            activeColor: AppColors.tan,
          ),
        ),
        SettingTile(
          icon: Icons.notifications,
          title: "Notifications",
          trailing: Switch(
            value: isNotificationsEnabled,
            onChanged: (value) => setState(() => isNotificationsEnabled = value),
            activeColor: AppColors.tan,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      "Preferences",
      [
        SettingTile(
          icon: Icons.text_fields,
          title: "Font Size",
          trailing: DropdownButton<double>(
            value: fontSize,
            style: TextStyle(color: isDarkMode ? AppColors.lightTan : AppColors.oxfordBlue),
            dropdownColor: isDarkMode ? AppColors.darkBlue : Colors.white,
            onChanged: (double? newValue) {
              if (newValue != null) {
                setState(() => fontSize = newValue);
              }
            },
            items: [14.0, 16.0, 18.0, 20.0].map<DropdownMenuItem<double>>((double value) {
              return DropdownMenuItem<double>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      "Security",
      [
        SettingTile(
          icon: Icons.fingerprint,
          title: "Enable Biometric Login",
          trailing: Switch(
            value: isBiometricEnabled,
            onChanged: (value) => setState(() => isBiometricEnabled = value),
            activeColor: AppColors.tan,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      "About",
      [
        SettingTile(
          icon: Icons.info,
          title: "Version",
          trailing: Text("1.0.0", style: TextStyle(color: AppColors.oxfordBlue)),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.tan : AppColors.oxfordBlue,
            ),
          ),
          SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  SettingTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.tan),
      title: Text(title, style: TextStyle(color: AppColors.oxfordBlue)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
