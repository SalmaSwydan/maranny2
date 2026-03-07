class MarketplaceProduct {
  final String id;
  final String title;
  final String category; // Equipment, Clothing, Accessories
  final String condition; // New, Used
  final double price;
  final String imageAsset;

  final String sellerName;
  final double sellerRating;
  final int reviewers;

  final String location;
  final String whatsapp;

  final String description;

  const MarketplaceProduct({
    required this.id,
    required this.title,
    required this.category,
    required this.condition,
    required this.price,
    required this.imageAsset,
    required this.sellerName,
    required this.sellerRating,
    required this.reviewers,
    required this.location,
    required this.whatsapp,
    required this.description,
  });
}