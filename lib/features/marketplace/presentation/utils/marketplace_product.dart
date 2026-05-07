import '../../data/models/marketplace_models.dart';

class MarketplaceProduct {
  final String id;
  final String title;
  final String category;
  final String condition;
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

  factory MarketplaceProduct.fromApi(ProductModel model) {
    return MarketplaceProduct(
      id: model.productId.toString(),
      title: model.title,
      category: model.categoryName,
      condition: model.condition,
      price: model.price,
      imageAsset: model.imageUrl,
      sellerName: model.sellerName,
      sellerRating: model.rating,
      reviewers: model.reviewsCount,
      location: model.location,
      whatsapp: model.sellerPhone,
      description: model.description,
    );
  }
}
