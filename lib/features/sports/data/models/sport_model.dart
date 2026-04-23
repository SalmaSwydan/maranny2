class SportModel {
  final int id;
  final String name;

  const SportModel({
    required this.id,
    required this.name,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
