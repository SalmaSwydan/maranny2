import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../bookings/data/models/reviews_payments_models.dart';
import '../../../bookings/data/repositories/reviews_payments_repository.dart';
import '../../../home/presentation/widgets/review_card.dart';

class AllReviewsScreen extends StatefulWidget {
  const AllReviewsScreen({super.key});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final ReviewsRepository _reviewsRepository = ReviewsRepository();

  bool _isLoading = true;
  List<ReviewModel> _reviews = const <ReviewModel>[];
  ReviewsSummary _summary = const ReviewsSummary(
    averageRating: 0,
    totalReviews: 0,
    ratingBreakdown: <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
  );

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviewsPage = await _reviewsRepository.getMyCoachReviews(pageSize: 100);
      if (!mounted) {
        return;
      }
      setState(() {
        _reviews = reviewsPage.reviews;
        _summary = reviewsPage.summary;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _reviews = const <ReviewModel>[];
        _summary = const ReviewsSummary(
          averageRating: 0,
          totalReviews: 0,
          ratingBreakdown: <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        );
        _isLoading = false;
      });
    }
  }

  double _getRatingPercentage(int stars) {
    if (_summary.totalReviews == 0) {
      return 0;
    }
    return (_summary.ratingBreakdown[stars] ?? 0) / _summary.totalReviews;
  }

  String _formatReviewTime(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    final local = parsed.isUtc ? parsed.toLocal() : parsed;
    final difference = DateTime.now().difference(local);
    if (difference.inDays >= 1) {
      return '${difference.inDays} days ago';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    }
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final averageRating = _summary.averageRating;
    final totalReviews = _summary.totalReviews;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF6FD3F5),
                  Color(0xFF1F3A93),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'All Reviews',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$totalReviews reviews',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(5, (index) {
                                    final stars = 5 - index;
                                    final percentage = _getRatingPercentage(stars);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Text(
                                            '$stars',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.3),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: percentage,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_reviews.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                            child: Center(
                              child: Text(
                                'No reviews yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ..._reviews.map(
                            (review) => ReviewCard(
                              name: review.clientName,
                              review: review.comment.isNotEmpty
                                  ? review.comment
                                  : 'No written comment provided.',
                              timestamp: _formatReviewTime(review.createdAt),
                              rating: review.rating.round().clamp(0, 5),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
