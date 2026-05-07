class SportModel {
  final int id;
  final String name;

  const SportModel({required this.id, required this.name});

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
