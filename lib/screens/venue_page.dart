import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sporto/api/maps_api.dart';
import 'package:get/get.dart'; // Added GetX import
import 'package:sporto/routes/routes_names.dart'; // Added Routes import
import 'package:sporto/screens/embedded_map_screen.dart';

class VenuePage extends StatefulWidget {
  final Map<String, dynamic> ownerData;
  const VenuePage({super.key, required this.ownerData});

  @override
  State<VenuePage> createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract metadata for cleaner access
    final metadata = widget.ownerData['metadata'] as Map<String, dynamic>;
    final List imageList = metadata['image_urls'] ?? [];
    final List sportsInfo = metadata['sports_info'] ?? [];
    final Map location = metadata['location'] ?? {'lat': 0.0, 'lng': 0.0};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          metadata['turf_name'] ?? "Turf Details",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Dynamic Image Carousel with Navigators
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: imageList.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        imageList[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      );
                    },
                  ),
                ),
                // Left Arrow Button
                Positioned(
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
                // Right Arrow Button
                Positioned(
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 2. Dynamic Timings and Price Table with Shadow/Elevation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Stronger shadow for elevation
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.indigo[50]),
                    columns: _buildTableColumns(),
                    rows: sportsInfo.map((sport) {
                      return DataRow(
                        cells: [
                          DataCell(Text(sport['sport'].toString(), style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Text(sport['timings'].toString())),
                          DataCell(Text('₹${sport['price_per_hr']} /hr')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 3. Dynamic Location Section with Map Overlay Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(metadata['address'] ?? 'No address provided', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 12),

                    // Interactive Map with "Open in Maps" Overlay
                    Stack(
                      children: [
                        _buildInteractiveMap(location, metadata['turf_name']),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // 🔥 THE FIX: Route to the internal map screen instead of launching externally
                              Get.to(() => EmbeddedMapScreen(
                                latitude: location['lat'].toDouble(),
                                longitude: location['lng'].toDouble(),
                                turfName: metadata['turf_name'] ?? 'Turf Location',
                              ));
                            },
                            icon: const Icon(Icons.fullscreen, size: 18), // Changed icon to suggest 'expand'
                            label: const Text('View Full Map'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.indigo[700], // Changed to match your theme
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 4. Book Now Button
            _buildBookNowButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns() => const [
    DataColumn(label: Text('SPORT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
    DataColumn(label: Text('TIMINGS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
    DataColumn(label: Text('PRICE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
  ];

  Widget _buildInteractiveMap(Map coords, String? turfName) {
    final LatLng position = LatLng(coords['lat'], coords['lng']);
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 15),
          markers: {Marker(markerId: const MarkerId('turf_loc'), position: position, infoWindow: InfoWindow(title: turfName))},
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _buildBookNowButton() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(61, 205, 22, 1.0),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () {
        // Open the bottom sheet instead of navigating immediately
        _showSportsSelectionBottomSheet(context);
      },
      child: const Text('Book now', style: TextStyle(fontSize: 20)),
    ),
  );

  // The new Bottom Sheet Method
  void _showSportsSelectionBottomSheet(BuildContext context) {
    final metadata = widget.ownerData['metadata'] as Map<String, dynamic>;
    final List sportsInfo = metadata['sports_info'] ?? [];

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content height
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                      "Select a Sport to Book",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
                const Divider(height: 1),
                ...sportsInfo.map((sport) {
                  return ListTile(
                    title: Text(sport['sport'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("₹${sport['price_per_hr']} / hr"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                    onTap: () {
                      // 1. Close the bottom sheet
                      Get.back();

                      // 2. Navigate to booking page, passing BOTH the turf data and the specific sport
                      Get.toNamed(RoutesName.turfBooking, arguments: {
                        'ownerData': widget.ownerData,
                        'selectedSport': sport,
                      });
                    },
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          );
        }
    );
  }
}