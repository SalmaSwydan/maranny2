class BookingSessionModel {
  final String id;
  final int coachUserId;
  final int? sportId;
  final String coachName;
  final String sport;
  final String location;
  final DateTime date;
  bool isReviewed;
  final bool isPast;

  BookingSessionModel({
    required this.id,
    required this.coachUserId,
    this.sportId,
    required this.coachName,
    required this.sport,
    required this.location,
    required this.date,
    required this.isPast,
    this.isReviewed = false,
  });
}
