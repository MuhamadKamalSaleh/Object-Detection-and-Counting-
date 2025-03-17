import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:camera/camera.dart';

class WelcomePage extends StatefulWidget {
  final CameraDescription camera;

  WelcomePage({Key? key, required this.camera}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  bool isHuman = false;
  bool isDarkMode = false;
  String welcomeMessage = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const Color oxfordBlue = Color(0xFF002147);
  static const Color tan = Color(0xFFD2B48C);
  static const Color lightTan = Color(0xFFE6D5BC);
  static const Color darkBlue = Color(0xFF001A38);

  @override
  void initState() {
    super.initState();
    _generateRandomWelcomeMessage();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _generateRandomWelcomeMessage() {
    List<String> messages = [
      "Welcome to Premium Detection",
      "Experience AI Excellence",
      "Discover Intelligent Recognition",
      "Your Premium AI Assistant",
    ];
    setState(() {
      welcomeMessage = (messages..shuffle()).first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Ensures the container takes the full screen width
        height: double.infinity, // Ensures the container takes the full screen height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [darkBlue, oxfordBlue]
                : [lightTan, tan],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    _buildThemeToggle(),
                    SizedBox(height: 40),
                    _buildWelcomeHeader(),
                    SizedBox(height: 40),
                    _buildInputFields(),
                    SizedBox(height: 24),
                    _buildVerificationButton(),
                    SizedBox(height: 24),
                    _buildContinueButton(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: isDarkMode ? Colors.amber : Colors.grey[800],
          ),
          onPressed: () => setState(() => isDarkMode = !isDarkMode),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        Icon(
          Icons.camera_alt,
          size: 64,
          color: isDarkMode ? Colors.white70 : oxfordBlue,
        ),
        SizedBox(height: 24),
        Text(
          welcomeMessage,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : oxfordBlue,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Text(
          "Enter your details to begin",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          hint: "Your Name",
          icon: Icons.person_outline,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          hint: "Your Email",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.grey[400],
          ),
          prefixIcon: Icon(
            icon,
            color: isDarkMode ? Colors.white54 : oxfordBlue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildVerificationButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: InkWell(
        onTap: () => setState(() => isHuman = !isHuman),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isHuman
                ? Color(0xFF4CAF50)
                : (isDarkMode ? Colors.grey[850] : Colors.white),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isHuman ? Icons.check_circle : Icons.verified_user_outlined,
                color: isHuman
                    ? Colors.white
                    : (isDarkMode ? Colors.white54 : oxfordBlue),
              ),
              SizedBox(width: 8),
              Text(
                isHuman ? "Verified" : "Verify Identity",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isHuman
                      ? Colors.white
                      : (isDarkMode ? Colors.white : oxfordBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    bool canContinue = isHuman && _nameController.text.isNotEmpty;
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canContinue
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(camera: widget.camera),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              oxfordBlue, // ✅ Use backgroundColor instead of primary
          foregroundColor:
              Colors.white, // ✅ Use foregroundColor instead of onPrimary
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          "Continue",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
