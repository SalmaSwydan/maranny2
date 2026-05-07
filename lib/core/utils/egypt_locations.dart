class EgyptLocations {
  EgyptLocations._();

  static const Map<String, List<String>> areasByCity = {
    'Cairo': [
      'Nasr City',
      'New Cairo',
      'Fifth Settlement',
      'Heliopolis',
      'Misr El Gedida',
      'Maadi',
      'Zamalek',
      'Garden City',
      'Downtown Cairo',
      'Rehab City',
      'Madinaty',
      'Shorouk',
      'Obour',
      'Mokattam',
      'New Capital',
      'Shubra',
      'Ain Shams',
      'Abbasiya',
      'Tagamoa',
      'Cairo Festival City',
      'Katameya',
      'Zahraa El Maadi',
      'El Marg',
      'Helwan',
      'El Nozha',
      'Sheraton',
      'Roxy',
      'Korba',
      'Manial',
      'Sayeda Zeinab',
      'El Basatin',
      'Dar El Salam',
    ],
    'Giza': [
      'Giza',
      'Dokki',
      'Mohandessin',
      'Sheikh Zayed',
      '6th of October',
      'Haram',
      'Faisal',
    ],
  };

  static List<String> get cities => areasByCity.keys.toList(growable: false);

  static List<String> get allAreas => areasByCity.values
      .expand((areas) => areas)
      .toSet()
      .toList(growable: false);

  static List<String> areasForCity(String? city) {
    if (city == null || city.trim().isEmpty) {
      return const [];
    }
    return areasByCity[city.trim()] ?? const [];
  }

  static bool isKnownPlace(String value) {
    final normalized = _normalize(value);
    return cities.any((city) => _normalize(city) == normalized) ||
        allAreas.any((area) => _normalize(area) == normalized);
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
