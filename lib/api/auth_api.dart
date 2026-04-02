import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthApi {
  final SupabaseClient supabaseClient;
  AuthApi(this.supabaseClient);

  // login with email OR mobile
  Future<AuthResponse> login(String identifier, String password) async {
    // Simple regex to check if the input is an email
    final bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(identifier);

    if (isEmail) {
      // Log in with Email
      return await supabaseClient.auth.signInWithPassword(
          email: identifier,
          password: password
      );
    } else {
      // Log in with Phone Number
      // Note: Supabase usually requires phone numbers in E.164 format (e.g., +919876543210)
      return await supabaseClient.auth.signInWithPassword(
          phone: identifier,
          password: password
      );
    }
  }

  // signup
  Future<AuthResponse> signup(String name, String mobile, String email, String password) async {
    return await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'mobile': mobile}
    );
  }

  //Google signin
  Future<AuthResponse?> googleSignIn() async {
    const webClientId = '692022723863-bp5abls77i6oheo2do3a0lqi5r199bbj.apps.googleusercontent.com';

    // 1. In v7+, we must use the instance singleton
    final GoogleSignIn signIn = GoogleSignIn.instance;

    try {
      // 2. Initialize must be awaited before authenticating
      await signIn.initialize(serverClientId: webClientId);

      // 3. authenticate() is the v7 method.
      // NOTE: If the user cancels the popup, this throws a GoogleSignInException
      final googleAccount = await signIn.authenticate();

      // 4. Get the authorization (for accessToken) and authentication (for idToken)
      final googleAuthorization = await googleAccount.authorizationClient.authorizationForScopes(['email', 'profile']);      final googleAuthentication = googleAccount.authentication; // Synchronous in v7

      final idToken = googleAuthentication.idToken;
      final accessToken = googleAuthorization?.accessToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 5. Sign in to Supabase
      return await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

    } on GoogleSignInException catch (e) {
      // This safely catches the user closing the sign-in modal
      print('Google Sign-In canceled or failed: $e');
      return null;
    } catch (e) {
      print('Unexpected error during Google Sign-In: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}