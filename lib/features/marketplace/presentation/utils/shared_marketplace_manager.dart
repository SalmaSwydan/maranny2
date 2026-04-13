import '../utils/marketplace_product.dart';

class SharedMarketplaceManager {
  SharedMarketplaceManager._();

  static bool _seeded = false;
  static final List<MarketplaceProduct> _products = [];

  static void _seedIfNeeded() {
    if (_seeded) return;
    _seeded = true;
    _products.addAll([
      const MarketplaceProduct(
        id: '1',
        title: 'Professional Football',
        category: 'Equipment',
        condition: 'New',
        price: 350,  // ✅ LE
        imageAsset: 'assets/images/professional_football.png',
        sellerName: 'Sports Store',
        sellerRating: 4.9,
        reviewers: 80,
        location: 'Cairo, Egypt',
        whatsapp: '+20 100 123 4567',
        description: 'Professional grade football perfect for training and matches. Made with high-quality synthetic leather, excellent grip and durability.',
      ),
      const MarketplaceProduct(
        id: '2',
        title: 'Basketball Shoes',
        category: 'Clothing',
        condition: 'New',
        price: 1200,  // ✅ LE
        imageAsset: 'assets/images/basketball_shoes.png',
        sellerName: 'Sports Store',
        sellerRating: 4.9,
        reviewers: 80,
        location: 'Cairo, Egypt',
        whatsapp: '+20 100 123 4567',
        description: 'High-performance shoes designed for comfort and stability.',
      ),
      const MarketplaceProduct(
        id: '3',
        title: 'Yoga Mat',
        category: 'Accessories',
        condition: 'New',
        price: 250,  // ✅ LE
        imageAsset: 'assets/images/yoga_matt.png',
        sellerName: 'Wellness Store',
        sellerRating: 4.5,
        reviewers: 80,
        location: 'Cairo, Egypt',
        whatsapp: '+20 100 123 4567',
        description: 'Non-slip yoga mat perfect for home workouts.',
      ),
      const MarketplaceProduct(
        id: '4',
        title: 'Swimming Goggles',
        category: 'Accessories',
        condition: 'Used',
        price: 120,  // ✅ LE
        imageAsset: 'assets/images/swimming_goggles.png',
        sellerName: 'Sports Store',
        sellerRating: 4.9,
        reviewers: 80,
        location: 'Cairo, Egypt',
        whatsapp: '+20 100 123 4567',
        description: 'Used goggles in good condition.',
      ),
    ]);
  }

  static List<MarketplaceProduct> getProducts() {
    _seedIfNeeded();
    return List<MarketplaceProduct>.from(_products);
  }

  static void addProduct(MarketplaceProduct product) {
    _products.insert(0, product);
  }
}
