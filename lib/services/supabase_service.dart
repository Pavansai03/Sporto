import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sporto/routes/routes_names.dart';
import 'package:sporto/utils/storage_constants.dart';

class SupabaseService extends GetxService {
  @override
  void onInit() {
    super.onInit();
    listenAuthChange();
  }

  static final SupabaseClient supabase = Supabase.instance.client;

  //to listen auth events
  void listenAuthChange() {
    SupabaseService.supabase.auth.onAuthStateChange.listen(
          (data) {
        final event = data.event;
        final session = data.session;

        // 1. Intercept the Sign In event
        if (event == AuthChangeEvent.signedIn && session != null) {
          StorageConstants.box.write(
            StorageConstants.authkey,
            session.accessToken,
          );

          // 2. Read the user's role from their metadata
          final user = session.user;
          final String? role = user.userMetadata?['role'];

          // 3. Route them to their correct respective dashboards
          if (role == 'owner') {
            Get.offAllNamed(RoutesName.ownerHome); // Route for Turf Owners
          } else {
            Get.offAllNamed(RoutesName.Home);
          }
        }

        if (event == AuthChangeEvent.signedOut) {
          StorageConstants.box.remove(StorageConstants.authkey);
          Get.offAllNamed(RoutesName.UserOwnerToggle);
        }
      },
    );
  }
}