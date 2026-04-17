/// ─────────────────────────────────────────────────────────────
/// REVIEWS MODELS
/// ─────────────────────────────────────────────────────────────

class SubmitReviewRequest {
  final int    sessionID;
  final int    coachID;
  final int    rating;
  final String comment;

  const SubmitReviewRequest({
    required this.sessionID,
    required this.coachID,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
    'sessionID': sessionID,
    'coachID':   coachID,
    'rating':    rating,
    'comment':   comment,
  };
}

class ReviewModel {
  final int    reviewID;
  final int    rating;
  final String comment;
  final String? coachResponse;
  final String? responseDate;
  final String  createdAt;
  final String  clientName;
  final String? clientProfilePicture;

  const ReviewModel({
    required this.reviewID,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.clientName,
    this.coachResponse,
    this.responseDate,
    this.clientProfilePicture,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      ReviewModel(
        reviewID:      json['reviewID'] as int,
        rating:        json['rating']   as int,
        comment:       json['comment']  as String,
        coachResponse: json['coachResponse'] as String?,
        responseDate:  json['responseDate']  as String?,
        createdAt:     json['createdAt']     as String,
        clientName: (json['client'] as Map<String, dynamic>?)?['name']
        as String? ??
            json['clientName'] as String? ?? '',
        clientProfilePicture:
        (json['client'] as Map<String, dynamic>?)?['profilePicture']
        as String?,
      );
}

class PaginatedReviews {
  final int               totalCount;
  final int               page;
  final int               pageSize;
  final int               totalPages;
  final double            averageRating;
  final List<ReviewModel> reviews;

  const PaginatedReviews({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.averageRating,
    required this.reviews,
  });

  factory PaginatedReviews.fromJson(Map<String, dynamic> json) =>
      PaginatedReviews(
        totalCount:    json['totalCount']    as int,
        page:          json['page']          as int,
        pageSize:      json['pageSize']      as int,
        totalPages:    json['totalPages']    as int,
        averageRating: (json['averageRating'] as num).toDouble(),
        reviews: (json['reviews'] as List<dynamic>)
            .map((e) =>
            ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// ─────────────────────────────────────────────────────────────
/// PAYMENTS MODELS
/// ─────────────────────────────────────────────────────────────

class InitiatePaymentRequest {
  final int    bookingID;
  final double amount;
  final String method; // 'Card' | 'Wallet'

  const InitiatePaymentRequest({
    required this.bookingID,
    required this.amount,
    required this.method,
  });

  Map<String, dynamic> toJson() => {
    'bookingID': bookingID,
    'amount':    amount,
    'method':    method,
  };
}

class InitiatePaymentResponse {
  final String message;
  final int    paymentId;
  final String paymentUrl;
  final double amount;
  final double platformFee;

  const InitiatePaymentResponse({
    required this.message,
    required this.paymentId,
    required this.paymentUrl,
    required this.amount,
    required this.platformFee,
  });

  factory InitiatePaymentResponse.fromJson(
      Map<String, dynamic> json) =>
      InitiatePaymentResponse(
        message:     json['message']     as String,
        paymentId:   json['paymentId']   as int,
        paymentUrl:  json['paymentUrl']  as String,
        amount:      (json['amount']     as num).toDouble(),
        platformFee: (json['platformFee'] as num).toDouble(),
      );
}

class PaymentModel {
  final int    paymentID;
  final int    bookingID;
  final double amount;
  final String method;
  final String status; // 'Pending'|'Completed'|'Failed'|'Refunded'
  final String transactionDate;
  final double platformFee;
  final double? refundAmount;

  const PaymentModel({
    required this.paymentID,
    required this.bookingID,
    required this.amount,
    required this.method,
    required this.status,
    required this.transactionDate,
    required this.platformFee,
    this.refundAmount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      PaymentModel(
        paymentID:       json['paymentID']       as int,
        bookingID:       json['bookingID']       as int,
        amount:          (json['amount']         as num).toDouble(),
        method:          json['method']          as String,
        status:          json['status']          as String,
        transactionDate: json['transactionDate'] as String,
        platformFee:     (json['platformFee']    as num).toDouble(),
        refundAmount: json['refundAmount'] != null
            ? (json['refundAmount'] as num).toDouble()
            : null,
      );
}