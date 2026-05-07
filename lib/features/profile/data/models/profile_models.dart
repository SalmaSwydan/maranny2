import '../../../../core/network/api_config.dart';

class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? city;
  final String? street;
  final String? buildingNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? bio;
  final int? experienceYears;
  final String? certificateUrl;

  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.city,
    this.street,
    this.buildingNumber,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.experienceYears,
    this.certificateUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    if (city != null) map['city'] = city;
    if (street != null) map['street'] = street;
    if (buildingNumber != null) map['buildingNumber'] = buildingNumber;
    if (dateOfBirth != null) map['dateOfBirth'] = dateOfBirth;
    if (gender != null) map['gender'] = gender;
    if (bio != null) map['bio'] = bio;
    if (experienceYears != null) map['experienceYears'] = experienceYears;
    if (certificateUrl != null) map['certificateUrl'] = certificateUrl;
    return map;
  }
}

class UpdatePreferencesRequest {
  final List<String>? sports;
  final double? budgetMin;
  final double? budgetMax;
  final double? maxDistance;
  final String? city;
  final String? area;
  final String? locationPreference;
  final String? ratingPreference;
  final String? coachGender;
  final String? coachAgeRange;
  final bool? certifiedOnly;

  const UpdatePreferencesRequest({
    this.sports,
    this.budgetMin,
    this.budgetMax,
    this.maxDistance,
    this.city,
    this.area,
    this.locationPreference,
    this.ratingPreference,
    this.coachGender,
    this.coachAgeRange,
    this.certifiedOnly,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (sports != null) map['sports'] = sports;
    if (budgetMin != null) map['budgetMin'] = budgetMin;
    if (budgetMax != null) map['budgetMax'] = budgetMax;
    if (maxDistance != null) map['maxDistance'] = maxDistance;
    if (city != null) map['city'] = city;
    if (area != null) map['area'] = area;
    if (locationPreference != null) {
      map['locationPreference'] = locationPreference;
    }
    if (ratingPreference != null) map['ratingPreference'] = ratingPreference;
    if (coachGender != null) map['coachGender'] = coachGender;
    if (coachAgeRange != null) map['coachAgeRange'] = coachAgeRange;
    if (certifiedOnly != null) map['certifiedOnly'] = certifiedOnly;
    return map;
  }
}

class CoachProfileModel {
  final int coachID;
  final String name;
  final String? bio;
  final String? about;
  final String? description;
  final int experienceYears;
  final double avgRating;
  final String? gender;
  final String? profilePictureUrl;
  final String? certificateUrl;
  final String verificationStatus;
  final String? email;
  final String? phoneNumber;
  final String? city;
  final String? location;
  final String? address;
  final double? sessionPrice;
  final double? hourlyRate;
  final double? startingPrice;
  final List<String> availableDays;
  final List<CoachSportModel> sports;
  final List<String> locations;
  final int totalReviews;
  final List<Map<String, dynamic>> upcomingSessions;
  final List<Map<String, dynamic>> recentReviews;

  const CoachProfileModel({
    required this.coachID,
    required this.name,
    required this.experienceYears,
    required this.avgRating,
    required this.verificationStatus,
    required this.sports,
    required this.locations,
    required this.totalReviews,
    required this.upcomingSessions,
    required this.recentReviews,
    this.bio,
    this.about,
    this.description,
    this.gender,
    this.profilePictureUrl,
    this.certificateUrl,
    this.email,
    this.phoneNumber,
    this.city,
    this.location,
    this.address,
    this.sessionPrice,
    this.hourlyRate,
    this.startingPrice,
    this.availableDays = const [],
  });

  factory CoachProfileModel.fromJson(Map<String, dynamic> json) {
    final payload = (json['coach'] is Map<String, dynamic>)
        ? json['coach'] as Map<String, dynamic>
        : json;

    return CoachProfileModel(
      coachID: _asInt(
        payload['coachID'] ?? payload['coachId'] ?? payload['id'],
      ),
      name: _asString(payload['name']),
      bio: _asNullableString(payload['bio']),
      about: _asNullableString(payload['about']),
      description: _asNullableString(payload['description']),
      experienceYears: _asInt(payload['experienceYears']),
      avgRating: _asDouble(payload['avgRating']),
      gender: _asNullableString(payload['gender']),
      profilePictureUrl: ApiConfig.resolveMediaUrl(
        _asNullableString(
          payload['url'] ??
              payload['profilePictureUrl'] ??
              payload['profilePicture'] ??
              payload['imageUrl'],
        ),
      ),
      certificateUrl: _asNullableString(payload['certificateUrl']),
      verificationStatus: _asString(
        payload['verificationStatus'],
        fallback: 'Pending',
      ),
      email: _asNullableString(payload['email']),
      phoneNumber: _asNullableString(payload['phoneNumber']),
      city: _asNullableString(payload['city']),
      location: _asNullableString(payload['location']),
      address: _asNullableString(payload['address']),
      sessionPrice: _asNullableDouble(payload['sessionPrice']),
      hourlyRate: _asNullableDouble(payload['hourlyRate']),
      startingPrice: _asNullableDouble(
        payload['startingPrice'] ?? payload['pricePerSession'],
      ),
      availableDays: List<String>.from(payload['availableDays'] ?? const []),
      sports: (payload['sports'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => CoachSportModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      locations: List<String>.from(payload['locations'] ?? const []),
      totalReviews: _asInt(payload['totalReviews']),
      upcomingSessions:
          (payload['upcomingSessions'] as List<dynamic>? ?? const [])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
      recentReviews: (payload['recentReviews'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  String? get resolvedBio => _firstNonEmptyString([bio, about, description]);

  double? get resolvedPrice => _firstNonNullDouble([
    sessionPrice,
    startingPrice,
    hourlyRate,
    ...sports.map((sport) => sport.pricePerSession),
  ]);

  String? get resolvedLocation => _firstNonEmptyString([
    if (locations.isNotEmpty) locations.first,
    city,
    location,
    address,
  ]);
}

class CoachSetupProfileModel {
  final int coachId;
  final String fullName;
  final String? city;
  final double? sessionPrice;
  final String? bio;
  final int? experienceYears;
  final String? certificateUrl;
  final String verificationStatus;
  final List<String> availableDays;
  final List<String> locations;
  final List<CoachSportModel> sports;

  const CoachSetupProfileModel({
    required this.coachId,
    required this.fullName,
    required this.verificationStatus,
    required this.availableDays,
    required this.locations,
    required this.sports,
    this.city,
    this.sessionPrice,
    this.bio,
    this.experienceYears,
    this.certificateUrl,
  });

  factory CoachSetupProfileModel.fromJson(Map<String, dynamic> json) {
    return CoachSetupProfileModel(
      coachId: _asInt(json['coachID'] ?? json['coachId'] ?? json['id']),
      fullName: _asString(json['fullName']),
      city: _asNullableString(json['city']),
      sessionPrice: _asNullableDouble(json['sessionPrice']),
      bio: _asNullableString(json['bio']),
      experienceYears: _asNullableInt(json['experienceYears']),
      certificateUrl: _asNullableString(json['certificateUrl']),
      verificationStatus: _asString(
        json['verificationStatus'],
        fallback: 'Pending',
      ),
      availableDays: List<String>.from(json['availableDays'] ?? const []),
      locations: List<String>.from(json['locations'] ?? const []),
      sports: (json['sports'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => CoachSportModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  String? get resolvedLocation => _firstNonEmptyString([
        if (locations.isNotEmpty) locations.first,
        city,
      ]);

  String get sportsLabel {
    final names = sports
        .map((sport) => sport.name.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    if (names.isEmpty) {
      return 'Coach';
    }
    return names.join(' | ');
  }
}

class CoachSportModel {
  final int id;
  final String name;
  final String? description;
  final double? pricePerSession;
  final int? experienceYears;

  const CoachSportModel({
    required this.id,
    required this.name,
    this.description,
    this.pricePerSession,
    this.experienceYears,
  });

  factory CoachSportModel.fromJson(Map<String, dynamic> json) {
    return CoachSportModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      description: _asNullableString(json['description']),
      pricePerSession: _asNullableDouble(json['pricePerSession']),
      experienceYears: _asNullableInt(json['experienceYears']),
    );
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
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

String? _firstNonEmptyString(List<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

double? _firstNonNullDouble(List<double?> values) {
  for (final value in values) {
    if (value != null && value > 0) {
      return value;
    }
  }
  return null;
}

