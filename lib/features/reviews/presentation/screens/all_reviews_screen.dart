import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cairo_time.dart';
import '../../../bookings/data/models/reviews_payments_models.dart';
import '../../../bookings/data/repositories/reviews_payments_repository.dart';

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
      final reviewsPage = await _reviewsRepository.getMyCoachReviews(
        pageSize: 100,
      );
      if (!mounted) return;
      setState(() {
        _reviews = reviewsPage.reviews;
        _summary = reviewsPage.summary;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
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
    if (_summary.totalReviews == 0) return 0;
    return (_summary.ratingBreakdown[stars] ?? 0) / _summary.totalReviews;
  }

  String _formatReviewTime(String raw) {
    final parsed = CairoTime.parse(raw);
    if (parsed == null) return raw;
    final difference = CairoTime.now().difference(parsed);
    if (difference.inDays >= 1) return '${difference.inDays} days ago';
    if (difference.inHours >= 1) return '${difference.inHours} hours ago';
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadReviews,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              _buildTopBar(),
              const SizedBox(height: 22),
              const Text(
                'COACH FEEDBACK',
                style: TextStyle(
                  color: Color(0xFF91A0C0),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.4,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reviews.',
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Real ratings from clients after completed sessions.',
                style: TextStyle(
                  color: Color(0xFF657392),
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 22),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _buildSummaryCard(),
                const SizedBox(height: 20),
                _buildSectionLabel('Client reviews'),
                const SizedBox(height: 10),
                if (_reviews.isEmpty)
                  _buildEmptyState()
                else
                  ..._reviews.map(_buildReviewCard),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.deepBlue,
                size: 18,
              ),
            ),
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _loadReviews,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.refresh_rounded,
                color: AppColors.deepBlue,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF203B98), Color(0xFF5ED1F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 118,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 32),
                const SizedBox(height: 8),
                Text(
                  _summary.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${_summary.totalReviews} reviews',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                return _buildRatingBar(stars);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Row(
              children: [
                Text(
                  '$stars',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: _getRatingPercentage(stars),
                backgroundColor: Colors.white.withValues(alpha: 0.24),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final rating = review.rating.round().clamp(0, 5);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE7FA)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.clientName.trim().isEmpty
                        ? 'C'
                        : review.clientName.trim()[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatReviewTime(review.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF7A86A5),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: index < rating
                        ? Colors.amber
                        : const Color(0xFFDDE7FA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            review.comment.isNotEmpty
                ? review.comment
                : 'No written comment provided.',
            style: const TextStyle(
              color: Color(0xFF34405F),
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          if (review.sportName.isNotEmpty) ...[
            const SizedBox(height: 12),
            _tag(review.sportName),
          ],
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.deepBlue,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDDE7FA)),
      ),
      child: const Column(
        children: [
          Icon(Icons.rate_review_outlined, color: Color(0xFFB7C2DA), size: 44),
          SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: TextStyle(
              color: AppColors.deepBlue,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Client feedback will appear here after completed sessions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7A86A5),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF91A0C0),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
        fontFamily: 'Inter',
      ),
    );
  }
}
