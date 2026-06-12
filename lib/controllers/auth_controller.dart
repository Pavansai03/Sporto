import 'package:get/get.dart';
import 'package:sporto/api/auth_api.dart';
import 'package:sporto/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sporto/routes/routes_names.dart';
import 'package:sporto/utils/storage_constants.dart'; // Make sure to import this to save/remove tokens!

class AuthController extends GetxController {

  late AuthApi authApi;
  RxBool isLoginLoading = false.obs;
  RxBool isSignupLoading = false.obs;
  RxBool isGoogleSigninLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    authApi = AuthApi(SupabaseService.supabase);
  }

  // login
  void login(String email, String password) async {
    try {
      isLoginLoading.value = true;
      final AuthResponse response = await authApi.login(email, password);
      isLoginLoading.value = false;

      print('Logged in successfully');

      // // 1. Save the token (Optional, but good if you want to keep them logged in)
      // if (response.session != null) {
      //   StorageConstants.box.write(StorageConstants.authkey, response.session!.accessToken);
      // }

    } catch (e) {
      isLoginLoading.value = false;
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      print('Login Error: $e');
    }
  }

  // signup
  void signup(String name, String mobile, String email, String password) async {
    try {
      isSignupLoading.value = true;

      final AuthResponse response = await authApi.signup(name, mobile, email, password);

      isSignupLoading.value = false;

      if(response.user != null) {
        print('User registered successfully');
        Get.snackbar('Success', 'Registration successful!');
        Get.offAllNamed(RoutesName.login);
      } else {
        Get.snackbar('Notice', 'Please check your email to verify your account.');
      }

    } on AuthException catch (e) {
      isSignupLoading.value = false;
      Get.snackbar('Signup Failed', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      isSignupLoading.value = false;
      Get.snackbar('Error', 'Something went wrong: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  //google signin
  void googleSignIn() async {
    try {
      isGoogleSigninLoading.value = true;

      // Await the response from your API
      final AuthResponse? response = await authApi.googleSignIn();

      isGoogleSigninLoading.value = false;

      // 1. Check if user canceled (response is null)
      if (response == null) {
        print('Google Sign-In canceled by user.');
        return; // Exit silently
      }

      // 2. Check for successful login
      if (response.user != null) {
        print('Google Sign-In successful');
        Get.snackbar(
            'Success',
            'Logged in with Google!',
            snackPosition: SnackPosition.TOP
        );

        // Redirect to Home Page
        Get.offAllNamed(RoutesName.Home);
      }

    } on AuthException catch (e) {
      isGoogleSigninLoading.value = false;
      Get.snackbar('Auth Error', e.message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      isGoogleSigninLoading.value = false;
      Get.snackbar('Error', 'Google Sign-In failed: $e', snackPosition: SnackPosition.TOP);
      print('Google Sign-In Error: $e');
    }
  }

  // signOut
  void signOut() async {
    try {
      // 1. Tell Supabase to end the session
      await authApi.signOut();

      // 2. Remove the saved token
      // StorageConstants.box.remove(StorageConstants.authkey);

      print('Logged out successfully');

      // 3. Redirect back to Login Page
      // Get.offAllNamed(RoutesName.login);

    } catch (e) {
      Get.snackbar('Error', 'Failed to log out: $e', snackPosition: SnackPosition.BOTTOM);
      print('Signout Error: $e');
    }
  }
}