class SportModel {
  final int id;
  final String name;

  const SportModel({required this.id, required this.name});

  static const Set<String> hiddenSportNames = {'Yoga'};

  static bool isVisibleName(String sport) =>
      !hiddenSportNames.contains(sport.trim());

  static List<SportModel> visible(Iterable<SportModel> sports) {
    return sports
        .where((sport) => sport.id > 0 && isVisibleName(sport.name))
        .toList(growable: false);
  }

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: _asInt(json['id'] ?? json['sportID'] ?? json['sportId']),
      name: (json['name'] ?? json['sportName'] ?? '').toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
