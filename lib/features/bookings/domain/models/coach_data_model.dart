class CoachReview {
  final String name;
  final String comment;
  final String date;
  final int rating;

  const CoachReview({
    required this.name,
    required this.comment,
    required this.date,
    required this.rating,
  });
}

class CoachAchievement {
  final String emoji;
  final String title;
  final String subtitle;

  const CoachAchievement({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class CoachData {
  final String name;
  final String sport;
  final int? sportId;
  final String location;
  final String image;
  final List<String> availableDays;
  final double rating;
  final int reviewCount;
  final int price;
  final String bio;
  final int totalStudents;
  final int totalSessions;
  final double hoursTaught;
  final List<CoachAchievement> achievements;
  final List<CoachReview> reviews;

  const CoachData({
    required this.name,
    required this.sport,
    this.sportId,
    required this.location,
    required this.image,
    this.availableDays = const [],
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.bio,
    required this.totalStudents,
    required this.totalSessions,
    required this.hoursTaught,
    required this.achievements,
    required this.reviews,
  });
}

/// Legacy fallback list kept empty so the app never shows demo coaches as real
/// data. Real coach details are built from API/search/booking responses.
final List<CoachData> allCoachesData = [];
