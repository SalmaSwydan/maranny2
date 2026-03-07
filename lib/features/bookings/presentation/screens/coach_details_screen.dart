import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../domain/models/booking_session_model.dart';
import '../widgets/book_session_sheet.dart';

class CoachDetailsScreen extends StatelessWidget {
  final BookingSessionModel session;
  final String image;

  const CoachDetailsScreen({
    super.key,
    required this.session,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [

                  /// Coach Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// Coach Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          session.coachName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "${session.sport} Coach",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              session.location,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// Price
                  const Column(
                    children: [
                      Text(
                        "\$25 / hr",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "per session",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [

                  _StatCard(
                    "12",
                    "Total Students",
                    AppAssets.icon_1_coach,
                  ),

                  _StatCard(
                    "245",
                    "Total Sessions",
                    AppAssets.icon_2_coach,
                  ),

                  _StatCard(
                    "328.5",
                    "Hours Taught",
                    AppAssets.icon_3_coach,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// BIO
            const _Section(
              title: "Bio",
              child: Text(
                "Professional coach with years of experience helping players improve their skills and confidence.",
              ),
            ),

            /// ACHIEVEMENTS
            _Section(
              title: "Achievements",
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [

                  _AchievementCard("🏆", "Quick Starter"),
                  _AchievementCard("⭐", "Consistent Trainer"),
                  _AchievementCard("📈", "Verified Member"),
                  _AchievementCard("🥇", "Super Rater"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// REVIEWS
            const _Section(
              title: "Reviews",
              child: Column(
                children: [

                  _ReviewTile(
                    name: "Aya Hassan",
                    comment:
                    "Excellent coach! Really helped improve my football skills.",
                  ),

                  SizedBox(height: 12),

                  _ReviewTile(
                    name: "Omar Ahmed",
                    comment:
                    "Very professional and patient. My son learned so much!",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// BOOK SESSION BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      builder: (context) {
                        return const BookSessionSheet();
                      },
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Book Session"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String title;
  final String icon;

  const _StatCard(this.number, this.title, this.icon);

  bool get isSvg => icon.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        children: [

          isSvg
              ? SvgPicture.asset(
            icon,
            height: 28,
            width: 28,
          )
              : Image.asset(
            icon,
            height: 28,
            width: 28,
          ),

          const SizedBox(height: 6),

          Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          child
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String icon;
  final String title;

  const _AchievementCard(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(icon, style: const TextStyle(fontSize: 28)),

          const SizedBox(height: 6),

          Text(title, textAlign: TextAlign.center)
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final String comment;

  const _ReviewTile({
    required this.name,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        const CircleAvatar(
          child: Icon(Icons.person),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                comment,
                style: const TextStyle(fontSize: 12),
              )
            ],
          ),
        )
      ],
    );
  }
}