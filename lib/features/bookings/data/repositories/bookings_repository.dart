import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/bookings_models.dart';

class BookingsRepository {
  final Dio _dio = ApiClient.dio;

  Future<PaginatedSessions> browseSessions({
    int? sportId,
    String? date,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.sessions,
      queryParameters: {
        if (sportId != null) 'sportId': sportId,
        if (date != null) 'date': date,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return PaginatedSessions.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaginatedSessions> getMySessions({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.mySessions,
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return PaginatedSessions.fromJson(response.data as Map<String, dynamic>);
  }

  Future<int> createSession(CreateSessionRequest request) async {
    final response = await _dio.post(
      ApiConfig.sessions,
      data: request.toJson(),
    );
    return response.data['sessionId'] as int;
  }

  Future<String> cancelSession(int sessionId) async {
    final response = await _dio.delete('${ApiConfig.sessions}/$sessionId');
    return response.data['message'] as String;
  }

  Future<List<BookingModel>> getMyBookings({String? status}) async {
    final response = await _dio.get(
      ApiConfig.myBookings,
      queryParameters: {if (status != null) 'status': status},
    );

    final data = response.data;

    if (data is List) {
      return data
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final list = data['bookings'] ?? data['items'] ?? data['data'] ?? [];
      return (list as List)
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<List<BookingModel>> getCoachBookings({String? status}) async {
    final response = await _dio.get(
      '/bookings/coach/my',
      queryParameters: {if (status != null) 'status': status},
    );

    final data = response.data;

    if (data is List) {
      return data
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final list = data['bookings'] ?? data['items'] ?? data['data'] ?? [];
      return (list as List)
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<int> bookSession(BookSessionRequest request) async {
    final response = await _dio.post(
      ApiConfig.bookings,
      data: request.toJson(),
    );
    return response.data['bookingId'] ?? response.data['bookingID'] ?? 0;
  }

  Future<CancelBookingResponse> cancelBooking(
      int bookingId, {
        String? reason,
      }) async {
    final response = await _dio.put(
      '/bookings/$bookingId/cancel',
      queryParameters: {if (reason != null) 'reason': reason},
    );
    return CancelBookingResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> approveBooking(int bookingId) async {
    final response = await _dio.put('/bookings/$bookingId/approve');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'Booking approved';
    }
    return 'Booking approved';
  }

  Future<String> declineBooking(int bookingId) async {
    final response = await _dio.put('/bookings/$bookingId/decline');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'Booking declined';
    }
    return 'Booking declined';
  }

  Future<Map<String, dynamic>> cancelSessionWithRefund(
      int sessionId, {
        String? reason,
      }) async {
    final response = await _dio.put(
      '/bookings/session/$sessionId/cancel-by-coach',
      queryParameters: {if (reason != null) 'reason': reason},
    );
    return response.data as Map<String, dynamic>;
  }
}