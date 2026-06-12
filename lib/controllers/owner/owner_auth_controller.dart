import 'dart:io';
import 'package:get/get.dart';
import 'package:sporto/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sporto/routes/routes_names.dart';
import 'package:sporto/api/owner/owner_auth_api.dart';

class OwnerAuthController extends GetxController {
  late OwnerAuthApi ownerAuthAPi;

  @override
  void onInit() {
    super.onInit();
    ownerAuthAPi = OwnerAuthApi(SupabaseService.supabase);
  }

  RxBool isOwnerSignupLoading = false.obs;
  RxBool isOwnerLoginLoading = false.obs;

  // --- 1. Added Sign Out Method ---
  void signOut() async {
    try {
      await SupabaseService.supabase.auth.signOut();
      // Redirect back to the starting toggle screen
      Get.offAllNamed(RoutesName.UserOwnerToggle);
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: ${e.toString()}');
    }
  }

  void login(String identifier, String password) async {
    try {
      isOwnerLoginLoading.value = true;
      final AuthResponse response = await ownerAuthAPi.login(identifier, password);
      isOwnerLoginLoading.value = false;

      if (response.user != null) {
        Get.snackbar('Success', 'Welcome back, Owner!', snackPosition: SnackPosition.BOTTOM);
        // Correctly redirect to owner dashboard
        Get.offAllNamed(RoutesName.ownerHome);
      }
    } catch (e) {
      isOwnerLoginLoading.value = false;
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      Get.snackbar('Login Failed', errorMsg, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void registerOwnerTurf({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required String turfName,
    required String address,
    required double? lat,
    required double? lng,
    required List dynamicSportsData,
    required List<File> imageFiles,
  }) async {
    try {
      if (lat == null || lng == null) {
        Get.snackbar('Location Missing', 'Please fetch coordinates first.');
        return;
      }

      isOwnerSignupLoading.value = true;
      List<String> uploadedUrls = [];

      // 1. Upload multiple images to Supabase Storage
      for (File file in imageFiles) {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFiles.indexOf(file)}.jpg';
        final String path = 'turf_photos/$fileName';

        await SupabaseService.supabase.storage
            .from('turf_images')
            .upload(path, file);

        final String publicUrl = SupabaseService.supabase.storage
            .from('turf_images')
            .getPublicUrl(path);

        uploadedUrls.add(publicUrl);
      }

      // 2. Structure metadata
      final List sportsList = dynamicSportsData
          .where((e) => e.sportController.text.trim().isNotEmpty)
          .map((e) => {
        'sport': e.sportController.text.trim(),
        'timings': e.timingController.text.trim(),
        'price_per_hr': e.priceController.text.trim(),
      })
          .toList();

      final Map<String, dynamic> turfMetadata = {
        'turf_name': turfName,
        'address': address,
        'location': {'lat': lat, 'lng': lng},
        'sports_info': sportsList,
        'image_urls': uploadedUrls,
      };

      // 3. Register
      await ownerAuthAPi.registerOwner(
        name: name,
        email: email,
        mobile: mobile,
        password: password,
        metadata: turfMetadata,
      );

      isOwnerSignupLoading.value = false;
      Get.snackbar('Success', 'Registration successful!');
      Get.offAllNamed(RoutesName.turfOwnerLogin);
    } catch (e) {
      isOwnerSignupLoading.value = false;
      Get.snackbar('Registration Failed', e.toString());
    }
  }
}