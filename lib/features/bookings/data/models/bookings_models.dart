class SessionModel {
  final int sessionID;
  final String sessionDate;
  final String? scheduledAt;
  final String sessionType;
  final String location;
  final int maxParticipants;
  final String startTime;
  final String endTime;
  final String status;
  final String sportName;
  final int sportID;
  final int? bookedCount;
  final int? availableSlots;
  final String? reservationStatus;
  final int? pendingBookings;
  final int? confirmedBookings;
  final CoachSummary? coach;
  final double? price;

  const SessionModel({
    required this.sessionID,
    required this.sessionDate,
    this.scheduledAt,
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
    this.reservationStatus,
    this.pendingBookings,
    this.confirmedBookings,
    this.coach,
    this.price,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    sessionID: _asInt(json['sessionID'] ?? json['sessionId'] ?? json['id']),
    sessionDate: _asString(
      json['sessionDate'] ??
          json['date'] ??
          json['bookingDate'] ??
          json['scheduledAt'],
    ),
    scheduledAt: _asNullableString(json['scheduledAt']),
    sessionType: _asString(
      json['sessionType'] ?? json['type'],
      fallback: 'Session',
    ),
    location: _asString(json['location']),
    maxParticipants: _asInt(json['maxParticipants']),
    startTime: _asString(
      json['start_Time'] ??
          json['startTime'] ??
          json['sessionTime'] ??
          json['time'],
    ),
    endTime: _asString(json['end_Time'] ?? json['endTime']),
    status: _asString(json['status'], fallback: 'Pending'),
    sportName: _asString(
      json['sportName'] ?? json['sport']?['name'],
      fallback: 'Coach',
    ),
    sportID: _asInt(json['sportID'] ?? json['sportId'] ?? json['sport']?['id']),
    bookedCount: _asNullableInt(json['bookedCount']),
    availableSlots: _asNullableInt(json['availableSlots']),
    reservationStatus: _asNullableString(
      json['reservationStatus'] ?? json['slotStatus'] ?? json['bookingStatus'],
    ),
    pendingBookings: _asNullableInt(json['pendingBookings']),
    confirmedBookings: _asNullableInt(json['confirmedBookings']),
    coach: _asMap(json['coach']) != null
        ? CoachSummary.fromJson(_asMap(json['coach'])!)
        : null,
    price: _asNullableDouble(
      json['price'] ??
          json['totalPrice'] ??
          json['sessionPrice'] ??
          json['amount'],
    ),
  );
}

class CoachSummary {
  final int coachID;
  final int? userID;
  final String name;
  final double avgRating;
  final int? experienceYears;

  const CoachSummary({
    required this.coachID,
    this.userID,
    required this.name,
    required this.avgRating,
    this.experienceYears,
  });

  factory CoachSummary.fromJson(Map<String, dynamic> json) => CoachSummary(
    coachID: _asInt(json['coachID'] ?? json['coachId'] ?? json['id']),
    userID: _asNullableInt(json['userID'] ?? json['userId']),
    name: _asString(
      json['name'] ?? json['fullName'] ?? json['coachName'],
      fallback: 'Coach',
    ),
    avgRating: _asDouble(json['avgRating'] ?? json['rating']),
    experienceYears: _asNullableInt(json['experienceYears']),
  );
}

class BookingUserSummary {
  final int userID;
  final String name;
  final String? email;
  final String? phoneNumber;

  const BookingUserSummary({
    required this.userID,
    required this.name,
    this.email,
    this.phoneNumber,
  });

  factory BookingUserSummary.fromJson(Map<String, dynamic> json) =>
      BookingUserSummary(
        userID: _asInt(json['userID'] ?? json['userId'] ?? json['id']),
        name: _asString(
          json['name'] ?? json['fullName'] ?? json['clientName'],
          fallback: 'Client',
        ),
        email: _asNullableString(json['email']),
        phoneNumber: _asNullableString(json['phoneNumber']),
      );
}

class PaginatedSessions {
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
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
        totalCount: _asInt(json['totalCount']),
        page: _asInt(json['page'], fallback: 1),
        pageSize: _asInt(json['pageSize'], fallback: 20),
        totalPages: _asInt(json['totalPages'], fallback: 1),
        sessions: ((json['sessions'] as List<dynamic>?) ?? const [])
            .whereType<Map>()
            .map((e) => SessionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class CoachAvailabilityModel {
  final int coachId;
  final List<String> availableDays;
  final List<String> availableHours;
  final List<CoachAvailabilityDateEntry> dayHourSlots;
  final List<CoachAvailabilityDateEntry> upcomingAvailableDates;
  final List<CoachWeeklySlotStatus> weeklySlotStatuses;
  final List<String> locations;
  final List<String> sports;
  final bool hasProfileAvailability;
  final bool hasRealSessions;
  final List<SessionModel> sessions;

  const CoachAvailabilityModel({
    required this.coachId,
    required this.availableDays,
    required this.availableHours,
    required this.dayHourSlots,
    required this.upcomingAvailableDates,
    required this.weeklySlotStatuses,
    required this.locations,
    required this.sports,
    required this.hasProfileAvailability,
    required this.hasRealSessions,
    required this.sessions,
  });

  factory CoachAvailabilityModel.fromJson(
    Map<String, dynamic> json,
  ) => CoachAvailabilityModel(
    coachId: _asInt(
      json['coachId'] ?? json['coachID'] ?? json['CoachId'] ?? json['id'],
    ),
    availableDays: _stringList(json['availableDays'] ?? json['AvailableDays']),
    availableHours: _stringList(
      json['availableHours'] ?? json['AvailableHours'],
    ),
    dayHourSlots: _availabilityDateList(
      json['dayHourSlots'] ?? json['DayHourSlots'],
    ),
    upcomingAvailableDates: _availabilityDateList(
      json['upcomingAvailableDates'] ?? json['UpcomingAvailableDates'],
    ),
    weeklySlotStatuses:
        ((json['weeklySlotStatuses'] as List<dynamic>?) ?? const [])
            .whereType<Map>()
            .map(
              (e) =>
                  CoachWeeklySlotStatus.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
    locations: _stringList(json['locations']),
    sports: _stringList(json['sports']),
    hasProfileAvailability: _asBool(
      json['hasProfileAvailability'],
      fallback: false,
    ),
    hasRealSessions: _asBool(json['hasRealSessions'], fallback: false),
    sessions: ((json['sessions'] as List<dynamic>?) ?? const [])
        .whereType<Map>()
        .map((e) => SessionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class CoachWeeklySlotStatus {
  final String dayName;
  final String date;
  final String hour;
  final String reservationStatus;
  final int pendingBookings;
  final int confirmedBookings;
  final int? availableSlots;
  final int? sessionId;

  const CoachWeeklySlotStatus({
    required this.dayName,
    required this.date,
    required this.hour,
    required this.reservationStatus,
    required this.pendingBookings,
    required this.confirmedBookings,
    this.availableSlots,
    this.sessionId,
  });

  factory CoachWeeklySlotStatus.fromJson(Map<String, dynamic> json) =>
      CoachWeeklySlotStatus(
        dayName: _asString(json['dayName'] ?? json['day']),
        date: _asString(json['date']),
        hour: _asString(json['hour'] ?? json['startTime']),
        reservationStatus: _asString(
          json['reservationStatus'] ?? json['status'],
          fallback: 'Free',
        ),
        pendingBookings: _asInt(json['pendingBookings']),
        confirmedBookings: _asInt(json['confirmedBookings']),
        availableSlots: _asNullableInt(json['availableSlots']),
        sessionId: _asNullableInt(json['sessionId'] ?? json['sessionID']),
      );
}

class CoachAvailabilityDateEntry {
  final String date;
  final String dayName;
  final String formattedDate;
  final List<String> availableHours;

  const CoachAvailabilityDateEntry({
    required this.date,
    required this.dayName,
    required this.formattedDate,
    required this.availableHours,
  });

  factory CoachAvailabilityDateEntry.fromDynamic(dynamic value) {
    if (value is String) {
      return CoachAvailabilityDateEntry(
        date: value,
        dayName: _dayNameFromDate(value),
        formattedDate: _formattedDateFromDate(value),
        availableHours: const [],
      );
    }

    final json = _asMap(value) ?? const <String, dynamic>{};
    final date = _asString(json['date'] ?? json['Date'] ?? json['sessionDate']);
    final dayName = _asString(
      json['dayName'] ?? json['Day'] ?? json['day'],
      fallback: _dayNameFromDate(date),
    );
    final formattedDate = _asString(
      json['formattedDate'] ?? json['FormattedDate'],
      fallback: _formattedDateFromDate(date),
    );
    final availableHours = _extractAvailableHours(json);

    return CoachAvailabilityDateEntry(
      date: date,
      dayName: dayName,
      formattedDate: formattedDate,
      availableHours: availableHours,
    );
  }
}

class CreateSessionRequest {
  final int sportID;
  final String sessionDate;
  final String sessionType;
  final String location;
  final int maxParticipants;
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
    'sportID': sportID,
    'sessionDate': sessionDate,
    'sessionType': sessionType,
    'location': location,
    'maxParticipants': maxParticipants,
    'start_Time': startTime,
    'end_Time': endTime,
    if (description != null) 'description': description,
  };
}

class BookingModel {
  final int bookingID;
  final String bookingDate;
  final String status;
  final bool isReviewed;
  final SessionModel session;
  final CoachSummary coach;
  final BookingUserSummary? client;

  const BookingModel({
    required this.bookingID,
    required this.bookingDate,
    required this.status,
    required this.isReviewed,
    required this.session,
    required this.coach,
    this.client,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final sessionJson = _asMap(json['session']) ?? json;
    final coachJson =
        _asMap(json['coach']) ??
        _asMap(sessionJson['coach']) ??
        _asMap(json['coachProfile']) ??
        const <String, dynamic>{};
    final clientJson =
        _asMap(json['client']) ??
        _asMap(json['user']) ??
        _asMap(json['bookedBy']) ??
        _asMap(json['requester']);

    return BookingModel(
      bookingID: _asInt(json['bookingID'] ?? json['bookingId'] ?? json['id']),
      bookingDate: _asString(
        json['bookingDate'] ?? json['createdAt'] ?? json['date'],
      ),
      status: _asString(json['status'], fallback: 'Pending'),
      isReviewed: _asBool(
        json['isReviewed'] ??
            json['reviewed'] ??
            json['hasReview'] ??
            json['hasReviewed'] ??
            (json['review'] != null),
        fallback: false,
      ),
      session: SessionModel.fromJson(sessionJson),
      coach: CoachSummary.fromJson(coachJson),
      client: clientJson != null
          ? BookingUserSummary.fromJson(clientJson)
          : null,
    );
  }

  String get normalizedStatus => normalizeBookingStatus(status);

  DateTime? get scheduledDateTime => parseBookingScheduledDateTime(this);
}

class BookSessionRequest {
  final int? sessionID;
  final int? coachID;
  final int? sportID;
  final String? sessionDate;
  final String? startTime;
  final String? notes;

  const BookSessionRequest({
    this.sessionID,
    this.coachID,
    this.sportID,
    this.sessionDate,
    this.startTime,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    if (sessionID != null) 'sessionID': sessionID,
    if (coachID != null) 'coachID': coachID,
    if (sportID != null) 'sportID': sportID,
    if (sessionDate != null) 'sessionDate': sessionDate,
    if (startTime != null) 'startTime': startTime,
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

  factory CancelBookingResponse.fromJson(Map<String, dynamic> json) =>
      CancelBookingResponse(
        message: _asString(json['message']),
        refundInfo: _asString(json['refundInfo'], fallback: ''),
        hoursUntilSession: _asDouble(json['hoursUntilSession']),
      );
}

class CoachCancelSessionResponse {
  final String message;
  final String refundInfo;

  const CoachCancelSessionResponse({
    required this.message,
    required this.refundInfo,
  });

  factory CoachCancelSessionResponse.fromJson(Map<String, dynamic> json) =>
      CoachCancelSessionResponse(
        message: _asString(json['message']),
        refundInfo: _asString(
          json['refundInfo'] ?? json['refundMessage'],
          fallback: '',
        ),
      );
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final stringValue = value.toString();
  return stringValue.isEmpty ? fallback : stringValue;
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final stringValue = value.toString();
  return stringValue.isEmpty ? null : stringValue;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lowered = value.toLowerCase();
    if (lowered == 'true') return true;
    if (lowered == 'false') return false;
  }
  return fallback;
}

List<String> _stringList(dynamic value) {
  if (value is! List) {
    return const <String>[];
  }

  return value
      .map((item) => item?.toString() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

List<CoachAvailabilityDateEntry> _availabilityDateList(dynamic value) {
  if (value is Map) {
    return value.entries
        .map(
          (entry) => CoachAvailabilityDateEntry(
            date: '',
            dayName: entry.key.toString(),
            formattedDate: '',
            availableHours: _stringList(entry.value),
          ),
        )
        .where((entry) => entry.dayName.isNotEmpty)
        .toList();
  }

  if (value is! List) {
    return const <CoachAvailabilityDateEntry>[];
  }

  return value
      .map(CoachAvailabilityDateEntry.fromDynamic)
      .where((entry) => entry.date.isNotEmpty || entry.dayName.isNotEmpty)
      .toList();
}

List<String> _extractAvailableHours(Map<String, dynamic> json) {
  final directLists = [
    json['availableHours'] ?? json['AvailableHours'],
    json['availableTimes'],
    json['timeSlots'],
    json['times'],
    json['availableSlots'],
    json['Hours'],
    json['hours'],
  ];

  for (final listValue in directLists) {
    final slots = _stringList(listValue);
    if (slots.isNotEmpty) {
      return slots;
    }
  }

  final sessions = json['sessions'];
  if (sessions is List) {
    final slots = sessions
        .map((session) => _asMap(session))
        .whereType<Map<String, dynamic>>()
        .map(
          (session) => _asString(
            session['startTime'] ?? session['start_Time'] ?? session['time'],
          ),
        )
        .where((slot) => slot.isNotEmpty)
        .toList();
    if (slots.isNotEmpty) {
      return slots;
    }
  }

  return const <String>[];
}

String _dayNameFromDate(String value) {
  try {
    final date = DateTime.parse(value);
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  } catch (_) {
    return '';
  }
}

String _formattedDateFromDate(String value) {
  try {
    final date = DateTime.parse(value);
    return '${date.day}/${date.month}/${date.year}';
  } catch (_) {
    return value;
  }
}

String normalizeBookingStatus(String raw) {
  final normalized = raw
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.isEmpty) {
    return 'pending';
  }
  if (normalized == 'pending' ||
      normalized == 'requested' ||
      normalized == 'request' ||
      normalized == 'waiting' ||
      normalized == 'awaiting approval' ||
      normalized == 'pending approval' ||
      normalized == 'pending coach approval' ||
      normalized == 'waiting coach approval') {
    return 'pending';
  }
  if (normalized == 'accepted' ||
      normalized == 'approved' ||
      normalized == 'confirmed' ||
      normalized == 'upcoming' ||
      normalized == 'booked' ||
      normalized == 'reserved') {
    return 'confirmed';
  }
  if (normalized == 'completed' || normalized == 'done') {
    return 'completed';
  }
  if (normalized == 'cancelled' ||
      normalized == 'canceled' ||
      normalized == 'declined' ||
      normalized == 'rejected') {
    return 'cancelled';
  }
  return normalized;
}

bool isPendingBookingStatus(String raw) =>
    normalizeBookingStatus(raw) == 'pending';

bool isConfirmedBookingStatus(String raw) =>
    normalizeBookingStatus(raw) == 'confirmed';

bool isCompletedBookingStatus(String raw) =>
    normalizeBookingStatus(raw) == 'completed';

bool isCancelledBookingStatus(String raw) =>
    normalizeBookingStatus(raw) == 'cancelled';

DateTime? parseBookingScheduledDateTime(BookingModel booking) {
  return combineSessionDateAndTime(
    sessionDate: booking.session.sessionDate,
    startTime: booking.session.startTime,
    scheduledAt: booking.session.scheduledAt,
    fallbackDate: booking.bookingDate,
  );
}

DateTime? combineSessionDateAndTime({
  String? sessionDate,
  String? startTime,
  String? scheduledAt,
  String? fallbackDate,
}) {
  final parsedScheduledAt = _parseFlexibleDateTime(
    scheduledAt ?? sessionDate ?? fallbackDate,
  );
  final parsedDate = _parseFlexibleDate(
    sessionDate ?? scheduledAt ?? fallbackDate,
  );
  final parsedTime = _parseFlexibleTime(startTime);

  if (parsedDate != null && parsedTime != null) {
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }

  if (parsedScheduledAt != null) {
    return parsedScheduledAt;
  }

  if (parsedDate != null) {
    return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
  }

  return null;
}

DateTime? _parseFlexibleDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }

  final trimmed = raw.trim();
  final dateMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(trimmed);
  if (dateMatch != null) {
    final year = int.tryParse(dateMatch.group(1) ?? '');
    final month = int.tryParse(dateMatch.group(2) ?? '');
    final day = int.tryParse(dateMatch.group(3) ?? '');
    if (year != null && month != null && day != null) {
      return DateTime(year, month, day);
    }
  }

  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    return null;
  }
  return DateTime(parsed.year, parsed.month, parsed.day);
}

DateTime? _parseFlexibleDateTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }

  final parsed = DateTime.tryParse(raw.trim());
  if (parsed == null) {
    return null;
  }
  return parsed.isUtc ? parsed.toLocal() : parsed;
}

DateTime? _parseFlexibleTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }

  final normalized = raw.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})(?:\s*(AM|PM))?$',
  ).firstMatch(normalized);
  if (match == null) {
    return null;
  }

  var hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '');
  final meridiem = match.group(3);

  if (hour == null || minute == null) {
    return null;
  }

  if (meridiem != null) {
    if (meridiem == 'AM') {
      if (hour == 12) hour = 0;
    } else if (meridiem == 'PM') {
      if (hour < 12) hour += 12;
    }
  }

  return DateTime(2000, 1, 1, hour, minute);
}
