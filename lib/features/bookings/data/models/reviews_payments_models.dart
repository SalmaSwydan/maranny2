class CreateReviewRequest {
  final int coachId;
  final int? sessionId;
  final int rating;
  final String? comment;

  const CreateReviewRequest({
    required this.coachId,
    this.sessionId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'coachID': coachId,
      'rating': rating,
    };

    if (sessionId != null) {
      map['sessionID'] = sessionId;
    }
    if (comment != null && comment!.trim().isNotEmpty) {
      map['comment'] = comment!.trim();
    }
    return map;
  }
}

class ReviewModel {
  final int reviewId;
  final int coachId;
  final int? clientId;
  final int? bookingId;
  final int? sessionId;
  final String clientName;
  final String coachName;
  final double rating;
  final String comment;
  final List<String> tags;
  final String createdAt;
  final String? coachResponse;
  final String? responseDate;
  final String? clientProfilePicture;
  final String sportName;

  const ReviewModel({
    required this.reviewId,
    required this.coachId,
    this.clientId,
    this.bookingId,
    this.sessionId,
    required this.clientName,
    required this.coachName,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.createdAt,
    this.coachResponse,
    this.responseDate,
    this.clientProfilePicture,
    required this.sportName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final client = _asMap(json['client']);
    final coach = _asMap(json['coach']);
    final booking = _asMap(json['booking']);
    final session = _asMap(json['session']);
    final createdAt = _asString(
      json['createdAt'] ?? json['date'] ?? json['reviewDate'] ?? json['time'],
    );

    return ReviewModel(
      reviewId: _asInt(json['reviewId'] ?? json['reviewID'] ?? json['id']),
      coachId: _asInt(
        json['coachId'] ?? json['coachID'] ?? coach?['id'] ?? coach?['coachID'],
      ),
      clientId: _asNullableInt(
        json['clientId'] ?? json['clientID'] ?? client?['id'] ?? client?['userID'],
      ),
      bookingId: _asNullableInt(
        json['bookingId'] ?? json['bookingID'] ?? booking?['id'],
      ),
      sessionId: _asNullableInt(
        json['sessionId'] ?? json['sessionID'] ?? session?['id'],
      ),
      clientName: _firstNonEmptyString([
            _asNullableString(json['clientName']),
            _asNullableString(json['reviewerName']),
            _asNullableString(client?['name']),
            _asNullableString(client?['fullName']),
          ]) ??
          'Client',
      coachName: _firstNonEmptyString([
            _asNullableString(json['coachName']),
            _asNullableString(coach?['name']),
            _asNullableString(coach?['fullName']),
          ]) ??
          'Coach',
      rating: _asDouble(json['rating'] ?? json['stars'] ?? json['score']),
      comment: _asString(
        json['comment'] ?? json['reviewText'] ?? json['text'],
      ),
      tags: _stringList(json['tags'] ?? json['labels']),
      createdAt: createdAt,
      coachResponse: _asNullableString(
        json['coachResponse'] ?? json['response'],
      ),
      responseDate: _asNullableString(
        json['responseDate'] ?? json['respondedAt'],
      ),
      clientProfilePicture: _asNullableString(
        json['clientProfilePicture'] ??
            client?['profilePicture'] ??
            client?['profilePictureUrl'],
      ),
      sportName: _firstNonEmptyString([
            _asNullableString(json['sportName']),
            _asNullableString(session?['sportName']),
            _asNullableString(booking?['sportName']),
          ]) ??
          '',
    );
  }

  bool matchesBooking(int bookingIdValue) => bookingId == bookingIdValue;
}

class ReviewsSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingBreakdown;

  const ReviewsSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
  });

  factory ReviewsSummary.fromJson(Map<String, dynamic> json) {
    final breakdownSource =
        _asMap(json['ratingBreakdown']) ?? _asMap(json['breakdown']) ?? const {};
    final breakdown = <int, int>{};
    for (final star in [5, 4, 3, 2, 1]) {
      final rawValue =
          breakdownSource['$star'] ??
          json['${star}StarCount'] ??
          json['${star}Stars'];
      breakdown[star] = _asInt(rawValue);
    }

    return ReviewsSummary(
      averageRating: _asDouble(
        json['averageRating'] ?? json['avgRating'] ?? json['rating'],
      ),
      totalReviews: _asInt(
        json['totalReviews'] ?? json['reviewCount'] ?? json['count'],
      ),
      ratingBreakdown: breakdown,
    );
  }
}

class PaginatedReviews {
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final double averageRating;
  final List<ReviewModel> reviews;

  const PaginatedReviews({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.averageRating,
    required this.reviews,
  });

  factory PaginatedReviews.fromJson(Map<String, dynamic> json) {
    final items =
        json['reviews'] ??
        json['items'] ??
        json['data'] ??
        json['results'] ??
        const <dynamic>[];
    final reviews = items is List
        ? items
            .whereType<Map>()
            .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false)
        : const <ReviewModel>[];

    final average = _asDouble(
      json['averageRating'] ?? json['avgRating'] ?? _calculateAverage(reviews),
    );

    return PaginatedReviews(
      totalCount: _asInt(
        json['totalCount'] ?? json['reviewCount'] ?? reviews.length,
      ),
      page: _asInt(json['page'], fallback: 1),
      pageSize: _asInt(json['pageSize'], fallback: reviews.length),
      totalPages: _asInt(json['totalPages'], fallback: 1),
      averageRating: average,
      reviews: reviews,
    );
  }

  ReviewsSummary get summary => ReviewsSummary(
    averageRating: averageRating,
    totalReviews: totalCount,
    ratingBreakdown: buildRatingBreakdown(reviews),
  );
}

Map<int, int> buildRatingBreakdown(List<ReviewModel> reviews) {
  final breakdown = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
  for (final review in reviews) {
    final rounded = review.rating.round().clamp(1, 5);
    breakdown[rounded] = (breakdown[rounded] ?? 0) + 1;
  }
  return breakdown;
}

double calculateAverageRating(List<ReviewModel> reviews) {
  if (reviews.isEmpty) {
    return 0;
  }
  final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
  return total / reviews.length;
}

double _calculateAverage(List<ReviewModel> reviews) {
  return calculateAverageRating(reviews);
}

class InitiatePaymentRequest {
  final int bookingID;
  final double? amount;
  final String method;
  final String? notes;

  const InitiatePaymentRequest({
    required this.bookingID,
    this.amount,
    required this.method,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'bookingID': bookingID,
    if (amount != null) 'amount': amount,
    'method': method,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
  };
}

class InitiatePaymentResponse {
  final String message;
  final int paymentId;
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

  factory InitiatePaymentResponse.fromJson(Map<String, dynamic> json) =>
      InitiatePaymentResponse(
        message: _asString(json['message']),
        paymentId: _asInt(json['paymentId']),
        paymentUrl: _asString(json['paymentUrl']),
        amount: _asDouble(json['amount']),
        platformFee: _asDouble(json['platformFee']),
      );
}

class PaymentModel {
  final int paymentID;
  final int bookingID;
  final double amount;
  final String method;
  final String status;
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

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    paymentID: _asInt(json['paymentID']),
    bookingID: _asInt(json['bookingID']),
    amount: _asDouble(json['amount']),
    method: _asString(json['method']),
    status: _asString(json['status']),
    transactionDate: _asString(json['transactionDate']),
    platformFee: _asDouble(json['platformFee']),
    refundAmount: _asNullableDouble(json['refundAmount']),
  );
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
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

int? _asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }
  return fallback;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  final stringValue = value.toString();
  return stringValue.isEmpty ? fallback : stringValue;
}

String? _asNullableString(dynamic value) {
  if (value == null) {
    return null;
  }
  final stringValue = value.toString();
  return stringValue.isEmpty ? null : stringValue;
}

List<String> _stringList(dynamic value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String? _firstNonEmptyString(List<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
