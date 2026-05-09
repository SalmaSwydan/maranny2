import '../utils/marketplace_product.dart';

class SharedMarketplaceManager {
  SharedMarketplaceManager._();

  static final List<MarketplaceProduct> _products = [];

  static List<MarketplaceProduct> getProducts() {
    return List<MarketplaceProduct>.from(_products);
  }

  static void addProduct(MarketplaceProduct product) {
    _products.insert(0, product);
  }
}
