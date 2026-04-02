import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sporto/controllers/auth_controller.dart';
import 'package:sporto/routes/routes_names.dart';
import 'package:sporto/common/sporto_title.dart';
import 'dart:math' as math;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formkey = GlobalKey<FormState>();
  String name = "", email = "", mobile = "", password = "";
  bool _isPasswordVisible = false, _isConfirmPasswordVisible = false;

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.black, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.0, 0.4, 0.8], colors: [Color.fromRGBO(61, 205, 22, 1.0), Colors.black, Colors.black]),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header Row synchronized with Login using VisualDensity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SportoTitle(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        // Use Get.back() if they just came from Login
                        // Or Get.offNamed to replace the current screen
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.login, color: Colors.white, size: 28),
                        tooltip: 'Sign In',
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(height: 1.0, width: double.infinity, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 20),
                  const Text('Get Ready to play', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  // const Text('Enter your info to register for new account', style: TextStyle(color: Colors.grey, fontSize: 18)),
                  // const SizedBox(height: 24),
                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        _buildTextField('Full Name', Icons.person_outline, (val) => name = val, (val) => (val == null || val.isEmpty) ? 'Name is required' : null),
                        const SizedBox(height: 12),
                        _buildTextField('Email', Icons.email_outlined, (val) => email = val, (val) {
                          if (val == null || val.isEmpty) return 'Email is required';
                          if (!GetUtils.isEmail(val)) return 'Enter a valid email';
                          return null;
                        }),
                        const SizedBox(height: 12),
                        _buildTextField('Mobile Number', Icons.phone_android_outlined, (val) => mobile = val, (val) {
                          if (val == null || val.isEmpty) return 'Mobile number is required';
                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(val)) return 'Enter a valid 10-digit number';
                          return null;
                        }),
                        const SizedBox(height: 12),
                        _buildPasswordField('Password', _isPasswordVisible, () => setState(() => _isPasswordVisible = !_isPasswordVisible), (val) {
                          if (val == null || val.isEmpty) return 'Password is required';
                          if (val.length < 6) return 'At least 6 characters required';
                          return null;
                        }),
                        const SizedBox(height: 12),
                        _buildPasswordField('Confirm Password', _isConfirmPasswordVisible, () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible), (val) {
                          if (val == null || val.isEmpty) return 'Please confirm password';
                          if (val != password) return 'Passwords do not match';
                          return null;
                        }),
                        const SizedBox(height: 20),
                        _buildMainButton('Sign Up', controller.isSignupLoading, () {
                          if (_formkey.currentState!.validate()) controller.signup(name, mobile, email, password);
                        }),
                        const SizedBox(height: 20),
                        const Center(child: Text('--or--', style: TextStyle(color: Colors.white,
                        fontSize: 15))),
                        const SizedBox(height: 20),
                        _buildGoogleButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods maintained for consistency
  Widget _buildTextField(String label, IconData icon, Function(String) onChanged, String? Function(String?)? validator) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
        label: Text(label),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      onChanged: (val) { onChanged(val); setState(() { if (label == 'Password') password = val; }); },
      validator: validator,
    );
  }

  Widget _buildPasswordField(String label, bool isVisible, VoidCallback toggle, String? Function(String?)? validator) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Colors.white),
      obscureText: !isVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(onPressed: toggle, icon: TweenAnimationBuilder<double>(duration: const Duration(milliseconds: 400), tween: Tween<double>(begin: 0.0, end: isVisible ? 0.0 : 1.0), builder: (context, value, child) { return Stack(alignment: Alignment.center, children: [const Icon(Icons.visibility, color: Colors.grey), Opacity(opacity: value, child: Transform.rotate(angle: -math.pi / 4, child: Container(width: 2.2, height: 22 * value, color: Colors.grey)))]); })),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
        label: Text(label),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: validator,
      onChanged: (val) { if (label == 'Password') setState(() => password = val); },
    );
  }

  Widget _buildMainButton(String label, RxBool loading, VoidCallback onPressed) { return Obx(() => ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(61, 205, 22, 1.0), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: onPressed, child: Text(loading.value ? 'Loading...' : label, style: const TextStyle(fontSize: 20)))); }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: () => controller.googleSignIn(),
      style: OutlinedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, minimumSize: const Size.fromHeight(50), side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network('https://www.google.com/favicon.ico', height: 20, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, color: Colors.blue)),
          const SizedBox(width: 12),
          const Text('Sign in with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}