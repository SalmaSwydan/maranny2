import '../../../auth/data/models/auth_models.dart';

class CoachOnboardingDraft {
  CoachOnboardingDraft({
    required this.email,
    required this.password,
    this.fullName = '',
    this.nationalId = '',
    this.gender = '',
    this.age,
    this.city = '',
    this.experienceYears = 0,
    this.sessionPrice = 0,
    List<String>? selectedSports,
    Map<String, int>? selectedSportIds,
    this.bio,
    List<String>? availableDays,
    Map<String, List<String>>? availabilitySlots,
    this.certificateUrl,
  }) : selectedSports = selectedSports ?? <String>[],
       selectedSportIds = selectedSportIds ?? <String, int>{},
       availableDays = availableDays ?? <String>[],
       availabilitySlots = availabilitySlots ?? <String, List<String>>{};

  final String email;
  final String password;
  final String fullName;
  final String nationalId;
  final String gender;
  final int? age;
  final String city;
  final int experienceYears;
  final double sessionPrice;
  final List<String> selectedSports;
  final Map<String, int> selectedSportIds;
  final String? bio;
  final List<String> availableDays;
  final Map<String, List<String>> availabilitySlots;
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
    String? gender,
    int? age,
    String? city,
    int? experienceYears,
    double? sessionPrice,
    List<String>? selectedSports,
    Map<String, int>? selectedSportIds,
    String? bio,
    List<String>? availableDays,
    Map<String, List<String>>? availabilitySlots,
    String? certificateUrl,
  }) {
    return CoachOnboardingDraft(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      city: city ?? this.city,
      experienceYears: experienceYears ?? this.experienceYears,
      sessionPrice: sessionPrice ?? this.sessionPrice,
      selectedSports: selectedSports ?? List<String>.from(this.selectedSports),
      selectedSportIds:
          selectedSportIds ?? Map<String, int>.from(this.selectedSportIds),
      bio: bio ?? this.bio,
      availableDays: availableDays ?? List<String>.from(this.availableDays),
      availabilitySlots:
          availabilitySlots ??
          Map<String, List<String>>.fromEntries(
            this.availabilitySlots.entries.map(
              (entry) => MapEntry(entry.key, List<String>.from(entry.value)),
            ),
          ),
      certificateUrl: certificateUrl ?? this.certificateUrl,
    );
  }

  List<String> get unsupportedSports => selectedSports
      .where((sport) => !_resolveSportId(sport).isValidSportId)
      .toList(growable: false);

  int? _resolveSportId(String sport) {
    final id = selectedSportIds[sport];
    if (id != null && id > 0) {
      return id;
    }
    return supportedSports[sport];
  }

  List<String> get selectedAvailableHours {
    final orderedHours = <String>[];
    final seen = <String>{};

    for (final day in availableDays) {
      for (final hour in availabilitySlots[day] ?? const <String>[]) {
        final normalizedHour = hour.trim();
        if (normalizedHour.isEmpty || !seen.add(normalizedHour)) {
          continue;
        }
        orderedHours.add(normalizedHour);
      }
    }

    return orderedHours;
  }

  Map<String, List<String>> get selectedDayToHours {
    final result = <String, List<String>>{};

    for (final day in availableDays) {
      final hours = <String>[];
      final seen = <String>{};

      for (final hour in availabilitySlots[day] ?? const <String>[]) {
        final normalizedHour = hour.trim();
        if (normalizedHour.isEmpty || !seen.add(normalizedHour)) {
          continue;
        }
        hours.add(normalizedHour);
      }

      if (hours.isNotEmpty) {
        result[day] = hours;
      }
    }

    return result;
  }

  CompleteCoachOnboardingRequest toRequest() {
    final sports = selectedSports
        .where((sport) => _resolveSportId(sport).isValidSportId)
        .map(
          (sport) => CoachOnboardingSportRequest(
            sportID: _resolveSportId(sport)!,
            description: bio,
          ),
        )
        .toList(growable: false);
    final dayToHours = selectedDayToHours;

    return CompleteCoachOnboardingRequest(
      email: email,
      password: password,
      fullName: fullName,
      nationalId: nationalId,
      gender: gender,
      age: age ?? 0,
      city: city,
      experienceYears: experienceYears,
      sessionPrice: sessionPrice,
      sports: sports,
      availableDays: availableDays,
      availableHours: selectedAvailableHours,
      dayHourSlots: dayToHours.entries
          .map(
            (entry) => CoachAvailabilitySlotRequest(
              day: entry.key,
              hours: entry.value,
            ),
          )
          .toList(growable: false),
      bio: bio,
      certificateUrl: certificateUrl,
    );
  }
}

extension on int? {
  bool get isValidSportId => this != null && this! > 0;
}
