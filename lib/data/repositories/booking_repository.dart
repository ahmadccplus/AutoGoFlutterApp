import '../../core/network/api_client.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final ApiClient _apiClient = ApiClient();

  Future<BookingModel> createBooking({
    required int carId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
    required double securityDeposit,
  }) async {
    final response = await _apiClient.post(
      '/bookings',
      data: {
        'car_id': carId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'total_price': totalPrice,
        'security_deposit': securityDeposit,
      },
    );
    return BookingModel.fromJson(response.data['booking'] as Map<String, dynamic>);
  }

  Future<BookingModel> getBookingById(int id) async {
    final response = await _apiClient.get('/bookings/$id');
    return BookingModel.fromJson(response.data['booking'] as Map<String, dynamic>);
  }

  Future<List<BookingModel>> getMyBookings() async {
    final response = await _apiClient.get('/bookings/my');
    final List<dynamic> bookingsJson = response.data['bookings'] as List<dynamic>;
    return bookingsJson.map((json) => BookingModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<BookingModel> signContract(int bookingId, String signatureUrl) async {
    final response = await _apiClient.put(
      '/bookings/$bookingId/sign',
      data: {'signature_url': signatureUrl},
    );
    return BookingModel.fromJson(response.data['booking'] as Map<String, dynamic>);
  }

  Future<void> cancelBooking(int id) async {
    await _apiClient.delete('/bookings/$id');
  }
}








