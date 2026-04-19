import 'package:dio/dio.dart';
import '../../../../core/network/ai_client.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/utils/user_preferences_storage.dart';
import '../models/recommend_models.dart';

/// ─────────────────────────────────────────────────────────────
/// RECOMMEND REPOSITORY
/// Full AI recommendation flow:
///   1. Load user preferences (saved during onboarding)
///   2. Build RecommendRequest with sport + preferences
///   3. Call AI service → get ranked coachId list
///   4. Call .NET backend → get full coach profiles
///   5. Merge AI explanation into profiles
///   6. Return to screen
/// ─────────────────────────────────────────────────────────────
class RecommendRepository {
  final Dio _aiDio  = AiClient.dio;
  final Dio _apiDio = ApiClient.dio;

  /// Main call — sport is required, all filters optional
  /// If no filters passed → loads saved preferences automatically
  Future<List<Map<String, dynamic>>> getRecommendations({
    required String sport,
    double?  budgetMin,
    double?  budgetMax,
    String?  city,
    String?  locationPreference,
    double?  minRating,
    bool?    isCertified,
    String?  coachGender,
    String?  coachAgeRange,
    bool     usesavedPreferences = true,
  }) async {
    // ── Step 1: Load saved preferences if no filters passed ──
    UserPreferences? savedPrefs;
    if (usesavedPreferences) {
      savedPrefs = await UserPreferencesStorage.load();
    }

    // ── Step 2: Get userId for personalized ranking ───────────
    final userId = await TokenStorage.getAccessToken() != null
        ? await _getUserId()
        : null;

    // ── Step 3: Build request ─────────────────────────────────
    // Passed filters override saved preferences
    final request = RecommendRequest(
      preferredSports:      sport,
      userId:               userId,
      budgetMin:            budgetMin   ?? savedPrefs?.budgetMin,
      budgetMax:            budgetMax   ?? savedPrefs?.budgetMax,
      userCity:             city        ?? savedPrefs?.city,
      locationPreference:   locationPreference ?? savedPrefs?.locationPreference,
      minRating:            minRating   ?? savedPrefs?.minRating,
      isCertified:          isCertified ?? (savedPrefs?.certifiedOnly == true ? true : null),
      preferredCoachGender: coachGender ?? savedPrefs?.coachGender,
      preferredCoachAgeRange: coachAgeRange ?? savedPrefs?.coachAgeRange,
    );

    // ── Step 4: Check AI alive ────────────────────────────────
    final alive = await AiClient.isAlive();
    if (!alive) {
      return _fallbackSearch(sport);
    }

    // ── Step 5: Call AI service ───────────────────────────────
    try {
      final aiResponse = await _aiDio.post(
        AiClient.recommend,
        data: request.toJson(),
      );
      final recommend = RecommendResponse.fromJson(
          aiResponse.data as Map<String, dynamic>);

      if (recommend.recommendations.isEmpty) return [];

      // ── Step 6: Fetch full profiles from .NET ─────────────
      // TODO: replace with actual endpoint when backend team provides it
      // Expected: POST /api/coaches/by-ids  body: { "ids": ["998", "502"] }
      final profilesResponse = await _apiDio.post(
        '/coaches/by-ids',
        data: {'ids': recommend.coachIds},
      );

      final profiles = List<Map<String, dynamic>>.from(
          profilesResponse.data as List<dynamic>);

      // ── Step 7: Merge AI explanation into profiles ─────────
      final explanationMap = {
        for (final r in recommend.recommendations) r.coachId: r
      };

      return profiles.map((profile) {
        final id  = profile['id'].toString();
        final rec = explanationMap[id];
        return {
          ...profile,
          'aiScore':       rec?.score,
          'aiExplanation': rec != null
              ? {
            'distance':     rec.explanation.distance,
            'sport':        rec.explanation.sport,
            'price':        rec.explanation.price,
            'rating':       rec.explanation.rating,
            'availability': rec.explanation.availability,
          }
              : null,
        };
      }).toList();
    } catch (e) {
      return _fallbackSearch(sport);
    }
  }

  /// Fallback when AI service is offline
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

  /// Get current user's ID for personalized ranking
  Future<String?> _getUserId() async {
    try {
      final response = await _apiDio.get('/auth/me');
      return response.data['id']?.toString();
    } catch (_) {
      return null;
    }
  }
}