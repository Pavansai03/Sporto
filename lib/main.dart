import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sporto/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sporto/utils/supabase_constants.dart';
import 'package:sporto/routes/routes_names.dart';
import 'package:sporto/routes/pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  await Supabase.initialize(
    url: URL,
    anonKey: ANON_KEY,
  );

  await GetStorage.init();
  Get.put(SupabaseService());

  // 2. Determine the initial route based on Auth session and Role
  final String initialRoute = await _getInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));
}

/// Logical check to find the correct landing page
Future<String> _getInitialRoute() async {
  final session = Supabase.instance.client.auth.currentSession;

  if (session == null) {
    return RoutesName.UserOwnerToggle;
  }

  final user = session.user;

  // --- ADD THESE PRINT STATEMENTS ---
  print("=== DEBUG LOG ===");
  print("User Email: ${user.email}");
  print("User Metadata: ${user.userMetadata}");
  print("=================");

  final String? role = user.userMetadata?['role'];

  if (role == 'owner') {
    return RoutesName.ownerHome;
  } else {
    return RoutesName.Home;
  }
}
class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // Use the dynamic initialRoute instead of a hardcoded one
      initialRoute: initialRoute,
      getPages: Pages.pages,
    );
  }
}