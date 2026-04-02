import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerAuthApi {
  final SupabaseClient supabaseClient;
  OwnerAuthApi(this.supabaseClient);

  /// Signs out the current user and clears the session
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An unexpected error occurred during sign out.");
    }
  }

  /// Handles owner login with strict role-based access control
  Future<AuthResponse> login(String identifier, String password) async {
    try {
      final bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(identifier);

      final AuthResponse response = await supabaseClient.auth.signInWithPassword(
        email: isEmail ? identifier : null,
        phone: !isEmail ? identifier : null,
        password: password,
      );

      // 1. Verify user role to prevent unauthorized access
      final userRole = response.user?.userMetadata?['role'];

      if (userRole != 'owner') {
        // Force sign out if the user is not an owner
        await signOut(); // Reuse the signOut method
        throw Exception("Access Denied: This account is not registered as a Turf Owner.");
      }

      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An unexpected error occurred during login.");
    }
  }

  /// Registers a new owner and turf details
  Future<void> registerOwner({
    required String name,
    required String mobile,
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      // 2. Consolidate all data including the 'owner' role
      final Map<String, dynamic> signUpData = {
        'name': name,
        'mobile': mobile,
        'role': 'owner',
        ...metadata,
      };

      await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: signUpData,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Registration failed. Please try again.");
    }
  }
}