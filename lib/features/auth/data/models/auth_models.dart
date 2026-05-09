import 'user_model.dart';

/// ─────────────────────────────────────────────────────────────
/// AUTH MODELS
/// All request and response shapes for auth endpoints.
/// ─────────────────────────────────────────────────────────────

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String userType;
  final String? nationalIdImageUrl;
  final bool? isCertified;
  final String? certificateImageUrl;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.userType,
    this.nationalIdImageUrl,
    this.isCertified,
    this.certificateImageUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType,
    };
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      map['phoneNumber'] = phoneNumber;
    }
    if (nationalIdImageUrl != null) {
      map['nationalIdImageUrl'] = nationalIdImageUrl;
    }
    if (isCertified != null) map['isCertified'] = isCertified;
    if (certificateImageUrl != null) {
      map['certificateImageUrl'] = certificateImageUrl;
    }
    return map;
  }
}

class RegisterResponse {
  final String message;
  final UserModel user;

  const RegisterResponse({required this.message, required this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        message: json['message'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class CompleteCoachOnboardingRequest {
  final String email;
  final String password;
  final String fullName;
  final String nationalId;
  final String gender;
  final int age;
  final String city;
  final int experienceYears;
  final double sessionPrice;
  final List<CoachOnboardingSportRequest> sports;
  final List<String> availableDays;
  final List<String> availableHours;
  final List<CoachAvailabilitySlotRequest> dayHourSlots;
  final String? bio;
  final String? certificateUrl;

  const CompleteCoachOnboardingRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.nationalId,
    required this.gender,
    required this.age,
    required this.city,
    required this.experienceYears,
    required this.sessionPrice,
    required this.sports,
    required this.availableDays,
    required this.availableHours,
    this.dayHourSlots = const [],
    this.bio,
    this.certificateUrl,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'fullName': fullName,
    'nationalId': nationalId,
    'gender': gender,
    'age': age,
    'city': city,
    'experienceYears': experienceYears,
    'sessionPrice': sessionPrice,
    'sports': sports.map((sport) => sport.toJson()).toList(),
    'availableDays': availableDays,
    'availableHours': availableHours,
    if (dayHourSlots.isNotEmpty)
      'dayHourSlots': dayHourSlots.map((slot) => slot.toJson()).toList(),
    if (bio != null && bio!.trim().isNotEmpty) 'bio': bio,
    if (certificateUrl != null && certificateUrl!.trim().isNotEmpty)
      'certificateUrl': certificateUrl,
  };
}

class CoachAvailabilitySlotRequest {
  final String day;
  final List<String> hours;

  const CoachAvailabilitySlotRequest({required this.day, required this.hours});

  Map<String, dynamic> toJson() => {'day': day, 'hours': hours};
}

class CoachOnboardingSportRequest {
  final int sportID;
  final String? description;

  const CoachOnboardingSportRequest({required this.sportID, this.description});

  Map<String, dynamic> toJson() => {
    'sportID': sportID,
    if (description != null && description!.trim().isNotEmpty)
      'description': description,
  };
}

class CompleteCoachOnboardingResponse {
  final String message;
  final bool emailConfirmed;
  final String verificationStatus;

  const CompleteCoachOnboardingResponse({
    required this.message,
    required this.emailConfirmed,
    required this.verificationStatus,
  });

  factory CompleteCoachOnboardingResponse.fromJson(Map<String, dynamic> json) {
    return CompleteCoachOnboardingResponse(
      message: json['message'] as String? ?? 'Coach profile completed.',
      emailConfirmed: json['emailConfirmed'] as bool? ?? false,
      verificationStatus: json['verificationStatus'] as String? ?? 'Pending',
    );
  }
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );
}

class RefreshRequest {
  final String accessToken;
  final String refreshToken;

  const RefreshRequest({required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}

class RefreshResponse {
  final String accessToken;
  final String refreshToken;

  const RefreshResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      RefreshResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}

class LogoutRequest {
  final String refreshToken;

  const LogoutRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String email;
  final String token;
  final String newPassword;

  const ResetPasswordRequest({
    required this.email,
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'token': token,
    'newPassword': newPassword,
  };
}

class ApiError {
  final String message;
  final List<String> errors;
  final int? attemptsRemaining;
  final String? reason;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.message,
    this.errors = const [],
    this.attemptsRemaining,
    this.reason,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final errorMsg =
        json['error'] as String? ??
        json['message'] as String? ??
        'Something went wrong';
    final errorsList = json['errors'] != null
        ? List<String>.from(json['errors'])
        : <String>[];
    return ApiError(
      message: errorMsg,
      errors: errorsList,
      attemptsRemaining: json['attemptsRemaining'] as int?,
      reason: json['reason'] as String?,
      details: json['details'] is Map<String, dynamic>
          ? json['details'] as Map<String, dynamic>
          : null,
    );
  }

  String get fullMessage => errors.isNotEmpty ? errors.join('\n') : message;
}
