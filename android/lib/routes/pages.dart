import 'package:get/get.dart';
import 'package:sporto/routes/routes_names.dart';
import 'package:sporto/screens/home.dart';
import 'package:sporto/screens/login.dart';
import 'package:sporto/screens/profile_page.dart';
import 'package:sporto/screens/register.dart';
import 'package:sporto/screens/venue_page.dart';
import 'package:sporto/screens/user_owner_toggle.dart';
import 'package:sporto/screens/owner/turf_owner_login.dart';
import 'package:sporto/screens/owner/turf_register.dart';
import 'package:sporto/screens/owner/owner_home.dart';
import 'package:sporto/controllers/owner/owner_auth_controller.dart';
import 'package:sporto/screens/turf_booking.dart';


class Pages {
  static final List<GetPage> pages = [
    GetPage(name: RoutesName.login, page: () => Login(),
    transition: Transition.rightToLeft,
    transitionDuration: Duration(microseconds: 400,
     )),
    GetPage(name: RoutesName.register, page: ()=> Register(),
    transition: Transition.rightToLeft,
    transitionDuration: Duration(microseconds: 400,
    )),
    GetPage(name: RoutesName.Home, page: ()=> Home()),
    GetPage(name: RoutesName.profilePage, page: ()=> ProfilePage()),
// Change line 27 in your pages.dart file
    GetPage(
      name: RoutesName.VenuePage,
      page: () => VenuePage(ownerData: Get.arguments), // Add this part
    ),
    GetPage(name: RoutesName.UserOwnerToggle, page: ()=> UserOwnerToggle(),
  transition: Transition.rightToLeft,
  transitionDuration: Duration(microseconds: 400,)),
  //   GetPage(name: RoutesName.turfRegistration, page: ()=> TurfRegistration(),
  // transition: Transition.rightToLeft,
  // transitionDuration: Duration(microseconds: 400,)),
    GetPage(name: RoutesName.turfOwnerLogin, page: ()=> TurfOwnerLogin(),),
    GetPage(name: RoutesName.turfRegister, page: ()=> TurfRegister(),),
// Inside Pages.pages list
    GetPage(
      name: RoutesName.ownerHome,
      page: () => const OwnerHome(),
      binding: BindingsBuilder(() {
        // This line creates the controller as soon as the page opens
        Get.lazyPut<OwnerAuthController>(() => OwnerAuthController());
      }),
    ),
    // In pages.dart
// Remove the 'ownerData: Get.arguments' part
    GetPage(
      name: RoutesName.turfBooking,
      page: () => const TurfBooking(), // <-- Change to this
    ),
  ];
}