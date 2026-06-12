import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sporto/common/sporto_title.dart';
import 'package:sporto/routes/routes_names.dart';

class UserOwnerToggle extends StatelessWidget {
  const UserOwnerToggle({super.key});

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
            // Matching the exact gradient from your Login page
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.3, 0.8],
                colors: [Color.fromRGBO(61, 205, 22, 1.0), Colors.black, Colors.black],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const SportoTitle(),
                  const SizedBox(height: 5),
                  Container(
                      height: 1.0,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.3)
                  ),
                  const Spacer(),

                  const Text(
                    "Welcome!",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Select your role to continue",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 40),

                  // User Button
                  _buildRoleCard(
                    title: "I'm a Player",
                    subtitle: "Book turfs and join matches",
                    icon: Icons.sports_soccer,
                    onTap: () => Get.toNamed(RoutesName.login),
                  ),

                  const SizedBox(height: 20),

                  // Owner Button
                  _buildRoleCard(
                    title: "I'm an Owner",
                    subtitle: "Register and manage your turf",
                    icon: Icons.stadium_outlined,
                    onTap: () {
                      // Navigate to your Turf Registration route
                      // Get.toNamed(RoutesName.turfRegistration);
                      Get.toNamed(RoutesName.turfOwnerLogin);
                    },
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color.fromRGBO(61, 205, 22, 1.0),
              radius: 25,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}