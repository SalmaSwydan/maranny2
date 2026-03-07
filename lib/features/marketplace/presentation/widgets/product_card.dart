import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../utils/marketplace_product.dart';

class ProductCard extends StatelessWidget {
  final MarketplaceProduct product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 16 / 12,
                child: _buildProductImage(product),
              ),
            ),

            /// Product title
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            /// Condition
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                product.condition,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),

            /// Price
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
              child: Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),

            /// Seller info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        product.sellerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 2),

                    Text(
                      product.sellerRating.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            /// Contact seller button
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Contact seller'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(MarketplaceProduct product) {
    Widget placeholder() => Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 40),
    );

    if (product.imageAsset.isEmpty) return placeholder();

    final isFilePath = product.imageAsset.startsWith('/') ||
        product.imageAsset.startsWith('file:') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(product.imageAsset);

    if (isFilePath) {
      final file = File(product.imageAsset);
      if (!file.existsSync()) return placeholder();

      return Image.file(
        file,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      product.imageAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }
}