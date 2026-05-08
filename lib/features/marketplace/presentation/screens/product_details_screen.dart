import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../utils/marketplace_product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final MarketplaceProduct product;
  final Future<void> Function()? onDeleted;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onDeleted,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final MarketplaceRepository _repository = MarketplaceRepository();

  late MarketplaceProduct _product;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final productId = int.tryParse(widget.product.id);
    developer.log(
      'Product details selected product -> id=${widget.product.id} title=${widget.product.title}',
      name: 'ProductDetailsScreen',
    );

    if (productId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final details = await _repository.getProductDetails(productId);
      if (!mounted) {
        return;
      }
      setState(() {
        _product = MarketplaceProduct.fromApi(details);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct() async {
    final productId = int.tryParse(_product.id);
    if (productId == null || _isDeleting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text(
          'If you no longer want this item, you can delete it now.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await _repository.deleteProduct(productId);
      if (widget.onDeleted != null) {
        await widget.onDeleted!.call();
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully.')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete this item right now. Please try again.',
          ),
        ),
      );
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final displayCategory = _normalizeText(
      product.category,
      fallback: 'Uncategorized',
    );
    final displayDescription = _normalizeText(
      product.description,
      fallback: 'No description available.',
    );
    final displayLocation = _normalizeText(
      product.location,
      fallback: 'Unknown',
    );
    final displayPhone = product.showPhoneNumber
        ? _displayPhone(product.whatsapp)
        : 'Hidden by seller';
    final hasCallablePhone =
        product.showPhoneNumber &&
        _extractCallablePhone(product.whatsapp).isNotEmpty;
    final displayCondition = _normalizeText(
      product.condition,
      fallback: 'Unknown',
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Product Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: IconButton(
                      onPressed: _isDeleting ? null : _deleteProduct,
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFFFD6D6),
                              size: 22,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildProductImage(product),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          displayCategory,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Condition: $displayCondition',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 18,
                                              color: Colors.amber.shade700,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${product.sellerRating} (${product.reviewers} reviewers)',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '${product.price.toStringAsFixed(0)} LE',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayDescription,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'For Contact',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.lightBlue.withValues(
                                            alpha: 0.3,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.store,
                                          color: Colors.grey.shade700,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.sellerName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amber.shade700,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${product.sellerRating} (${product.reviewers} reviewers)',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 20,
                                        color: AppColors.primaryBlue,
                                      ),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Location',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            displayLocation,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 24),
                                      const Icon(
                                        Icons.message,
                                        size: 20,
                                        color: Color(0xFF25D366),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'WhatsApp / Phone',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              displayPhone,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _callSeller(context, product.whatsapp),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.call, size: 22),
                                label: const Text(
                                  'Call seller',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (!hasCallablePhone) ...[
                            const SizedBox(height: 10),
                            const Center(
                              child: Text(
                                'Seller phone number is not available yet.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callSeller(BuildContext context, String phone) async {
    final cleaned = _extractCallablePhone(phone);
    if (cleaned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller phone number is not available.')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cannot call $phone')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cannot call $phone')));
      }
    }
  }

  Widget _buildProductImage(MarketplaceProduct product) {
    Widget placeholder() => Container(
      width: 100,
      height: 100,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported),
    );
    if (product.imageAsset.isEmpty) {
      return placeholder();
    }
    final isNetworkImage =
        product.imageAsset.startsWith('http://') ||
        product.imageAsset.startsWith('https://');
    final isFilePath =
        product.imageAsset.startsWith('file:') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(product.imageAsset);
    if (isNetworkImage) {
      return Image.network(
        product.imageAsset,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
      );
    }
    if (isFilePath) {
      final file = File(product.imageAsset);
      if (!file.existsSync()) {
        return placeholder();
      }
      return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
    }
    return Image.asset(
      product.imageAsset,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }

  String _normalizeText(String value, {required String fallback}) {
    final cleaned = value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^\{.*\}$'), '')
        .trim();
    if (cleaned.isEmpty || cleaned.toLowerCase() == 'null') {
      return fallback;
    }
    return cleaned;
  }

  String _extractCallablePhone(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    final normalized = cleaned.startsWith('+')
        ? '+${cleaned.substring(1).replaceAll('+', '')}'
        : cleaned;
    if (normalized.replaceAll('+', '').length < 7) {
      return '';
    }
    return normalized;
  }

  String _displayPhone(String value) {
    final normalized = _extractCallablePhone(value);
    if (normalized.isEmpty) {
      return 'Not available';
    }
    if (normalized.startsWith('+') && normalized.length > 4) {
      return '${normalized.substring(0, 4)} ${normalized.substring(4)}';
    }
    if (normalized.length == 11) {
      return '${normalized.substring(0, 4)} ${normalized.substring(4, 7)} ${normalized.substring(7)}';
    }
    return normalized;
  }
}
