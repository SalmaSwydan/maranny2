import '../../../../core/network/api_config.dart';

class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String userType;
  final List<String> roles;
  final bool emailConfirmed;
  final bool isBlocked;
  final String? profilePicture;
  final String? phoneNumber;
  final String? city;
  final String? street;
  final String? bio;
  final String? verificationStatus;
  final bool? coachSetupCompleted;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    required this.roles,
    required this.emailConfirmed,
    required this.isBlocked,
    this.profilePicture,
    this.phoneNumber,
    this.city,
    this.street,
    this.bio,
    this.verificationStatus,
    this.coachSetupCompleted,
  });

  String get fullName => '$firstName $lastName';
  bool get isCoach => userType == 'Coach';
  bool get isClient => userType == 'Client';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    email: json['email'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    userType: json['userType'] as String,
    roles: List<String>.from(json['roles'] ?? []),
    emailConfirmed: json['emailConfirmed'] as bool? ?? false,
    isBlocked: json['isBlocked'] as bool? ?? false,
    profilePicture: ApiConfig.resolveMediaUrl(
      json['profilePicture'] as String?,
    ),
    phoneNumber: json['phoneNumber'] as String?,
    city: json['city'] as String?,
    street: json['street'] as String?,
    bio: json['bio'] as String?,
    verificationStatus: json['verificationStatus'] as String?,
    coachSetupCompleted: json['coachSetupCompleted'] as bool?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'userType': userType,
    'roles': roles,
    'emailConfirmed': emailConfirmed,
    'isBlocked': isBlocked,
    'profilePicture': profilePicture,
    'phoneNumber': phoneNumber,
    'city': city,
    'street': street,
    'bio': bio,
    'verificationStatus': verificationStatus,
    'coachSetupCompleted': coachSetupCompleted,
  };
}
