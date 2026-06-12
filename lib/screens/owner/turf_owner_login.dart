import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sporto/routes/routes_names.dart';
import 'package:sporto/common/sporto_title.dart';
import 'dart:math' as math;
import 'package:sporto/controllers/owner/owner_auth_controller.dart';

class TurfOwnerLogin extends StatefulWidget {
  const TurfOwnerLogin({super.key});

  @override
  State<TurfOwnerLogin> createState() => _TurfOwnerLoginState();
}

class _TurfOwnerLoginState extends State<TurfOwnerLogin> {
  final _formkey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isPasswordVisible = false;

  // Initializing the specific OwnerAuthController
  final OwnerAuthController controller = Get.put(OwnerAuthController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.3, 0.8],
                colors: [Color.fromRGBO(61, 205, 22, 1.0), Colors.black, Colors.black],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SportoTitle(),
                      SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(height: 1.0, width: double.infinity, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 40),
                  const Text("Sign in owner", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 25),
                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: _buildInputDecoration('Email Address', Icons.email_outlined),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Email is required';
                            if (!GetUtils.isEmail(val)) return 'Enter a valid email';
                            return null;
                          },
                          onChanged: (val) => setState(() => email = val),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          obscureText: !_isPasswordVisible,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: _buildPasswordDecoration('Password', _isPasswordVisible, () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          }),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Password is required';
                            if (val.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                          onChanged: (val) => setState(() => password = val),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(onPressed: () {}, child: const Text('Forgot password?', style: TextStyle(color: Colors.white))),
                        ),
                        const SizedBox(height: 10),
                        // Using owner-specific loading state
                        _buildMainButton('Sign In', controller.isOwnerLoginLoading, () {
                          if (_formkey.currentState!.validate()) {
                            controller.login(email, password);
                          }
                        }),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () => Get.toNamed(
                                RoutesName.turfRegister,
                              ),
                              child: const Text(
                                'SignUp',
                                style: TextStyle(color: Color.fromRGBO(61, 205, 22, 1.0)),
                              ),
                            ),
                          ],
                        ),
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

  // --- Helper Methods ---

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }

  InputDecoration _buildPasswordDecoration(String label, bool isVisible, VoidCallback toggle) {
    return InputDecoration(
      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
      suffixIcon: IconButton(
        onPressed: toggle,
        icon: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween<double>(begin: 0.0, end: isVisible ? 0.0 : 1.0),
          builder: (context, value, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.visibility, color: Colors.grey),
                Opacity(opacity: value, child: Transform.rotate(angle: -math.pi / 4, child: Container(width: 2.2, height: 22 * value, color: Colors.grey))),
              ],
            );
          },
        ),
      ),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildMainButton(String label, RxBool loading, VoidCallback onPressed) {
    return Obx(() => ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(61, 205, 22, 1.0),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
      onPressed: onPressed,
      child: Text(loading.value ? 'Loading...' : label, style: const TextStyle(fontSize: 20)),
    ));
  }
}