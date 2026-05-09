import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/bookings_models.dart';

class BookingsRepository {
  final Dio _dio = ApiClient.dio;

  Future<PaginatedSessions> browseSessions({
    int? coachId,
    int? sportId,
    String? date,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.sessions,
      queryParameters: {
        if (coachId != null) 'coachId': coachId,
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

  Future<CoachAvailabilityModel> getCoachAvailability(int coachId) async {
    final response = await _dio.get(
      '${ApiConfig.sessionsAvailability}/$coachId',
    );
    final responseData = response.data as Map<String, dynamic>;
    developer.log(
      'Coach availability response -> coachId=$coachId body=${jsonEncode(responseData)}',
      name: 'BookingsRepository',
    );

    final availability = CoachAvailabilityModel.fromJson(responseData);
    developer.log(
      'Coach availability parsed -> coachId=$coachId '
      'dayHourSlots=${availability.dayHourSlots.map((entry) => {'dayName': entry.dayName, 'hours': entry.availableHours}).toList(growable: false)} '
      'upcomingAvailableDates=${availability.upcomingAvailableDates.map((entry) => {'date': entry.date, 'dayName': entry.dayName, 'formattedDate': entry.formattedDate, 'hours': entry.availableHours}).toList(growable: false)} '
      'availableDays=${availability.availableDays} '
      'availableHours=${availability.availableHours}',
      name: 'BookingsRepository',
    );
    return availability;
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
    developer.log(
      'Client bookings response -> statusFilter=${status ?? 'all'} body=${jsonEncode(response.data)}',
      name: 'BookingsRepository',
    );
    return _parseBookings(response.data);
  }

  Future<BookingModel> getBookingById(int bookingId) async {
    final response = await _dio.get('${ApiConfig.bookings}/$bookingId');
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final bookingMap = data['booking'] is Map
          ? Map<String, dynamic>.from(data['booking'] as Map)
          : data;
      return BookingModel.fromJson(bookingMap);
    }

    throw const FormatException('Invalid booking details response');
  }

  Future<List<BookingModel>> getCoachBookings({String? status}) async {
    final response = await _dio.get(
      ApiConfig.coachMyBookings,
      queryParameters: {if (status != null) 'status': status},
    );
    developer.log(
      'Coach bookings response -> statusFilter=${status ?? 'all'} body=${jsonEncode(response.data)}',
      name: 'BookingsRepository',
    );
    return _parseBookings(response.data);
  }

  Future<int> bookSession(BookSessionRequest request) async {
    final requestBody = request.toJson();
    final requestUrl = _buildLogUrl(ApiConfig.bookings);
    final requestHeaders = _sanitizeHeaders(<String, dynamic>{
      ..._dio.options.headers,
    });
    final requestContentType =
        _dio.options.contentType ??
        requestHeaders['Content-Type']?.toString() ??
        'application/json';

    developer.log(
      'Booking request -> '
      'method=POST '
      'url=$requestUrl '
      'headers=${jsonEncode(requestHeaders)} '
      'contentType=$requestContentType '
      'body=${jsonEncode(requestBody)}',
      name: 'BookingsRepository',
    );
    print(
      '[BookingsRepository] Booking request -> '
      'method=POST '
      'url=$requestUrl '
      'headers=${jsonEncode(requestHeaders)} '
      'contentType=$requestContentType '
      'body=${jsonEncode(requestBody)}',
    );

    try {
      final response = await _dio.post(ApiConfig.bookings, data: requestBody);
      developer.log(
        'Booking response -> '
        'status=${response.statusCode} '
        'body=${jsonEncode(response.data)}',
        name: 'BookingsRepository',
      );
      print(
        '[BookingsRepository] Booking response -> '
        'status=${response.statusCode} '
        'body=${jsonEncode(response.data)}',
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final bookingId = data['bookingId'] ?? data['bookingID'] ?? data['id'];
        if (bookingId is int) return bookingId;
        if (bookingId is num) return bookingId.toInt();
      }
      return 0;
    } on DioException catch (error) {
      final errorBody = error.response?.data;
      developer.log(
        'Booking error -> '
        'method=POST '
        'url=$requestUrl '
        'headers=${jsonEncode(requestHeaders)} '
        'contentType=$requestContentType '
        'requestBody=${jsonEncode(requestBody)} '
        'status=${error.response?.statusCode} '
        'body=${jsonEncode(errorBody)} '
        'dioMessage=${error.message}',
        name: 'BookingsRepository',
        error: error,
      );
      print(
        '[BookingsRepository] Booking error -> '
        'method=POST '
        'url=$requestUrl '
        'headers=${jsonEncode(requestHeaders)} '
        'contentType=$requestContentType '
        'requestBody=${jsonEncode(requestBody)} '
        'status=${error.response?.statusCode} '
        'body=${jsonEncode(errorBody)} '
        'dioMessage=${error.message}',
      );
      print('[BookingsRepository] Booking raw response.data -> $errorBody');
      rethrow;
    }
  }

  Future<CancelBookingResponse> cancelBooking(
    int bookingId, {
    String? reason,
  }) async {
    final response = await _dio.put(
      '${ApiConfig.bookings}/$bookingId/cancel',
      queryParameters: {if (reason != null) 'reason': reason},
    );
    return CancelBookingResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<String> approveBooking(int bookingId) async {
    final response = await _dio.put('${ApiConfig.bookings}/$bookingId/approve');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'Booking approved';
    }
    return 'Booking approved';
  }

  Future<String> declineBooking(int bookingId, {String? reason}) async {
    final response = await _dio.put(
      '${ApiConfig.bookings}/$bookingId/decline',
      data: {if (reason != null && reason.trim().isNotEmpty) 'reason': reason},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'Booking declined';
    }
    return 'Booking declined';
  }

  Future<CoachCancelSessionResponse> cancelSessionWithRefund(
    int sessionId, {
    String? reason,
  }) async {
    final response = await _dio.put(
      '${ApiConfig.bookings}/session/$sessionId/cancel-by-coach',
      queryParameters: {if (reason != null) 'reason': reason},
    );
    return CoachCancelSessionResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  List<BookingModel> _parseBookings(dynamic data) {
    if (data is List) {
      final bookings = data
          .whereType<Map>()
          .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      developer.log(
        'Parsed bookings from list -> count=${bookings.length}',
        name: 'BookingsRepository',
      );
      return bookings;
    }

    if (data is Map<String, dynamic>) {
      final list =
          data['bookings'] ??
          data['items'] ??
          data['data'] ??
          data['results'] ??
          data['result'] ??
          data['records'] ??
          const <dynamic>[];
      if (list is List) {
        final bookings = list
            .whereType<Map>()
            .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        developer.log(
          'Parsed bookings from object -> keys=${data.keys.toList()} count=${bookings.length}',
          name: 'BookingsRepository',
        );
        return bookings;
      }

      final singleBooking = data['booking'];
      if (singleBooking is Map) {
        final bookings = [
          BookingModel.fromJson(Map<String, dynamic>.from(singleBooking)),
        ];
        developer.log(
          'Parsed single booking from object -> count=${bookings.length}',
          name: 'BookingsRepository',
        );
        return bookings;
      }
    }

    developer.log(
      'Parsed bookings -> unsupported response type=${data.runtimeType}',
      name: 'BookingsRepository',
    );
    return const <BookingModel>[];
  }

  String _buildLogUrl(String path) {
    final baseUrl = _dio.options.baseUrl;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (baseUrl.endsWith('/') && path.startsWith('/')) {
      return '${baseUrl.substring(0, baseUrl.length - 1)}$path';
    }
    if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      return '$baseUrl/$path';
    }
    return '$baseUrl$path';
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization') {
        sanitized[entry.key] = '[REDACTED]';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }
}
