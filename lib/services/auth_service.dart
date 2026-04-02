import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabaseClient;

  AuthService({required this.supabaseClient});

  // get user name
  String get userName {
    return supabaseClient.auth.currentUser
        ?.userMetadata?['name']
        ?.toString() ?? 'No Name';
  }

  // get email
  String get userEmail {
    return supabaseClient.auth.currentUser
        ?.email ?? 'No Email';
  }
}
