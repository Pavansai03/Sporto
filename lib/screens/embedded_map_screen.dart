import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class EmbeddedMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String turfName;

  const EmbeddedMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.turfName = 'Turf Location',
  });

  @override
  State<EmbeddedMapScreen> createState() => _EmbeddedMapScreenState();
}

class _EmbeddedMapScreenState extends State<EmbeddedMapScreen> {
  late GoogleMapController mapController;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool isLoadingRoute = false;

  // 🔥 IMPORTANT: Paste your exact Google Maps API Key here
  final String googleApiKey = "AIzaSyBhPbjMiq_DVP4OW62WZGYCY_EBwW9rw7M";

  @override
  void initState() {
    super.initState();
    // Add the turf destination marker initially
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(title: widget.turfName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // --- GET LOCATION & DRAW ROUTE ---
  Future<void> _drawRoute() async {
    setState(() => isLoadingRoute = true);

    try {
      // 1. Get User's Current Location
      Position position = await _determinePosition();
      LatLng origin = LatLng(position.latitude, position.longitude);
      LatLng destination = LatLng(widget.latitude, widget.longitude);

      // Add a marker for the user's current location
      setState(() {
        markers.add(
          Marker(
            markerId: const MarkerId('origin'),
            position: origin,
            infoWindow: const InfoWindow(title: 'You are here'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });

      // 2. Fetch Polyline Points from Google Directions API
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleApiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      // 3. Draw Polyline on Map
      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = [];
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blueAccent, // Color of the route line
              points: polylineCoordinates,
              width: 5, // Thickness of the route line
            ),
          );
        });

        // 4. Adjust camera bounds to fit the whole route on screen
        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(
            origin.latitude < destination.latitude ? origin.latitude : destination.latitude,
            origin.longitude < destination.longitude ? origin.longitude : destination.longitude,
          ),
          northeast: LatLng(
            origin.latitude > destination.latitude ? origin.latitude : destination.latitude,
            origin.longitude > destination.longitude ? origin.longitude : destination.longitude,
          ),
        );
        mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      } else {
        Get.snackbar('Route Error', result.errorMessage ?? 'Could not find a route.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => isLoadingRoute = false);
    }
  }

  // --- GEOLOCATION PERMISSIONS HELPER ---
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Please turn on your GPS.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied. Please enable in settings.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turfName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // The Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: 15.0,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true, // Shows the blue dot for the user's location
            myLocationButtonEnabled: true,
          ),

          // Floating Directions Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              onPressed: isLoadingRoute ? null : _drawRoute,
              icon: isLoadingRoute
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.directions, size: 24),
              label: Text(
                  isLoadingRoute ? "Calculating Route..." : "Get Directions",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
}