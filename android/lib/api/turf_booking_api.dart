import 'package:supabase_flutter/supabase_flutter.dart';

class TurfBookingApi {
  final SupabaseClient supabase = Supabase.instance.client;

  // 1. Check if the slot overlaps with any existing booking for the SAME sport
  Future<bool> isSlotAvailable({
    required String turfId,
    required String date,
    required String startTime,
    required String endTime,
    required String sportName,
  }) async {

    final response = await supabase
        .from('bookings')
        .select('id, sports_selected')
        .eq('turf_id', turfId)
        .eq('booking_date', date)
        .eq('status', 'confirmed')
    // The overlap math:
        .lt('start_time', endTime)   // Existing start must be LESS THAN requested end
        .gt('end_time', startTime);  // Existing end must be GREATER THAN requested start

    // If no overlapping times are found, it's completely free
    if (response.isEmpty) return true;

    // If times overlap, check if they are trying to play the SAME sport
    for (var booking in response) {
      List sports = booking['sports_selected'] as List;
      bool sportAlreadyBooked = sports.any((s) => s['sport'] == sportName);

      if (sportAlreadyBooked) {
        return false; // The specific sport is taken!
      }
    }

    return true; // The time overlaps, but for a DIFFERENT sport.
  }

  // 2. Insert the actual booking
  Future<void> createBooking({
    required String turfId,
    required String date,
    required String startTime,
    required String endTime,
    required List<Map<String, dynamic>> sports,
    required int totalPrice,
  }) async {
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('bookings').insert({
      'turf_id': turfId,
      'user_id': userId,
      'booking_date': date,
      'start_time': startTime,
      'end_time': endTime,
      'sports_selected': sports,
      'total_price': totalPrice,
    });
  }
}