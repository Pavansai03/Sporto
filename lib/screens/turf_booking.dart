import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sporto/controllers/turf_booking_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sporto/routes/routes_names.dart';

class TurfBooking extends StatefulWidget {
  const TurfBooking({super.key});

  @override
  State<TurfBooking> createState() => _TurfBookingState();
}

class _TurfBookingState extends State<TurfBooking> {
  final TurfBookingController controller = Get.put(TurfBookingController());
  final String userName = Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ?? 'Player';

  Map<String, dynamic>? ownerData;
  Map<String, dynamic>? selectedSport;

  @override
  void initState() {
    super.initState();

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map<String, dynamic>;
      ownerData = args['ownerData'];
      selectedSport = args['selectedSport'];

      if (selectedSport != null) {
        controller.initSport(selectedSport!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ownerData == null || selectedSport == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Turf'), elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 10),
              const Text("Session data lost.", style: TextStyle(color: Colors.grey, fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => Get.offAllNamed(RoutesName.Home),
                child: const Text("Go Back Home", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    final metadata = ownerData!['metadata'] as Map<String, dynamic>;
    final String turfId = ownerData!['id'];

    return Scaffold(
      appBar: AppBar(title: const Text('Book Turf'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, $userName! 👋", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Booking at ${metadata['turf_name']}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Selected Sport", style: TextStyle(color: Colors.indigo, fontSize: 12)),
                      Text(selectedSport!['sport'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text("₹${selectedSport!['price_per_hr']} / hr", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) controller.selectedDate.value = date;
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: Obx(() => Text(controller.selectedDate.value == null
                        ? 'Pick Date'
                        : "${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}")),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        // Captures exact hours AND minutes
                        controller.selectedTime.value = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Obx(() => Text(controller.selectedTime.value ?? 'Pick Time')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Duration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.green),
                        onPressed: () => controller.decrementDuration(),
                      ),
                      Obx(() => Text(
                        "${controller.durationHours.value} hr${controller.durationHours.value > 1 ? 's' : ''}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () => controller.incrementDuration(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Price", style: TextStyle(color: Colors.grey)),
                      Obx(() => Text("₹${controller.totalPrice.value}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: controller.isLoading.value ? null : () => controller.bookTurf(turfId),
                    child: controller.isLoading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 16)),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}