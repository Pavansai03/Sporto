import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sporto/routes/routes_names.dart';

class VenueCard extends StatelessWidget {
  final Map<String, dynamic> ownerData; // Data passed from the Home Page list

  const VenueCard({super.key, required this.ownerData});

  @override
  Widget build(BuildContext context) {
    // Extract metadata for easier access
    final metadata = ownerData['metadata'] as Map<String, dynamic>;
    final List imageUrls = metadata['image_urls'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Pass the ownerData to the VenuePage via arguments
          Get.toNamed(RoutesName.VenuePage, arguments: ownerData);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue Image - Display the first image from Supabase Storage
            imageUrls.isNotEmpty
                ? Image.network(
              imageUrls[0], // Use the first uploaded image
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
                : _buildPlaceholder(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metadata['turf_name'] ?? "Turf Name", // Dynamic Name
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      Expanded(
                        child: Text(
                          " ${metadata['address'] ?? 'Location unavailable'}", // Dynamic Address
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.stadium_outlined, size: 50, color: Colors.grey),
    );
  }
}