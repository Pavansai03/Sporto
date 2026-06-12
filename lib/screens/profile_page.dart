import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sporto/common/sporto_title.dart';
import 'package:sporto/controllers/auth_controller.dart';
import 'package:sporto/controllers/profile_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController controller = Get.put(ProfileController());
  final AuthController authController = Get.put(AuthController());

  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Photo Gallery'),
              onTap: () => controller.pickAndUploadImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Camera'),
              onTap: () => controller.pickAndUploadImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 NEW: Edit Profile Dialog
  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: controller.userName.value);
    final TextEditingController phoneController = TextEditingController(text: controller.userPhone.value == 'Not provided' ? '' : controller.userPhone.value);

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Profile Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: const Icon(Icons.person, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: const Icon(Icons.phone, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar("Error", "Name cannot be empty", backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }
              controller.updateProfileDetails(nameController.text.trim(), phoneController.text.trim());
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back();
              await Supabase.instance.client.auth.signOut();
            },
            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3, 0.8],
              colors: [Color.fromRGBO(61, 205, 22, 1.0), Colors.black, Colors.black],
            ),
          ),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const Expanded(child: Center(child: SportoTitle())),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Colors.green));
                    }
                    return _buildProfileContent();
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return RefreshIndicator(
      color: Colors.green,
      onRefresh: () async {
        await controller.loadProfileData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: controller.avatarUrl.value.isNotEmpty
                        ? NetworkImage(controller.avatarUrl.value)
                        : null,
                    child: controller.isUploading.value
                        ? const CircularProgressIndicator(color: Colors.green)
                        : controller.avatarUrl.value.isEmpty
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 🔥 Added onEdit callback to make Name & Phone editable
            ProfileInfoBox(
              label: "Name",
              value: controller.userName.value,
              icon: Icons.person_outline,
              onEdit: _showEditProfileDialog,
            ),
            const SizedBox(height: 15),

            // Email is not editable
            ProfileInfoBox(
              label: "Email",
              value: controller.userEmail.value,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 15),

            ProfileInfoBox(
              label: "Phone",
              value: controller.userPhone.value,
              icon: Icons.phone_outlined,
              onEdit: _showEditProfileDialog,
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Upcoming Bookings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),

            controller.myBookings.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No upcoming bookings.", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.myBookings.length,
              itemBuilder: (context, index) {
                final booking = controller.myBookings[index];
                final turfMeta = booking['owners'] != null ? booking['owners']['metadata'] : {};
                final sports = booking['sports_selected'] as List? ?? [];
                final sportName = sports.isNotEmpty ? sports[0]['sport'] : 'Sport';

                return _buildBookingCard(booking, turfMeta, sportName);
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[700],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _showSignOutDialog,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatTo12Hour(String time) {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final ampm = hour >= 12 ? 'PM' : 'AM';

      hour = hour % 12;
      if (hour == 0) hour = 12;

      return '$hour:$minute $ampm';
    } catch (e) {
      return time;
    }
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, Map<String, dynamic> turfMeta, String sportName) {
    final rawStartTime = booking['start_time']?.toString() ?? '00:00';
    final safeStartTime = rawStartTime.length >= 5 ? rawStartTime.substring(0, 5) : rawStartTime;
    final rawEndTime = booking['end_time']?.toString() ?? '00:00';
    final safeEndTime = rawEndTime.length >= 5 ? rawEndTime.substring(0, 5) : rawEndTime;

    final formattedStartTime = _formatTo12Hour(safeStartTime);
    final formattedEndTime = _formatTo12Hour(safeEndTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  turfMeta['turf_name'] ?? 'Turf Venue',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(20)),
                child: Text(
                  booking['status'].toString().toUpperCase(),
                  style: TextStyle(color: Colors.green[800], fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.sports_soccer, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(sportName, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${booking['booking_date']} | $formattedStartTime - $formattedEndTime",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text("₹${booking['total_price']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ],
      ),
    );
  }
}

// 🔥 UPGRADED: ProfileInfoBox now accepts an optional onEdit callback to display a pencil icon
class ProfileInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onEdit;

  const ProfileInfoBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
              onPressed: onEdit,
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}