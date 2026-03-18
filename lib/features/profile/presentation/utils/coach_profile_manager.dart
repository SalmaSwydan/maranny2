/// Persists coach profile data (edit screen → profile screen).
class CoachProfileManager {
  CoachProfileManager._();

  static String? profileImagePath;
  static String fullName = 'Ahmed Mohamed';
  static String email = 'ahmed.mohamed@example.com';
  static String location = 'Cairo';
  static String phone = '+20 100 123 567';
  static String bio =
      'Lorem ipsum dolor sit amet consectetur. Dolor at est at luctus volutpat aliquet ligula lectus egestas. Quam dolor vestibulum eget malesuada eget nisl iaculis vitae. Aliquam facilisis at pretium viverra. Sed dignissim elementum ut sed lorem. Cras aliquam quam ut elit consectetur adipiscing elit.';
  static int yearsOfExperience = 3;
  static String sessionPrice = '\$25 / hour';

  /// List of uploaded certificates: { 'path': filePath, 'name': displayName }
  static final List<Map<String, String>> certificates = [];

  static void saveProfile({
    String? imagePath,
    String? name,
    String? emailVal,
    String? locationVal,
    String? phoneVal,
    String? bioVal,
    int? years,
    String? price,
  }) {
    if (imagePath != null) profileImagePath = imagePath;
    if (name != null && name.isNotEmpty) fullName = name;
    if (emailVal != null && emailVal.isNotEmpty) email = emailVal;
    if (locationVal != null && locationVal.isNotEmpty) location = locationVal;
    if (phoneVal != null && phoneVal.isNotEmpty) phone = phoneVal;
    if (bioVal != null) bio = bioVal;
    if (years != null) yearsOfExperience = years;
    if (price != null && price.isNotEmpty) sessionPrice = price;
  }

  static void addCertificate(String filePath, String displayName) {
    certificates.add({'path': filePath, 'name': displayName});
  }

  static void clearCertificates() {
    certificates.clear();
  }
}
