import 'package:url_launcher/url_launcher.dart';

class MapsApi {
  static Future<void> openMap(double latitude, double longitude) async {
    // Construct the URL for Google Maps (works on both Android and iOS)
    // 'q' stands for query/location
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    // Convert String to Uri object
    Uri uri = Uri.parse(googleUrl);

    // Check if the device can handle the URL and launch it
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }
}