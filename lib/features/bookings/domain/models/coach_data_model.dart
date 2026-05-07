// FILE: lib/features/bookings/domain/models/coach_data_model.dart

class CoachReview {
  final String name;
  final String comment;
  final String date;
  final int rating;

  const CoachReview({
    required this.name,
    required this.comment,
    required this.date,
    required this.rating,
  });
}

class CoachAchievement {
  final String emoji;
  final String title;
  final String subtitle;

  const CoachAchievement({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class CoachData {
  final String name;
  final String sport;
  final int? sportId;
  final String location; // ✅ single field — "Area, City"
  final String image;
  final List<String> availableDays;
  final double rating;
  final int reviewCount;
  final int price;
  final String bio;
  final int totalStudents;
  final int totalSessions;
  final double hoursTaught;
  final List<CoachAchievement> achievements;
  final List<CoachReview> reviews;

  const CoachData({
    required this.name,
    required this.sport,
    this.sportId,
    required this.location,
    required this.image,
    this.availableDays = const [],
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.bio,
    required this.totalStudents,
    required this.totalSessions,
    required this.hoursTaught,
    required this.achievements,
    required this.reviews,
  });
}

// ── All coaches data ─────────────────────────────────

final List<CoachData> allCoachesData = [
  CoachData(
    name: 'Ahmed Mohamed',
    sport: 'Football',
    location: 'Nasr City, Cairo',
    image: 'assets/images/coach_ahmed_mohamed.png',
    rating: 4.9,
    reviewCount: 80,
    price: 500,
    bio:
        'Ahmed is a certified UEFA football coach with over 10 years of experience training youth and adult players. He specializes in technical skill development, tactical awareness, and physical conditioning. His sessions are intense but fun.',
    totalStudents: 120,
    totalSessions: 340,
    hoursTaught: 510.0,
    achievements: [
      CoachAchievement(
        emoji: '🏆',
        title: 'Top Rated',
        subtitle: 'Rated 4.9 by clients',
      ),
      CoachAchievement(
        emoji: '⭐',
        title: 'Expert Trainer',
        subtitle: 'Completed 300+ sessions',
      ),
      CoachAchievement(
        emoji: '📈',
        title: 'Verified Coach',
        subtitle: 'UEFA certified',
      ),
      CoachAchievement(
        emoji: '🥇',
        title: 'Super Rater',
        subtitle: 'Completed 50+ reviews',
      ),
    ],
    reviews: [
      CoachReview(
        name: 'Karim Hassan',
        comment: 'Ahmed really transformed my game. His drills are excellent!',
        date: 'Dec 20, 2025',
        rating: 5,
      ),
      CoachReview(
        name: 'Nour Ali',
        comment: 'Very professional. My son improved a lot in just 2 months.',
        date: 'Dec 10, 2025',
        rating: 5,
      ),
    ],
  ),

  CoachData(
    name: 'Sarah Ahmed',
    sport: 'Swimming',
    location: 'Maadi, Cairo',
    image: 'assets/images/coach_sarah_Ahmed.jpeg',
    rating: 4.7,
    reviewCount: 77,
    price: 400,
    bio:
        'Sarah is a competitive swimmer turned coach with 8 years of coaching experience. She has trained swimmers of all levels, from beginners to competitive athletes. She is patient, encouraging, and results-driven.',
    totalStudents: 95,
    totalSessions: 280,
    hoursTaught: 420.0,
    achievements: [
      CoachAchievement(
        emoji: '🏊',
        title: 'Swim Expert',
        subtitle: 'Trained 95+ swimmers',
      ),
      CoachAchievement(
        emoji: '⭐',
        title: 'Consistent Coach',
        subtitle: 'Completed 250+ sessions',
      ),
      CoachAchievement(
        emoji: '📈',
        title: 'Verified Coach',
        subtitle: 'Nationally certified',
      ),
      CoachAchievement(
        emoji: '🥇',
        title: 'Top Reviewer',
        subtitle: '4.7 average rating',
      ),
    ],
    reviews: [
      CoachReview(
        name: 'Layla Omar',
        comment:
            'Sarah is amazing! I went from scared of water to swimming laps.',
        date: 'Jan 5, 2026',
        rating: 5,
      ),
      CoachReview(
        name: 'Youssef Tarek',
        comment: 'Great technique coaching. Very patient with beginners.',
        date: 'Dec 22, 2025',
        rating: 4,
      ),
    ],
  ),

  CoachData(
    name: 'Sara Ahmed',
    sport: 'Swimming',
    location: 'Maadi, Cairo',
    image: 'assets/images/coach_sarah_Ahmed.jpeg',
    rating: 4.7,
    reviewCount: 77,
    price: 400,
    bio:
        'Sara is a competitive swimmer turned coach with 8 years of coaching experience. She has trained swimmers of all levels, from beginners to competitive athletes. She is patient, encouraging, and results-driven.',
    totalStudents: 95,
    totalSessions: 280,
    hoursTaught: 420.0,
    achievements: [
      CoachAchievement(
        emoji: '🏊',
        title: 'Swim Expert',
        subtitle: 'Trained 95+ swimmers',
      ),
      CoachAchievement(
        emoji: '⭐',
        title: 'Consistent Coach',
        subtitle: 'Completed 250+ sessions',
      ),
      CoachAchievement(
        emoji: '📈',
        title: 'Verified Coach',
        subtitle: 'Nationally certified',
      ),
      CoachAchievement(
        emoji: '🥇',
        title: 'Top Reviewer',
        subtitle: '4.7 average rating',
      ),
    ],
    reviews: [
      CoachReview(
        name: 'Layla Omar',
        comment:
            'Sara is amazing! I went from scared of water to swimming laps.',
        date: 'Jan 5, 2026',
        rating: 5,
      ),
      CoachReview(
        name: 'Youssef Tarek',
        comment: 'Great technique coaching. Very patient with beginners.',
        date: 'Dec 22, 2025',
        rating: 4,
      ),
    ],
  ),

  CoachData(
    name: 'Nancy Ali',
    sport: 'Yoga',
    location: 'Sheikh Zayed, Giza',
    image: 'assets/images/coach_nancy_ali.png',
    rating: 4.9,
    reviewCount: 80,
    price: 350,
    bio:
        'Nancy is a certified yoga instructor with a deep passion for mindfulness and holistic wellness. She teaches Hatha, Vinyasa, and restorative yoga. Her classes help clients reduce stress, improve flexibility, and build inner strength.',
    totalStudents: 85,
    totalSessions: 200,
    hoursTaught: 300.0,
    achievements: [
      CoachAchievement(
        emoji: '🧘',
        title: 'Yoga Master',
        subtitle: 'RYT 500 certified',
      ),
      CoachAchievement(
        emoji: '⭐',
        title: 'Mindful Coach',
        subtitle: 'Completed 200+ sessions',
      ),
      CoachAchievement(
        emoji: '📈',
        title: 'Verified Coach',
        subtitle: 'Internationally certified',
      ),
      CoachAchievement(
        emoji: '🌟',
        title: 'Wellness Expert',
        subtitle: 'Holistic health coach',
      ),
    ],
    reviews: [
      CoachReview(
        name: 'Hana Samir',
        comment:
            'Nancy changed my life! I sleep better and feel less stressed.',
        date: 'Jan 8, 2026',
        rating: 5,
      ),
      CoachReview(
        name: 'Rana Mostafa',
        comment:
            'Incredibly calming sessions. Highly recommend for stress relief.',
        date: 'Dec 30, 2025',
        rating: 5,
      ),
    ],
  ),

  CoachData(
    name: 'Ziad Marwan',
    sport: 'Padel',
    location: '5th Settlement, New Cairo',
    image: 'assets/images/ZiadMarwanPADEL.jpeg',
    rating: 4.7,
    reviewCount: 16,
    price: 600,
    bio:
        'Ziad is one of Egypt\'s top padel coaches, having competed professionally for 6 years before transitioning to coaching. He offers technical and tactical training for all levels, with a focus on court positioning and team strategy.',
    totalStudents: 40,
    totalSessions: 95,
    hoursTaught: 142.5,
    achievements: [
      CoachAchievement(
        emoji: '🎾',
        title: 'Padel Pro',
        subtitle: 'Former competitive player',
      ),
      CoachAchievement(
        emoji: '⭐',
        title: 'Rising Coach',
        subtitle: 'Completed 90+ sessions',
      ),
      CoachAchievement(
        emoji: '📈',
        title: 'Verified Coach',
        subtitle: 'National federation cert',
      ),
      CoachAchievement(
        emoji: '🏅',
        title: 'Quick Starter',
        subtitle: 'Booked first session',
      ),
    ],
    reviews: [
      CoachReview(
        name: 'Tarek Fawzy',
        comment:
            'Ziad really understands the game deeply. Great tactical advice.',
        date: 'Jan 2, 2026',
        rating: 5,
      ),
      CoachReview(
        name: 'Mira Adel',
        comment: 'Fun sessions and very informative. My game improved a lot!',
        date: 'Dec 15, 2025',
        rating: 4,
      ),
    ],
  ),

  CoachData(
    name: 'Omar Khaled',
    sport: 'Fitness',
    location: 'Heliopolis, Cairo',
    image: 'assets/images/coach_omar_khaled.png',
    rating: 4.8,
    reviewCount: 42,
    price: 300,
    bio:
        'Omar is a certified personal trainer and nutrition coach with 7 years of experience helping clients achieve their fitness goals. He specializes in weight loss, muscle building, and functional fitness training.',
    totalStudents: 68,
    totalSessions: 190,
    hoursTaught: 285.0,
    achievements: [
      CoachAchievement(
        emoji: '💪',
        title: 'Fitness Expert',
        subtitle: 'ACE certified trainer',
      ),
      CoachAchievement(
        emoji: '⭐',
        title: 'Dedicated Coach',
        subtitle: 'Completed 180+ sessions',
      ),
      CoachAchievement(
        emoji: '🥗',
        title: 'Nutrition Coach',
        subtitle: 'Certified nutritionist',
      ),
      CoachAchievement(
        emoji: '🏅',
        title: 'Top Performer',
        subtitle: '4.8 average rating',
      ),
    ],
    reviews: [
      CoachReview(
        name: 'Salma Wael',
        comment: 'Omar helped me lose 10kg in 3 months. Amazing coach!',
        date: 'Jan 10, 2026',
        rating: 5,
      ),
      CoachReview(
        name: 'Hassan Nabil',
        comment:
            'Very motivating and knowledgeable. Pushes you to your limits.',
        date: 'Dec 28, 2025',
        rating: 5,
      ),
    ],
  ),
];
