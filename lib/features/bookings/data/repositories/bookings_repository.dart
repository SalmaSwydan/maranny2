import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/bookings_models.dart';

class BookingsRepository {
  final Dio _dio = ApiClient.dio;

  Future<PaginatedSessions> browseSessions({
    int? sportId, String? date, int page = 1, int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.sessions,
      queryParameters: {
        if (sportId != null) 'sportId': sportId,
        if (date != null)    'date':    date,
        'page': page, 'pageSize': pageSize,
      },
    );
    return PaginatedSessions.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<PaginatedSessions> getMySessions({
    String? status, int page = 1, int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.mySessions,
      queryParameters: {
        if (status != null) 'status': status,
        'page': page, 'pageSize': pageSize,
      },
    );
    return PaginatedSessions.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<int> createSession(CreateSessionRequest request) async {
    final response = await _dio.post(
        ApiConfig.sessions, data: request.toJson());
    return response.data['sessionId'] as int;
  }

  Future<String> cancelSession(int sessionId) async {
    final response =
    await _dio.delete('${ApiConfig.sessions}/$sessionId');
    return response.data['message'] as String;
  }

  Future<Map<String, dynamic>> cancelSessionWithRefund(
      int sessionId, {String? reason}) async {
    final response = await _dio.put(
      '/bookings/session/$sessionId/cancel-by-coach',
      queryParameters: {if (reason != null) 'reason': reason},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<BookingModel>> getMyBookings({String? status}) async {
    final response = await _dio.get(
      ApiConfig.myBookings,
      queryParameters: {if (status != null) 'status': status},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
        BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> bookSession(BookSessionRequest request) async {
    final response = await _dio.post(
        ApiConfig.bookings, data: request.toJson());
    return response.data['bookingId'] as int;
  }

  Future<CancelBookingResponse> cancelBooking(
      int bookingId, {String? reason}) async {
    final response = await _dio.put(
      '/bookings/$bookingId/cancel',
      queryParameters: {if (reason != null) 'reason': reason},
    );
    return CancelBookingResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}