import '../../../auth/data/models/auth_models.dart';

class CoachOnboardingDraft {
  CoachOnboardingDraft({
    required this.email,
    required this.password,
    this.fullName = '',
    this.nationalId = '',
    this.city = '',
    this.experienceYears = 0,
    this.sessionPrice = 0,
    List<String>? selectedSports,
    this.bio,
    List<String>? availableDays,
    this.certificateUrl,
  }) : selectedSports = selectedSports ?? <String>[],
       availableDays = availableDays ?? <String>[];

  final String email;
  final String password;
  final String fullName;
  final String nationalId;
  final String city;
  final int experienceYears;
  final double sessionPrice;
  final List<String> selectedSports;
  final String? bio;
  final List<String> availableDays;
  final String? certificateUrl;

  static const Map<String, int> supportedSports = {
    'Football': 1,
    'Basketball': 2,
    'Swimming': 3,
    'Tennis': 4,
    'Gym Training': 5,
    'Padel': 6,
  };

  CoachOnboardingDraft copyWith({
    String? email,
    String? password,
    String? fullName,
    String? nationalId,
    String? city,
    int? experienceYears,
    double? sessionPrice,
    List<String>? selectedSports,
    String? bio,
    List<String>? availableDays,
    String? certificateUrl,
  }) {
    return CoachOnboardingDraft(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      city: city ?? this.city,
      experienceYears: experienceYears ?? this.experienceYears,
      sessionPrice: sessionPrice ?? this.sessionPrice,
      selectedSports: selectedSports ?? List<String>.from(this.selectedSports),
      bio: bio ?? this.bio,
      availableDays: availableDays ?? List<String>.from(this.availableDays),
      certificateUrl: certificateUrl ?? this.certificateUrl,
    );
  }

  List<String> get unsupportedSports => selectedSports
      .where((sport) => !supportedSports.containsKey(sport))
      .toList(growable: false);

  CompleteCoachOnboardingRequest toRequest() {
    final sports = selectedSports
        .where(supportedSports.containsKey)
        .map(
          (sport) => CoachOnboardingSportRequest(
            sportID: supportedSports[sport]!,
            description: bio,
          ),
        )
        .toList(growable: false);

    return CompleteCoachOnboardingRequest(
      email: email,
      password: password,
      fullName: fullName,
      nationalId: nationalId,
      city: city,
      experienceYears: experienceYears,
      sessionPrice: sessionPrice,
      sports: sports,
      availableDays: availableDays,
      bio: bio,
      certificateUrl: certificateUrl,
    );
  }
}
