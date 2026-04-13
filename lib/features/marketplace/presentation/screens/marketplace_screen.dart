import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/marketplace_product.dart';
import '../utils/shared_marketplace_manager.dart';
import '../widgets/category_chips.dart';
import '../widgets/marketplace_search_bar.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'list_item_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedTab = 'All';
  String _search = '';

  late List<MarketplaceProduct> _products;

  @override
  void initState() {
    super.initState();
    _products = SharedMarketplaceManager.getProducts();
  }

  void _onItemListed(MarketplaceProduct product) {
    SharedMarketplaceManager.addProduct(product);
    setState(() {
      _products = SharedMarketplaceManager.getProducts();
    });
  }

  List<MarketplaceProduct> get _filtered {
    final q = _search.trim().toLowerCase();
    return _products.where((p) {
      final matchesSearch = q.isEmpty ? true : p.title.toLowerCase().contains(q);
      final matchesTab = () {
        if (_selectedTab == 'All') return true;
        if (_selectedTab == 'Used') return p.condition == 'Used';
        return p.category == _selectedTab;
      }();
      return matchesSearch && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: use MediaQuery so header fills under status bar
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ListItemScreen(onListed: _onItemListed),
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // ✅ NO SafeArea — header handles the top padding manually
      body: Column(
        children: [
          // ✅ Header extends under status bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 20),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: const Text(
              'Market Place',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          MarketplaceSearchBar(
            hint: 'Search for what you need',
            onChanged: (v) => setState(() => _search = v),
          ),
          CategoryChips(
            selected: _selectedTab,
            onSelected: (tab) => setState(() => _selectedTab = tab),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (context, i) {
                final product = _filtered[i];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
