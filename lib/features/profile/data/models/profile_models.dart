/// ─────────────────────────────────────────────────────────────
/// PROFILE MODELS
/// ─────────────────────────────────────────────────────────────

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
  final int?    experienceYears;
  final String? certificateUrl;

  const UpdateProfileRequest({
    this.firstName, this.lastName, this.phoneNumber,
    this.city, this.street, this.buildingNumber,
    this.dateOfBirth, this.gender, this.bio,
    this.experienceYears, this.certificateUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null)       map['firstName']       = firstName;
    if (lastName != null)        map['lastName']        = lastName;
    if (phoneNumber != null)     map['phoneNumber']     = phoneNumber;
    if (city != null)            map['city']            = city;
    if (street != null)          map['street']          = street;
    if (buildingNumber != null)  map['buildingNumber']  = buildingNumber;
    if (dateOfBirth != null)     map['dateOfBirth']     = dateOfBirth;
    if (gender != null)          map['gender']          = gender;
    if (bio != null)             map['bio']             = bio;
    if (experienceYears != null) map['experienceYears'] = experienceYears;
    if (certificateUrl != null)  map['certificateUrl']  = certificateUrl;
    return map;
  }
}

class UpdatePreferencesRequest {
  final String? sports;
  final double? budgetMin;
  final double? budgetMax;
  final double? maxDistance;

  const UpdatePreferencesRequest({
    this.sports, this.budgetMin, this.budgetMax, this.maxDistance,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (sports != null)      map['sports']      = sports;
    if (budgetMin != null)   map['budgetMin']   = budgetMin;
    if (budgetMax != null)   map['budgetMax']   = budgetMax;
    if (maxDistance != null) map['maxDistance'] = maxDistance;
    return map;
  }
}

class CoachProfileModel {
  final int    coachID;
  final String name;
  final String? bio;
  final int    experienceYears;
  final double avgRating;
  final String? gender;
  final String? profilePictureUrl; // ⚠️ API field is 'url'
  final String? certificateUrl;
  final String  verificationStatus;
  final String? email;
  final String? phoneNumber;
  final List<CoachSportModel>      sports;
  final List<String>               locations;
  final int                        totalReviews;
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
    this.bio, this.gender, this.profilePictureUrl,
    this.certificateUrl, this.email, this.phoneNumber,
  });

  factory CoachProfileModel.fromJson(Map<String, dynamic> json) =>
      CoachProfileModel(
        coachID:            json['coachID']            as int,
        name:               json['name']               as String,
        bio:                json['bio']                as String?,
        experienceYears:    json['experienceYears']    as int,
        avgRating:          (json['avgRating']         as num).toDouble(),
        gender:             json['gender']             as String?,
        profilePictureUrl:  json['url']                as String?,
        certificateUrl:     json['certificateUrl']     as String?,
        verificationStatus: json['verificationStatus'] as String,
        email:              json['email']              as String?,
        phoneNumber:        json['phoneNumber']        as String?,
        sports: (json['sports'] as List<dynamic>? ?? [])
            .map((e) =>
            CoachSportModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        locations: List<String>.from(json['locations'] ?? []),
        totalReviews: json['totalReviews'] as int,
        upcomingSessions: List<Map<String, dynamic>>.from(
            json['upcomingSessions'] ?? []),
        recentReviews: List<Map<String, dynamic>>.from(
            json['recentReviews'] ?? []),
      );
}

class CoachSportModel {
  final int    id; // ⚠️ API uses 'id' not 'sportID'
  final String name;
  final String? description;
  final double? pricePerSession;
  final int?    experienceYears;

  const CoachSportModel({
    required this.id, required this.name,
    this.description, this.pricePerSession, this.experienceYears,
  });

  factory CoachSportModel.fromJson(Map<String, dynamic> json) =>
      CoachSportModel(
        id:              json['id']   as int,
        name:            json['name'] as String,
        description:     json['description']    as String?,
        pricePerSession: json['pricePerSession'] != null
            ? (json['pricePerSession'] as num).toDouble()
            : null,
        experienceYears: json['experienceYears'] as int?,
      );
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
    'newPassword':     newPassword,
    'confirmPassword': confirmPassword,
  };
}