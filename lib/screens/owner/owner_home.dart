import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:sporto/controllers/owner/owner_auth_controller.dart';
import 'package:sporto/controllers/owner/owner_home_controller.dart';
import 'package:sporto/common/sporto_title.dart';

class OwnerHome extends StatelessWidget {
  const OwnerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final OwnerHomeController controller = Get.put(OwnerHomeController());
    final OwnerAuthController authController = Get.find<OwnerAuthController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.3, 0.8],
                colors: [Color.fromRGBO(61, 205, 22, 1.0), Colors.black, Colors.black],
              ),
            ),
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                    child: Row(
                      children: [
                        const SportoTitle(),
                        const Spacer(),
                        IconButton(
                          icon: const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.logout, color: Colors.white, size: 20),
                          ),
                          onPressed: () => _showLogoutDialog(authController),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator(color: Colors.green));
                      }
                      return _buildDashboardContent(controller);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(OwnerHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello, ${controller.ownerName.value}!",
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const Text("Manage your turf bookings below",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 20),

              // --- DYNAMIC REVENUE SUMMARY ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Revenue", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),

                        Row(
                          children: [
                            // Sport Filter Dropdown
                            Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.selectedSportFilter.value,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green, size: 14),
                                  style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                  items: controller.availableSports.map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  )).toList(),
                                  onChanged: (newValue) => controller.selectedSportFilter.value = newValue!,
                                ),
                              ),
                            ),
                            // Time Filter Dropdown
                            Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.selectedRevenueFilter.value,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green, size: 14),
                                  style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                  items: ['Today', '1 Week', 'This Month', 'All Time']
                                      .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                                      .toList(),
                                  onChanged: (newValue) => controller.selectedRevenueFilter.value = newValue!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("₹${controller.filteredSportRevenue}",
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
                        if (controller.selectedSportFilter.value != 'All Sports')
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 6),
                            child: Text("/ ₹${controller.totalOverallRevenue} Total",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        const TabBar(
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          indicatorWeight: 3,
          tabs: [
            Tab(text: "Upcoming"),
            Tab(text: "History"),
          ],
        ),

        Expanded(
          child: TabBarView(
            children: [
              // Tab 1: Upcoming Bookings (WITH SPORT DROPDOWN)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20, top: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedUpcomingSportFilter.value,
                            icon: const Icon(Icons.filter_list, size: 16, color: Colors.grey),
                            style: TextStyle(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                            items: controller.availableSports
                                .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                                .toList(),
                            onChanged: (newValue) => controller.selectedUpcomingSportFilter.value = newValue!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildBookingList(controller.filteredUpcomingBookings, controller, "No upcoming bookings for this sport."),
                  ),
                ],
              ),

              // Tab 2: Past Bookings (History with Dropdown)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20, top: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedHistoryFilter.value,
                            icon: const Icon(Icons.filter_list, size: 16, color: Colors.grey),
                            style: TextStyle(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                            items: ['Today', '1 Week', 'This Month', 'All Time']
                                .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                                .toList(),
                            onChanged: (newValue) => controller.selectedHistoryFilter.value = newValue!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildBookingList(controller.filteredPastBookings, controller, "No history for this period."),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 NEW: Wrapped in RefreshIndicator so you can swipe down to update
  Widget _buildBookingList(List<Map<String, dynamic>> bookings, OwnerHomeController controller, String emptyMessage) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        color: Colors.green,
        onRefresh: () => controller.fetchOwnerDashboardData(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: Get.height * 0.3),
            Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: () => controller.fetchOwnerDashboardData(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index], controller);
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, OwnerHomeController controller) {
    final bookingId = booking['id'].toString();
    final customerMeta = booking['users']?['metadata'] ?? {};
    final customerName = customerMeta['name'] ?? customerMeta['full_name'] ?? 'Unknown Customer';
    final sportsList = booking['sports_selected'] as List? ?? [];
    final sportName = sportsList.isNotEmpty ? sportsList[0]['sport'] : 'Turf Booking';
    final rawTime = booking['start_time'].toString().substring(0, 5);
    final formattedTime = _formatTo12Hour(rawTime);

    // Date & Time Logic
    final bookingDateTime = DateTime.parse('${booking['booking_date']} ${booking['start_time']}');
    final endDateStr = booking['end_time'] != null ? '${booking['booking_date']} ${booking['end_time']}' : '';
    final endDateTime = endDateStr.isNotEmpty ? DateTime.parse(endDateStr) : bookingDateTime.add(const Duration(hours: 1));

    final now = DateTime.now();
    final isPast = endDateTime.isBefore(now);

    // 🔥 NEW: Check if this match is currently active
    final isHappeningNow = now.isAfter(bookingDateTime) && now.isBefore(endDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Gives a very subtle green tint if it's currently live
        color: isHappeningNow ? Colors.green.shade50 : (isPast ? Colors.grey[50] : Colors.white),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          // Border turns green if live
            color: isHappeningNow ? Colors.green.shade400 : (isPast ? Colors.grey.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.3))
        ),
        boxShadow: [
          if (!isPast)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(sportName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isPast ? Colors.grey[700] : Colors.black)),

                  // 🔥 NEW: Red 'LIVE' badge
                  if (isHappeningNow)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                ],
              ),
              Text("₹${booking['total_price']}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPast ? Colors.grey : Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: isPast ? Colors.grey : Colors.indigo),
              const SizedBox(width: 6),
              Text(customerName, style: TextStyle(color: isPast ? Colors.grey[600] : Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text("${booking['booking_date']} at $formattedTime", style: TextStyle(color: isPast ? Colors.grey : Colors.black87)),
                ],
              ),

              if (!isPast)
                Obx(() {
                  final isAlreadyAdded = controller.addedAlerts.contains(bookingId);

                  return InkWell(
                    onTap: () async {
                      if (isAlreadyAdded) {
                        Get.snackbar(
                          'Re-opening Calendar',
                          'You clicked this before. Opening again just in case you forgot to save!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(10),
                        );
                      }

                      try {
                        final Event event = Event(
                          title: '$sportName Booking: $customerName',
                          description: 'Customer: $customerName\nRevenue: ₹${booking['total_price']}\nStatus: Confirmed',
                          startDate: bookingDateTime,
                          endDate: endDateTime,
                        );

                        final success = await Add2Calendar.addEvent2Cal(event);

                        if (success) {
                          controller.addedAlerts.add(bookingId);
                        } else {
                          Get.snackbar(
                            'Calendar Error',
                            'Could not open calendar. Do you have a calendar app installed?',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        Get.snackbar('Error', 'Failed to create event: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAlreadyAdded ? Colors.grey.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isAlreadyAdded ? Colors.grey.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(isAlreadyAdded ? Icons.check_circle_outline : Icons.notification_add,
                              size: 14,
                              color: isAlreadyAdded ? Colors.grey.shade600 : Colors.green),
                          const SizedBox(width: 6),
                          Text(isAlreadyAdded ? "Added" : "Add Alert",
                              style: TextStyle(color: isAlreadyAdded ? Colors.grey.shade600 : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTo12Hour(String time) {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $ampm';
    } catch (e) {
      return time;
    }
  }

  void _showLogoutDialog(OwnerAuthController auth) {
    Get.dialog(
      AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => auth.signOut(),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}