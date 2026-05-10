import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/marketplace_product.dart';

class ProductCard extends StatelessWidget {
  final MarketplaceProduct product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE0E7F4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 12,
                child: _buildProductImage(product),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 2),
              child: Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Color(0xFF24345D),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                product.condition,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blueGrey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 5),
              child: Text(
                '${product.price.toStringAsFixed(0)} LE',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 15,
                      color: Colors.blueGrey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        product.sellerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey.shade500,
                        ),
                      ),
                    ),
                    Icon(Icons.star, size: 13, color: Colors.amber.shade700),
                    const SizedBox(width: 2),
                    Text(
                      product.sellerRating.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.info_outline_rounded, size: 17),
                  label: const Text(
                    'More info',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
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
      color: const Color(0xFFEAF0FB),
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Color(0xFF8D99B5),
      ),
    );

    final resolvedImageUrl = ApiConfig.resolveMediaUrl(product.imageAsset);
    debugPrint(
      '[Marketplace][ProductCard] final image url -> $resolvedImageUrl',
    );

    if (resolvedImageUrl.isEmpty) return placeholder();
    final isNetworkImage =
        resolvedImageUrl.startsWith('http://') ||
        resolvedImageUrl.startsWith('https://');
    final isFilePath =
        resolvedImageUrl.startsWith('file:') ||
        RegExp(r'^[A-Za-z]:[\/]').hasMatch(resolvedImageUrl);

    if (isNetworkImage) {
      return Image.network(
        resolvedImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, error, __) {
          debugPrint(
            '[Marketplace][ProductCard] image load error -> url=$resolvedImageUrl error=$error',
          );
          return placeholder();
        },
      );
    }

    if (isFilePath) {
      final file = File(resolvedImageUrl);
      if (!file.existsSync()) return placeholder();
      return Image.file(file, fit: BoxFit.cover);
    }

    return Image.asset(
      resolvedImageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }
}
