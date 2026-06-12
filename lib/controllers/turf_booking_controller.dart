import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sporto/api/turf_booking_api.dart';

class TurfBookingController extends GetxController {
  final TurfBookingApi api = TurfBookingApi();

  var isLoading = false.obs;
  var selectedDate = Rxn<DateTime>();
  var selectedTime = Rxn<String>();
  var totalPrice = 0.obs;
  var durationHours = 1.obs;

  late Map<String, dynamic> currentSport;

  void initSport(Map<String, dynamic> sport) {
    currentSport = sport;
    _calculateTotal();
  }

  void incrementDuration() {
    if (durationHours.value < 12) {
      durationHours.value++;
      _calculateTotal();
    }
  }

  void decrementDuration() {
    if (durationHours.value > 1) {
      durationHours.value--;
      _calculateTotal();
    }
  }

  void _calculateTotal() {
    int price = int.parse(currentSport['price_per_hr'].toString());
    totalPrice.value = price * durationHours.value;
  }

  Future<void> bookTurf(String turfId) async {
    if (selectedDate.value == null || selectedTime.value == null) {
      Get.snackbar('Error', 'Please select a date and time.');
      return;
    }

    try {
      isLoading.value = true;

      // 1. Format Date
      String formattedDate = "${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}";

      // 2. Format Start & End Time
      String startTime = selectedTime.value!;
      int startHour = int.parse(startTime.split(':')[0]);
      String startMinute = startTime.split(':')[1];

      int endHour = (startHour + durationHours.value) % 24;
      String endTime = "${endHour.toString().padLeft(2, '0')}:$startMinute:00";

      // 3. Check Availability
      bool isAvailable = await api.isSlotAvailable(
        turfId: turfId,
        date: formattedDate,
        startTime: startTime,
        endTime: endTime,
        sportName: currentSport['sport'],
      );

      if (!isAvailable) {
        Get.snackbar(
          'Slot Unavailable',
          'Sorry, ${currentSport['sport']} is already booked during this time!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        isLoading.value = false; // Stop loading since we are staying on this page
        return;
      }

      // 4. Create Booking
      await api.createBooking(
        turfId: turfId,
        date: formattedDate,
        startTime: startTime,
        endTime: endTime,
        sports: [currentSport],
        totalPrice: totalPrice.value,
      );

      // 🔥 FIX 1: Navigate BACK first to close the booking page
      Get.back();

      // 🔥 FIX 2: Show the snackbar AFTER navigating, so it appears beautifully on the Venue Page
      Get.snackbar(
        'Success',
        'Turf booked successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );

    } catch (e) {
      // 🔥 FIX 3: Only set isLoading to false if an error happens and we don't navigate
      isLoading.value = false;
      Get.snackbar('Error', 'Booking failed: $e');
    }
    // Notice we completely removed the "finally" block!
  }
}