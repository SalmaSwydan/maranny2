/// ─────────────────────────────────────────────────────────────
/// RECOMMEND MODELS
/// Request and response shapes for the AI service.
/// POST http://your-server:8000/api/recommend
/// ─────────────────────────────────────────────────────────────

class RecommendRequest {
  final String preferredSports;
  final String? userId;
  final String? userCity;
  final String? locationPreference;
  final double? budgetMin;
  final double? budgetMax;
  final double? minRating;
  final bool?   isCertified;
  final String? preferredCoachGender;
  final String? preferredCoachAgeRange;

  const RecommendRequest({
    required this.preferredSports,
    this.userId,
    this.userCity,
    this.locationPreference,
    this.budgetMin,
    this.budgetMax,
    this.minRating,
    this.isCertified,
    this.preferredCoachGender,
    this.preferredCoachAgeRange,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'preferred_sports': preferredSports,
    };
    if (userId != null)                 map['userId']                    = userId;
    if (userCity != null)               map['user_city']                 = userCity;
    if (locationPreference != null)     map['location_preference']       = locationPreference;
    if (budgetMin != null)              map['budget_min']                = budgetMin;
    if (budgetMax != null)              map['budget_max']                = budgetMax;
    if (minRating != null)              map['min_rating']                = minRating;
    if (isCertified != null)            map['is_certified']              = isCertified;
    if (preferredCoachGender != null)   map['preferred_coach_gender']    = preferredCoachGender;
    if (preferredCoachAgeRange != null) map['preferred_coach_age_range'] = preferredCoachAgeRange;
    return map;
  }
}

class RecommendResponse {
  final List<CoachRecommendation> recommendations;

  const RecommendResponse({required this.recommendations});

  factory RecommendResponse.fromJson(Map<String, dynamic> json) {
    final list = json['recommendations'] as List<dynamic>;
    return RecommendResponse(
      recommendations: list
          .map((e) =>
          CoachRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  List<String> get coachIds =>
      recommendations.map((r) => r.coachId).toList();
}

class CoachRecommendation {
  final String        coachId;
  final double        score;
  final AiExplanation explanation;

  const CoachRecommendation({
    required this.coachId,
    required this.score,
    required this.explanation,
  });

  factory CoachRecommendation.fromJson(Map<String, dynamic> json) =>
      CoachRecommendation(
        coachId:     json['coachId'] as String,
        score:       (json['score'] as num).toDouble(),
        explanation: AiExplanation.fromJson(
            json['explanation'] as Map<String, dynamic>),
      );
}

class AiExplanation {
  final String distance;
  final String sport;
  final String price;
  final String rating;
  final String availability;

  const AiExplanation({
    required this.distance,
    required this.sport,
    required this.price,
    required this.rating,
    required this.availability,
  });

  factory AiExplanation.fromJson(Map<String, dynamic> json) =>
      AiExplanation(
        distance:     json['distance']     as String? ?? '',
        sport:        json['sport']        as String? ?? '',
        price:        json['price']        as String? ?? '',
        rating:       json['rating']       as String? ?? '',
        availability: json['availability'] as String? ?? '',
      );
}