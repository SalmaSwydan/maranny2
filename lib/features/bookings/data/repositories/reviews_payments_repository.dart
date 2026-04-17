import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/reviews_payments_models.dart';

/// ─────────────────────────────────────────────────────────────
/// REVIEWS REPOSITORY
/// ─────────────────────────────────────────────────────────────
class ReviewsRepository {
  final Dio _dio = ApiClient.dio;

  Future<int> submitReview(SubmitReviewRequest request) async {
    final response = await _dio.post(
        ApiConfig.reviews, data: request.toJson());
    return response.data['reviewId'] as int;
  }

  Future<PaginatedReviews> getCoachReviews(
      int coachId, {int page = 1, int pageSize = 10}) async {
    final response = await _dio.get(
      '/reviews/coach/$coachId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PaginatedReviews.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<String> respondToReview(
      int reviewId, String responseText) async {
    final response = await _dio.put(
      '/reviews/$reviewId/response',
      data: {'response': responseText},
    );
    return response.data['message'] as String;
  }
}

/// ─────────────────────────────────────────────────────────────
/// PAYMENTS REPOSITORY
/// ─────────────────────────────────────────────────────────────
class PaymentsRepository {
  final Dio _dio = ApiClient.dio;

  /// Returns paymentUrl — open this in WebView for user to pay
  Future<InitiatePaymentResponse> initiatePayment(
      InitiatePaymentRequest request) async {
    final response = await _dio.post(
        ApiConfig.initiatePayment, data: request.toJson());
    return InitiatePaymentResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<PaymentModel> getPaymentDetails(int paymentId) async {
    final response = await _dio.get('/payments/$paymentId');
    return PaymentModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<List<PaymentModel>> getMyPayments() async {
    final response = await _dio.get(ApiConfig.myPayments);
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
        PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}