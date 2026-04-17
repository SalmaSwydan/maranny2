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
  final String phoneNumber;
  final String userType;
  final String? nationalIdImageUrl;
  final bool?   isCertified;
  final String? certificateImageUrl;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.userType,
    this.nationalIdImageUrl,
    this.isCertified,
    this.certificateImageUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email':       email,
      'password':    password,
      'firstName':   firstName,
      'lastName':    lastName,
      'phoneNumber': phoneNumber,
      'userType':    userType,
    };
    if (nationalIdImageUrl != null)  map['nationalIdImageUrl']  = nationalIdImageUrl;
    if (isCertified != null)         map['isCertified']         = isCertified;
    if (certificateImageUrl != null) map['certificateImageUrl'] = certificateImageUrl;
    return map;
  }
}

class RegisterResponse {
  final String    message;
  final UserModel user;

  const RegisterResponse({required this.message, required this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        message: json['message'] as String,
        user:    UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email':    email,
    'password': password,
  };
}

class LoginResponse {
  final String    accessToken;
  final String    refreshToken;
  final UserModel user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken:  json['accessToken']  as String,
    refreshToken: json['refreshToken'] as String,
    user:         UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );
}

class RefreshRequest {
  final String accessToken;
  final String refreshToken;

  const RefreshRequest({
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
    'accessToken':  accessToken,
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
        accessToken:  json['accessToken']  as String,
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
    'email':       email,
    'token':       token,
    'newPassword': newPassword,
  };
}

class ApiError {
  final String       message;
  final List<String> errors;
  final int?         attemptsRemaining;
  final String?      reason;

  const ApiError({
    required this.message,
    this.errors = const [],
    this.attemptsRemaining,
    this.reason,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final errorMsg = json['error']   as String? ??
        json['message'] as String? ??
        'Something went wrong';
    final errorsList = json['errors'] != null
        ? List<String>.from(json['errors'])
        : <String>[];
    return ApiError(
      message:           errorMsg,
      errors:            errorsList,
      attemptsRemaining: json['attemptsRemaining'] as int?,
      reason:            json['reason']            as String?,
    );
  }

  String get fullMessage =>
      errors.isNotEmpty ? errors.join('\n') : message;
}