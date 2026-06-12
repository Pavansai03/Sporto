import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var isUploading = false.obs;

  // User Data
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var avatarUrl = ''.obs;

  // Bookings Data
  var myBookings = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData(isRefresh: false);
  }

  // 1. Fetch User Data
  Future<void> loadProfileData({bool isRefresh = true}) async {
    try {
      if (!isRefresh) isLoading.value = true;

      final user = supabase.auth.currentUser;

      if (user != null) {
        userEmail.value = user.email ?? 'No Email';

        final dbUser = await supabase.from('users').select('metadata').eq('id', user.id).maybeSingle();

        // Check Auth Session
        final authAvatar = user.userMetadata?['avatar_url']?.toString() ?? user.userMetadata?['picture']?.toString() ?? '';
        final authName = user.userMetadata?['name']?.toString() ?? user.userMetadata?['full_name']?.toString() ?? '';
        final authPhone = user.userMetadata?['mobile']?.toString() ?? '';

        // Check Database
        final dbAvatar = (dbUser?['metadata'] as Map?)?['avatar_url']?.toString() ?? '';
        final dbName = (dbUser?['metadata'] as Map?)?['name']?.toString() ?? '';
        final dbPhone = (dbUser?['metadata'] as Map?)?['mobile']?.toString() ?? '';

        // 🔥 Database takes absolute priority for all editable fields!
        avatarUrl.value = dbAvatar.isNotEmpty ? dbAvatar : authAvatar;
        userName.value = dbName.isNotEmpty ? dbName : (authName.isNotEmpty ? authName : 'Player');
        userPhone.value = dbPhone.isNotEmpty ? dbPhone : (authPhone.isNotEmpty ? authPhone : 'Not provided');

        await fetchBookings(user.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      if (!isRefresh) isLoading.value = false;
    }
  }

  // 🔥 NEW: Update Profile Details (Name & Phone)
  Future<void> updateProfileDetails(String newName, String newPhone) async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser!;
      final userId = user.id;

      // 1. Save to permanent public.users table
      final dbUser = await supabase.from('users').select('metadata').eq('id', userId).maybeSingle();
      Map<String, dynamic> updatedMeta = Map<String, dynamic>.from((dbUser?['metadata'] as Map?) ?? {});

      updatedMeta['name'] = newName;
      updatedMeta['mobile'] = newPhone;

      await supabase.from('users').update({'metadata': updatedMeta}).eq('id', userId);

      // 2. Update Auth session metadata
      await supabase.auth.updateUser(
        UserAttributes(data: {'name': newName, 'mobile': newPhone}),
      );

      // 3. Update UI instantly
      userName.value = newName;
      userPhone.value = newPhone;

      Get.back(); // Close the dialog
      Get.snackbar('Success', 'Profile updated successfully!', backgroundColor: Colors.green[100]);

    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Fetch the user's booking history
  Future<void> fetchBookings(String userId) async {
    try {
      final response = await supabase
          .from('bookings')
          .select('*, owners(metadata)')
          .eq('user_id', userId)
          .order('booking_date', ascending: true)
          .order('start_time', ascending: true);

      final now = DateTime.now();
      List<Map<String, dynamic>> activeBookings = [];

      for (var booking in response) {
        final dateStr = booking['booking_date'];
        final endTimeStr = booking['end_time'] != null ? booking['end_time'].toString() : '';
        DateTime endDateTime;

        if (endTimeStr.isNotEmpty) {
          endDateTime = DateTime.parse('$dateStr $endTimeStr');
        } else {
          final startDateTime = DateTime.parse('$dateStr ${booking['start_time']}');
          endDateTime = startDateTime.add(const Duration(hours: 1));
        }

        if (endDateTime.isAfter(now)) {
          activeBookings.add(booking);
        }
      }
      myBookings.value = activeBookings;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bookings: $e');
    }
  }

  // 3. Handle Profile Picture Upload
  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      Get.back();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile == null) return;

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            resetButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      isUploading.value = true;
      File imageFile = File(croppedFile.path);

      final user = supabase.auth.currentUser!;
      final userId = user.id;
      final fileExt = croppedFile.path.split('.').last;

      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'user_avatars/$fileName';

      await supabase.storage.from('avatars').upload(filePath, imageFile);
      final String publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      await supabase.auth.updateUser(UserAttributes(data: {'avatar_url': publicUrl}));

      try {
        final dbUser = await supabase.from('users').select('metadata').eq('id', userId).maybeSingle();
        Map<String, dynamic> updatedMeta = Map<String, dynamic>.from((dbUser?['metadata'] as Map?) ?? {});
        updatedMeta['avatar_url'] = publicUrl;

        await supabase.from('users').update({'metadata': updatedMeta}).eq('id', userId);
      } catch (dbError) {
        debugPrint("DB Update Warning: $dbError");
      }

      avatarUrl.value = publicUrl;
      Get.snackbar('Success', 'Profile picture updated!', backgroundColor: Colors.green[100]);

    } catch (e) {
      Get.snackbar('Error', 'Failed to update image: $e');
    } finally {
      isUploading.value = false;
    }
  }
}