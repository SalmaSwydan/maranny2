/// ─────────────────────────────────────────────────────────────
/// USER MODEL
/// Matches exactly what the API returns in login/me responses.
/// ─────────────────────────────────────────────────────────────
class UserModel {
  final int    id;
  final String email;
  final String firstName;
  final String lastName;
  final String userType;            // 'Client' | 'Coach'
  final List<String> roles;
  final bool   emailConfirmed;
  final bool   isBlocked;
  final String? profilePicture;
  final String? verificationStatus; // 'Pending' | 'Verified' | 'Rejected' | null

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
    this.verificationStatus,
  });

  String get fullName => '$firstName $lastName';
  bool get isCoach  => userType == 'Coach';
  bool get isClient => userType == 'Client';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:                 json['id']               as int,
    email:              json['email']             as String,
    firstName:          json['firstName']         as String,
    lastName:           json['lastName']          as String,
    userType:           json['userType']          as String,
    roles:              List<String>.from(json['roles'] ?? []),
    emailConfirmed:     json['emailConfirmed']    as bool? ?? false,
    isBlocked:          json['isBlocked']         as bool? ?? false,
    profilePicture:     json['profilePicture']    as String?,
    verificationStatus: json['verificationStatus'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id':                 id,
    'email':              email,
    'firstName':          firstName,
    'lastName':           lastName,
    'userType':           userType,
    'roles':              roles,
    'emailConfirmed':     emailConfirmed,
    'isBlocked':          isBlocked,
    'profilePicture':     profilePicture,
    'verificationStatus': verificationStatus,
  };
}