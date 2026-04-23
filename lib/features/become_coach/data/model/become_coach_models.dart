class CoachSportRequest {
  final int sportID;
  final String description;

  CoachSportRequest({
    required this.sportID,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'sportID': sportID,
      'description': description,
    };
  }
}

class CompleteCoachOnboardingRequest {
  final String email;
  final String password;
  final String fullName;
  final String nationalId;
  final String city;
  final int experienceYears;
  final double sessionPrice;
  final List<CoachSportRequest> sports;
  final List<String> availableDays;
  final String bio;
  final String certificateUrl;

  CompleteCoachOnboardingRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.nationalId,
    required this.city,
    required this.experienceYears,
    required this.sessionPrice,
    required this.sports,
    required this.availableDays,
    required this.bio,
    required this.certificateUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'nationalId': nationalId,
      'city': city,
      'experienceYears': experienceYears,
      'sessionPrice': sessionPrice,
      'sports': sports.map((e) => e.toJson()).toList(),
      'availableDays': availableDays,
      'bio': bio,
      'certificateUrl': certificateUrl,
    };
  }

  CompleteCoachOnboardingRequest copyWith({
    String? email,
    String? password,
    String? fullName,
    String? nationalId,
    String? city,
    int? experienceYears,
    double? sessionPrice,
    List<CoachSportRequest>? sports,
    List<String>? availableDays,
    String? bio,
    String? certificateUrl,
  }) {
    return CompleteCoachOnboardingRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      city: city ?? this.city,
      experienceYears: experienceYears ?? this.experienceYears,
      sessionPrice: sessionPrice ?? this.sessionPrice,
      sports: sports ?? this.sports,
      availableDays: availableDays ?? this.availableDays,
      bio: bio ?? this.bio,
      certificateUrl: certificateUrl ?? this.certificateUrl,
    );
  }
}

class CompleteCoachOnboardingResponse {
  final String? message;

  CompleteCoachOnboardingResponse({
    this.message,
  });

  factory CompleteCoachOnboardingResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompleteCoachOnboardingResponse(
      message: json['message']?.toString(),
    );
  }
}