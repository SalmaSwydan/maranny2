import 'egypt_locations.dart';

class ProfileValidators {
  ProfileValidators._();

  static final RegExp _nameRegex = RegExp(
    r"^[A-Za-z\u0600-\u06FF]+(?:\s+[A-Za-z\u0600-\u06FF]+)+$",
  );

  static final RegExp _egyptPhoneRegex = RegExp(
    r'^(?:\+20|20|0)?1[0125][0-9]{8}$',
  );

  static bool isValidName(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return normalized.length >= 5 && _nameRegex.hasMatch(normalized);
  }

  static bool isValidEgyptPhone(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    return _egyptPhoneRegex.hasMatch(normalized);
  }

  static String normalizeEgyptPhone(String value) {
    var digits = value.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0020')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = '20${digits.substring(1)}';
    } else if (digits.startsWith('1')) {
      digits = '20$digits';
    }
    return '+$digits';
  }

  static bool isValidLocation(String value) =>
      EgyptLocations.isKnownPlace(value.trim());

  static int sentenceCount(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return 0;
    }

    final punctuated = text
        .split(RegExp(r'[.!?؟]+'))
        .map((part) => part.trim())
        .where((part) => part.split(RegExp(r'\s+')).length >= 3)
        .length;
    if (punctuated >= 3) {
      return punctuated;
    }

    return text
        .split(RegExp(r'\n+'))
        .map((part) => part.trim())
        .where((part) => part.split(RegExp(r'\s+')).length >= 3)
        .length;
  }

  static bool hasThreeSentenceBio(String value) => sentenceCount(value) >= 3;

  static int wordCount(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .length;

  static bool hasFiftyWordBio(String value) => wordCount(value) >= 50;

  static List<String> missingClientProfileFields({
    required String? profilePicture,
    required String? phone,
    required String? location,
    List<String> sports = const [],
  }) {
    final missing = <String>[];
    if ((profilePicture ?? '').trim().isEmpty) {
      missing.add('profile photo');
    }
    if (!isValidEgyptPhone(phone ?? '')) {
      missing.add('valid Egyptian phone number');
    }
    if (!isValidLocation(location ?? '')) {
      missing.add('Cairo/Giza area');
    }
    if (sports.where((sport) => sport.trim().isNotEmpty).isEmpty) {
      missing.add('preferred sport');
    }
    return missing;
  }
}
