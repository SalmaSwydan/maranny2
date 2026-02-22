import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../utils/marketplace_product.dart';
import '../utils/shared_marketplace_manager.dart';
import '../widgets/category_chips.dart';
import '../widgets/marketplace_search_bar.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'list_item_screen.dart';

import '../../../home/presentation/widgets/bottom_navigation.dart';
import '../../../home/presentation/screens/coach_homescreen.dart';
import '../../../bookings/presentation/screens/upcoming_pending.dart';
import '../../../messages/presentation/screens/messages_clients.dart';
import '../../../profile/presentation/screens/coach_profile_screen.dart';

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

  void _navigateFromBottomNav(int index) {
    if (index == 2) return; // Marketplace

    Widget page;
    switch (index) {
      case 0:
      // If CoachHomeScreen requires onAuthRequired and null doesn't compile,
      // we will adjust CoachHomeScreen signature safely.
        page = CoachHomeScreen(onAuthRequired: () {});
        break;
      case 1:
        page = const UpcomingScreen();
        break;
      case 3:
        page = const MessagesClientsScreen();
        break;
      case 4:
        page = const CoachProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar: CoachBottomNav(
        initialIndex: 2,
        onItemSelected: _navigateFromBottomNav,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Gradient header - Market Place
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
                  childAspectRatio: 0.70,
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
      ),
    );
  }
}