import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerHomeController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var ownerName = ''.obs;

  // Bookings lists
  var upcomingBookings = <Map<String, dynamic>>[].obs;
  var pastBookings = <Map<String, dynamic>>[].obs;

  // Revenue & History Dropdown selections
  var selectedRevenueFilter = 'This Month'.obs;
  var selectedHistoryFilter = 'This Month'.obs;

  // Sport Filter Dropdowns
  var selectedSportFilter = 'All Sports'.obs;
  var selectedUpcomingSportFilter = 'All Sports'.obs;
  var availableSports = <String>['All Sports'].obs;

  // 🔥 Tracks which bookings have been added to the calendar
  var addedAlerts = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOwnerDashboardData();
  }

  Future<void> fetchOwnerDashboardData() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;

      if (user != null) {
        ownerName.value = user.userMetadata?['name'] ?? 'Owner';

        // 1. Fetch the owner's turf profile to get ALL available sports
        Set<String> sportsSet = {'All Sports'};
        final ownerResponse = await supabase.from('owners').select('metadata').eq('id', user.id).maybeSingle();

        if (ownerResponse != null && ownerResponse['metadata'] != null) {
          final sportsInfo = ownerResponse['metadata']['sports_info'] as List? ?? [];
          for (var sport in sportsInfo) {
            if (sport['sport'] != null) {
              sportsSet.add(sport['sport'].toString());
            }
          }
        }

        // 2. Fetch all bookings
        final response = await supabase
            .from('bookings')
            .select('*, users(metadata)')
            .eq('turf_id', user.id)
            .order('booking_date', ascending: false)
            .order('start_time', ascending: false);

        final now = DateTime.now();
        List<Map<String, dynamic>> tempUpcoming = [];
        List<Map<String, dynamic>> tempPast = [];

        for (var booking in response) {
          final dateStr = booking['booking_date'];
          final timeStr = booking['start_time'].toString();
          final bookingDateTime = DateTime.parse('$dateStr $timeStr');

          if (bookingDateTime.isAfter(now)) {
            tempUpcoming.add(booking);
          } else {
            tempPast.add(booking);
          }
        }

        // Sort upcoming bookings so the soonest match is at the top
        tempUpcoming.sort((a, b) {
          final aDate = DateTime.parse('${a['booking_date']} ${a['start_time']}');
          final bDate = DateTime.parse('${b['booking_date']} ${b['start_time']}');
          return aDate.compareTo(bDate);
        });

        upcomingBookings.assignAll(tempUpcoming);
        pastBookings.assignAll(tempPast);
        availableSports.assignAll(sportsSet.toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- REVENUE CALCULATION ENGINE ---
  int _calculateRevenue({required bool filterBySport}) {
    final allBookings = [...upcomingBookings, ...pastBookings];
    final now = DateTime.now();
    int total = 0;

    for (var booking in allBookings) {
      final bookingDate = DateTime.parse(booking['booking_date']);
      bool timeInclude = false;

      if (selectedRevenueFilter.value == 'Today') {
        if (bookingDate.year == now.year && bookingDate.month == now.month && bookingDate.day == now.day) {
          timeInclude = true;
        }
      } else if (selectedRevenueFilter.value == '1 Week') {
        if (now.difference(bookingDate).inDays <= 7) timeInclude = true;
      } else if (selectedRevenueFilter.value == 'This Month') {
        if (bookingDate.year == now.year && bookingDate.month == now.month) timeInclude = true;
      } else {
        timeInclude = true; // All Time
      }

      if (!timeInclude) continue;

      if (filterBySport && selectedSportFilter.value != 'All Sports') {
        final sportsList = booking['sports_selected'] as List? ?? [];
        final sportName = sportsList.isNotEmpty ? sportsList[0]['sport'].toString() : '';
        if (sportName != selectedSportFilter.value) continue;
      }

      total += (booking['total_price'] as int? ?? 0);
    }
    return total;
  }

  int get filteredSportRevenue => _calculateRevenue(filterBySport: true);
  int get totalOverallRevenue => _calculateRevenue(filterBySport: false);

  // --- DYNAMIC UPCOMING FILTERING ---
  List<Map<String, dynamic>> get filteredUpcomingBookings {
    if (selectedUpcomingSportFilter.value == 'All Sports') {
      return upcomingBookings;
    }
    return upcomingBookings.where((booking) {
      final sportsList = booking['sports_selected'] as List? ?? [];
      final sportName = sportsList.isNotEmpty ? sportsList[0]['sport'].toString() : '';
      return sportName == selectedUpcomingSportFilter.value;
    }).toList();
  }

  // --- DYNAMIC HISTORY FILTERING ---
  List<Map<String, dynamic>> get filteredPastBookings {
    final now = DateTime.now();

    return pastBookings.where((booking) {
      final bookingDate = DateTime.parse(booking['booking_date']);

      if (selectedHistoryFilter.value == 'Today') {
        return bookingDate.year == now.year && bookingDate.month == now.month && bookingDate.day == now.day;
      } else if (selectedHistoryFilter.value == '1 Week') {
        return now.difference(bookingDate).inDays <= 7;
      } else if (selectedHistoryFilter.value == 'This Month') {
        return bookingDate.year == now.year && bookingDate.month == now.month;
      }
      return true; // All Time
    }).toList();
  }
}