import 'package:dio/dio.dart';
import '../../../../core/network/ai_client.dart';
import '../../../../core/network/api_client.dart';
import '../models/recommend_models.dart';

/// ─────────────────────────────────────────────────────────────
/// RECOMMEND REPOSITORY
/// 1. Calls AI service → gets ranked coachId list
/// 2. Calls .NET backend → gets full coach profiles
/// 3. Returns merged result to screen
/// ─────────────────────────────────────────────────────────────
class RecommendRepository {
  final Dio _aiDio  = AiClient.dio;
  final Dio _apiDio = ApiClient.dio;

  Future<List<Map<String, dynamic>>> getRecommendations(
      RecommendRequest request) async {
    final alive = await AiClient.isAlive();
    if (!alive) return _fallbackSearch(request.preferredSports);

    final aiResponse = await _aiDio.post(
      AiClient.recommend,
      data: request.toJson(),
    );
    final recommend = RecommendResponse.fromJson(
        aiResponse.data as Map<String, dynamic>);

    if (recommend.recommendations.isEmpty) return [];

    // TODO: replace with actual .NET endpoint when ready
    final profilesResponse = await _apiDio.post(
      '/coaches/by-ids',
      data: {'ids': recommend.coachIds},
    );

    final profiles = List<Map<String, dynamic>>.from(
        profilesResponse.data as List<dynamic>);

    final explanationMap = {
      for (final r in recommend.recommendations) r.coachId: r.explanation
    };

    return profiles.map((profile) {
      final id          = profile['id'].toString();
      final explanation = explanationMap[id];
      return {
        ...profile,
        'aiScore': recommend.recommendations
            .firstWhere((r) => r.coachId == id,
            orElse: () => CoachRecommendation(
                coachId: id,
                score: 0,
                explanation: AiExplanation(
                    distance: '', sport: '', price: '',
                    rating: '', availability: '')))
            .score,
        'aiExplanation': explanation != null
            ? {
          'distance':     explanation.distance,
          'sport':        explanation.sport,
          'price':        explanation.price,
          'rating':       explanation.rating,
          'availability': explanation.availability,
        }
            : null,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fallbackSearch(
      String sport) async {
    try {
      final response = await _apiDio.get(
        '/search/coaches',
        queryParameters: {'sport': sport},
      );
      return List<Map<String, dynamic>>.from(
          response.data as List<dynamic>);
    } catch (_) {
      return [];
    }
  }
}