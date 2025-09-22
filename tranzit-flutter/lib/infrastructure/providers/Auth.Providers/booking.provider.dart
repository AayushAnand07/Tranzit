import 'package:flutter/material.dart';
import 'package:tranzit/infrastructure/providers/Auth.Providers/route.provider.dart';
import 'package:tranzit/infrastructure/services/booking.service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
final RouteProvider routeProvider = RouteProvider();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _qrPayload;
  String? get qrPayload => _qrPayload;

  bool? _isVerified;
  bool? get isVerified=> _isVerified;

  List<Map<String, dynamic>> _bookingHistory = [];
  List<Map<String, dynamic>> get BookingHistory => _bookingHistory;


  Future<void> fetchTicketBookingResponse({
    required int vehicleId,
    required int fromStopName,
    required int toStopName,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookingService.postTicketBookingDetails(
        vehicleId: vehicleId,
        fromStopId:fromStopName,
        toStopId: toStopName,
        userId: userId,
      );

      if (response['success'] == true) {
        _qrPayload = response['qrPayload'];
        print("Ticket booked successfully, QR Payload: $_qrPayload");
      } else {
        throw Exception(response['error'] ?? 'Booking failed');
      }
    } catch (e) {
      print("Error booking ticket: $e");
      _qrPayload = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyTicketCheckIn({required int ticketID,required bool isCheckInMode}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookingService.VerifyCheckIn(ticketId: ticketID,isCheckedIn: isCheckInMode);

      if (response['success'] == true) {
        _isVerified = true;
        return true;
      } else {
        _isVerified = false;
        return false;
      }
    } catch (e) {
      print("Error verifying ticket: $e");
      _isVerified = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> fetchAllTickets() async {
    _isLoading = true;
    notifyListeners();

    try {

      final response = await _bookingService.FetchAllTickets();
      _bookingHistory=List<Map<String,dynamic>>.from(response);

    } catch (e) {
      print("Error fetching booking history for user: $e");
      _bookingHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }





}
