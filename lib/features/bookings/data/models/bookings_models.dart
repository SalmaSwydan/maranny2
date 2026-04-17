/// ─────────────────────────────────────────────────────────────
/// BOOKINGS MODELS
/// ─────────────────────────────────────────────────────────────

class SessionModel {
  final int    sessionID;
  final String sessionDate;
  final String sessionType;
  final String location;
  final int    maxParticipants;
  final String startTime;
  final String endTime;
  final String status;
  final String sportName;
  final int    sportID;
  final int?   bookedCount;
  final int?   availableSlots;
  final CoachSummary? coach;

  const SessionModel({
    required this.sessionID,
    required this.sessionDate,
    required this.sessionType,
    required this.location,
    required this.maxParticipants,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.sportName,
    required this.sportID,
    this.bookedCount,
    this.availableSlots,
    this.coach,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      SessionModel(
        sessionID:       json['sessionID']       as int,
        sessionDate:     json['sessionDate']     as String,
        sessionType:     json['sessionType']     as String,
        location:        json['location']        as String,
        maxParticipants: json['maxParticipants'] as int,
        startTime:       json['start_Time']      as String,
        endTime:         json['end_Time']        as String,
        status:          json['status']          as String,
        sportName:       json['sportName']       as String,
        sportID:         json['sportID']         as int,
        bookedCount:     json['bookedCount']     as int?,
        availableSlots:  json['availableSlots']  as int?,
        coach: json['coach'] != null
            ? CoachSummary.fromJson(
            json['coach'] as Map<String, dynamic>)
            : null,
      );
}

class CoachSummary {
  final int    coachID;
  final String name;
  final double avgRating;
  final int?   experienceYears;

  const CoachSummary({
    required this.coachID,
    required this.name,
    required this.avgRating,
    this.experienceYears,
  });

  factory CoachSummary.fromJson(Map<String, dynamic> json) =>
      CoachSummary(
        coachID:         json['coachID']         as int,
        name:            json['name']            as String,
        avgRating:       (json['avgRating']      as num).toDouble(),
        experienceYears: json['experienceYears'] as int?,
      );
}

class PaginatedSessions {
  final int                totalCount;
  final int                page;
  final int                pageSize;
  final int                totalPages;
  final List<SessionModel> sessions;

  const PaginatedSessions({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.sessions,
  });

  factory PaginatedSessions.fromJson(Map<String, dynamic> json) =>
      PaginatedSessions(
        totalCount: json['totalCount'] as int,
        page:       json['page']       as int,
        pageSize:   json['pageSize']   as int,
        totalPages: json['totalPages'] as int,
        sessions: (json['sessions'] as List<dynamic>)
            .map((e) =>
            SessionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CreateSessionRequest {
  final int    sportID;
  final String sessionDate;
  final String sessionType;
  final String location;
  final int    maxParticipants;
  final String startTime;
  final String endTime;
  final String? description;

  const CreateSessionRequest({
    required this.sportID,
    required this.sessionDate,
    required this.sessionType,
    required this.location,
    required this.maxParticipants,
    required this.startTime,
    required this.endTime,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'sportID':         sportID,
    'sessionDate':     sessionDate,
    'sessionType':     sessionType,
    'location':        location,
    'maxParticipants': maxParticipants,
    'start_Time':      startTime,
    'end_Time':        endTime,
    if (description != null) 'description': description,
  };
}

class BookingModel {
  final int          bookingID;
  final String       bookingDate;
  final String       status;
  final SessionModel session;
  final CoachSummary coach;

  const BookingModel({
    required this.bookingID,
    required this.bookingDate,
    required this.status,
    required this.session,
    required this.coach,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      BookingModel(
        bookingID:   json['bookingID']   as int,
        bookingDate: json['bookingDate'] as String,
        status:      json['status']      as String,
        session: SessionModel.fromJson(
            json['session'] as Map<String, dynamic>),
        coach: CoachSummary.fromJson(
            json['coach'] as Map<String, dynamic>),
      );
}

class BookSessionRequest {
  final int     sessionID;
  final String? notes;

  const BookSessionRequest({required this.sessionID, this.notes});

  Map<String, dynamic> toJson() => {
    'sessionID': sessionID,
    if (notes != null) 'notes': notes,
  };
}

class CancelBookingResponse {
  final String message;
  final String refundInfo;
  final double hoursUntilSession;

  const CancelBookingResponse({
    required this.message,
    required this.refundInfo,
    required this.hoursUntilSession,
  });

  factory CancelBookingResponse.fromJson(
      Map<String, dynamic> json) =>
      CancelBookingResponse(
        message:           json['message']            as String,
        refundInfo:        json['refundInfo']         as String? ?? '',
        hoursUntilSession: (json['hoursUntilSession'] as num).toDouble(),
      );
}