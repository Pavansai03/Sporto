import 'package:flutter/material.dart';
import 'package:sporto/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:sporto/common/cards/venue_card.dart';
import 'package:flutter/services.dart';
import 'package:sporto/common/sporto_title.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sporto/routes/routes_names.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthController controller = Get.put(AuthController());

  // 🔥 NEW: Added a controller to easily clear the text when switching filters
  final TextEditingController _searchController = TextEditingController();

  // State variables for search
  String _searchQuery = '';
  String _searchFilter = 'Venue'; // Defaults to searching by Venue

  // Stream to fetch owners in real-time
  final Stream<List<Map<String, dynamic>>> _venuesStream =
  Supabase.instance.client.from('owners').stream(primaryKey: ['id']);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3, 0.8],
              colors: [
                Color.fromRGBO(61, 205, 22, 1.0),
                Colors.black,
                Colors.black,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const SportoTitle(),
              centerTitle: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.3),
                  height: 1.0,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    onPressed: () => Get.toNamed(RoutesName.profilePage),
                  ),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),

                // --- Dynamical Venue Section ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _venuesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.green));
                        }

                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyStateWrapper("No venues available right now");
                        }

                        final allVenues = snapshot.data!;

                        // 🔥 NEW: Dynamic Filtering Logic based on the chosen category
                        final filteredVenues = _searchQuery.isEmpty
                            ? allVenues
                            : allVenues.where((venue) {
                          final metadata = venue['metadata'] as Map<String, dynamic>? ?? {};

                          if (_searchFilter == 'Venue') {
                            // 1. Search by Turf Name or Location
                            final turfName = (metadata['turf_name'] ?? '').toString().toLowerCase();
                            final address = (metadata['address'] ?? '').toString().toLowerCase();
                            return turfName.contains(_searchQuery) || address.contains(_searchQuery);

                          } else {
                            // 2. Search by Sport
                            final sportsInfo = metadata['sports_info'] as List? ?? [];
                            for (var sportObj in sportsInfo) {
                              final sportName = (sportObj['sport'] ?? '').toString().toLowerCase();
                              if (sportName.contains(_searchQuery)) {
                                return true; // Match found! Include this venue.
                              }
                            }
                            return false; // No matching sport found at this venue.
                          }
                        }).toList();

                        if (filteredVenues.isEmpty) {
                          return _buildEmptyStateWrapper("No venues match your search");
                        }

                        return RefreshIndicator(
                          color: Colors.green,
                          onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(15),
                            itemCount: filteredVenues.length,
                            itemBuilder: (context, index) {
                              return VenueCard(ownerData: filteredVenues[index]);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const Text(
            'Discover venues in Nagpur',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildSearchBar(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 🔥 NEW: Beautiful embedded selector inside the Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // 1. The Category Dropdown
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 4.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _searchFilter,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green, size: 18),
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                items: ['Venue', 'Sport'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _searchFilter = newValue!;
                    // Clear the search box when switching categories for better UX
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              ),
            ),
          ),

          // Small vertical divider line
          Container(height: 24, width: 1, color: Colors.grey.shade300),

          // 2. The Text Field
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                // Dynamic hint text based on selection
                hintText: _searchFilter == 'Venue'
                    ? 'Search turf, location...'
                    : 'Search cricket, football...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWrapper(String message) {
    return RefreshIndicator(
      color: Colors.green,
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stadium_outlined, size: 60, color: Colors.grey),
              const SizedBox(height: 10),
              Text(message, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}