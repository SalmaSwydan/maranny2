import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/reviews_payments_models.dart';

class ReviewsRepository {
  final Dio _dio = ApiClient.dio;

  Future<int> submitReview(CreateReviewRequest request) async {
    final requestBody = request.toJson();
    developer.log(
      'Submit review request -> url=${_buildLogUrl(ApiConfig.reviews)} body=${jsonEncode(requestBody)}',
      name: 'ReviewsRepository',
    );

    try {
      final response = await _dio.post(ApiConfig.reviews, data: requestBody);
      developer.log(
        'Submit review response -> status=${response.statusCode} body=${jsonEncode(response.data)}',
        name: 'ReviewsRepository',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _asInt(data['reviewId'] ?? data['reviewID'] ?? data['id']);
      }
      return 0;
    } on DioException catch (error) {
      developer.log(
        'Submit review error -> status=${error.response?.statusCode} body=${jsonEncode(error.response?.data)}',
        name: 'ReviewsRepository',
        error: error,
      );
      rethrow;
    }
  }

  Future<PaginatedReviews> getCoachReviews(
    int coachId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.coachReviews(coachId),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    developer.log(
      'Coach reviews response -> coachId=$coachId body=${jsonEncode(response.data)}',
      name: 'ReviewsRepository',
    );
    final parsed = PaginatedReviews.fromJson(
      response.data as Map<String, dynamic>,
    );
    developer.log(
      'Coach reviews parsed -> coachId=$coachId count=${parsed.reviews.length} averageRating=${parsed.averageRating}',
      name: 'ReviewsRepository',
    );
    return parsed;
  }

  Future<PaginatedReviews> getMyCoachReviews({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.myCoachReviews,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    developer.log(
      'My coach reviews response -> body=${jsonEncode(response.data)}',
      name: 'ReviewsRepository',
    );
    final parsed = PaginatedReviews.fromJson(
      response.data as Map<String, dynamic>,
    );
    developer.log(
      'My coach reviews parsed -> count=${parsed.reviews.length} averageRating=${parsed.averageRating}',
      name: 'ReviewsRepository',
    );
    return parsed;
  }

  Future<ReviewModel?> getBookingReview(int bookingId) async {
    try {
      final response = await _dio.get(ApiConfig.bookingReview(bookingId));
      developer.log(
        'Booking review response -> bookingId=$bookingId body=${jsonEncode(response.data)}',
        name: 'ReviewsRepository',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final reviewJson = _extractReviewMap(data);
        if (reviewJson == null) {
          return null;
        }
        return ReviewModel.fromJson(reviewJson);
      }
      return null;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        developer.log(
          'Booking review response -> bookingId=$bookingId not found',
          name: 'ReviewsRepository',
        );
        return null;
      }
      developer.log(
        'Booking review error -> status=${error.response?.statusCode} body=${jsonEncode(error.response?.data)}',
        name: 'ReviewsRepository',
        error: error,
      );
      rethrow;
    }
  }

  Future<String> respondToReview(int reviewId, String responseText) async {
    final response = await _dio.put(
      ApiConfig.reviewResponse(reviewId),
      data: {'response': responseText},
    );
    return (response.data as Map<String, dynamic>)['message'] as String;
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
}

Map<String, dynamic>? _extractReviewMap(Map<String, dynamic> data) {
  final directReview = data['review'];
  if (directReview is Map<String, dynamic>) {
    return directReview;
  }
  if (directReview is Map) {
    return Map<String, dynamic>.from(directReview);
  }
  if (data.containsKey('rating') || data.containsKey('reviewId')) {
    return data;
  }
  return null;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

class PaymentsRepository {
  final Dio _dio = ApiClient.dio;

  Future<InitiatePaymentResponse> initiatePayment(
    InitiatePaymentRequest request,
  ) async {
    final response = await _dio.post(
      ApiConfig.initiatePayment,
      data: request.toJson(),
    );
    return InitiatePaymentResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PaymentModel> getPaymentDetails(int paymentId) async {
    final response = await _dio.get(ApiConfig.paymentById(paymentId));
    return PaymentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PaymentModel>> getMyPayments() async {
    final response = await _dio.get(ApiConfig.myPayments);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
