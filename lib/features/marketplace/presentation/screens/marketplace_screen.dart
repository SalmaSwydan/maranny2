import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../utils/marketplace_product.dart';
import '../widgets/category_chips.dart';
import '../widgets/marketplace_search_bar.dart';
import '../widgets/product_card.dart';
import 'list_item_screen.dart';
import 'product_details_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final MarketplaceRepository _repository = MarketplaceRepository();

  String _selectedTab = 'All';
  String _search = '';
  bool _isLoading = true;
  String? _error;
  List<MarketplaceProduct> _products = const <MarketplaceProduct>[];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    developer.log(
      'MarketplaceScreen load -> selectedCategory=$_selectedTab searchQuery=$_search',
      name: 'MarketplaceScreen',
    );

    try {
      final products = await _repository.getProducts(
        query: _search,
        category: _selectedTab,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _products = products.map(MarketplaceProduct.fromApi).toList(growable: false);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Could not load marketplace items right now.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openListItem() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListItemScreen(
          onListed: (_) async {
            await _loadProducts();
          },
        ),
      ),
    );
    if (mounted) {
      await _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _openListItem,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
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
            onChanged: (value) {
              setState(() => _search = value);
              _loadProducts();
            },
          ),
          CategoryChips(
            selected: _selectedTab,
            onSelected: (tab) {
              setState(() => _selectedTab = tab);
              _loadProducts();
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: TextButton(
                          onPressed: _loadProducts,
                          child: Text(_error!),
                        ),
                      )
                    : _products.isEmpty
                        ? Center(
                            child: Text(
                              _search.trim().isNotEmpty
                                  ? 'No search results found'
                                  : 'Marketplace is empty right now',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.58,
                            ),
                            itemBuilder: (context, i) {
                              final product = _products[i];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  developer.log(
                                    'Marketplace selected product -> id=${product.id} title=${product.title}',
                                    name: 'MarketplaceScreen',
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                        product: product,
                                      ),
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
