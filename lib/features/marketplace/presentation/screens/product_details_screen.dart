import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../messages/presentation/screens/chat_screen.dart';
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
      setState(() => _isLoading = false);
      return;
    }

    try {
      final details = await _repository.getProductDetails(productId);
      if (!mounted) return;
      setState(() {
        _product = MarketplaceProduct.fromApi(details);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct() async {
    final productId = int.tryParse(_product.id);
    if (productId == null || _isDeleting) return;

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

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await _repository.deleteProduct(productId);
      if (widget.onDeleted != null) {
        await widget.onDeleted!.call();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully.')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete this item right now. Please try again.',
          ),
        ),
      );
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final displayCategory = _normalizeText(product.category, fallback: 'Gear');
    final displayDescription = _normalizeText(
      product.description,
      fallback: 'No description available yet.',
    );
    final displayLocation = _normalizeText(
      product.location,
      fallback: 'Not specified',
    );
    final displayCondition = _normalizeText(
      product.condition,
      fallback: 'Available',
    );
    final displayPhone = product.showPhoneNumber
        ? _displayPhone(product.whatsapp)
        : 'Hidden by seller';
    final hasCallablePhone =
        product.showPhoneNumber &&
        _extractCallablePhone(product.whatsapp).isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(28, 18, 28, 30),
                          color: const Color(0xFFF4F0E8),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: SizedBox(
                                height: 230,
                                width: double.infinity,
                                child: _buildProductImage(product),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F7FF),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${displayCategory.toUpperCase()}  •  ${displayCondition.toUpperCase()}',
                                style: const TextStyle(
                                  color: Color(0xFF9AA7C5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontSize: 29,
                                        height: 1,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    '${product.price.toStringAsFixed(0)} LE',
                                    style: const TextStyle(
                                      color: Color(0xFF60D9EF),
                                      fontSize: 29,
                                      height: 1,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _SellerCard(
                                sellerName: product.sellerName,
                                onMessage: () => _openSellerChat(product),
                              ),
                              const SizedBox(height: 24),
                              const _SectionLabel('DESCRIPTION'),
                              const SizedBox(height: 10),
                              Text(
                                displayDescription,
                                style: const TextStyle(
                                  color: Color(0xFF405072),
                                  fontSize: 14.5,
                                  height: 1.55,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 28),
                              const _SectionLabel('DETAILS'),
                              const SizedBox(height: 10),
                              _DetailsTable(
                                rows: [
                                  _DetailRow('Condition', displayCondition),
                                  _DetailRow('Pickup', displayLocation),
                                  _DetailRow('Phone', displayPhone),
                                  _DetailRow('Seller', product.sellerName),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: _PrimaryActionButton(
                                      icon: Icons.call_rounded,
                                      label: 'Call seller',
                                      enabled: hasCallablePhone,
                                      onPressed: () => _callSeller(
                                        context,
                                        product.whatsapp,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _DeleteButton(
                                    isDeleting: _isDeleting,
                                    onPressed: _deleteProduct,
                                  ),
                                ],
                              ),
                              if (!hasCallablePhone) ...[
                                const SizedBox(height: 10),
                                const Center(
                                  child: Text(
                                    'Seller phone number is not available yet.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7E8CAD),
                                      fontWeight: FontWeight.w700,
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
                  Positioned(
                    top: 12,
                    left: 16,
                    child: _TopCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 16,
                    child: _TopCircleButton(
                      icon: Icons.delete_outline_rounded,
                      iconColor: const Color(0xFFE53935),
                      onPressed: _isDeleting ? null : _deleteProduct,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _openSellerChat(MarketplaceProduct product) {
    final sellerUserId = product.sellerUserId;
    if (sellerUserId == null || sellerUserId <= 0) {
      _showMessageUnavailable();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: sellerUserId,
          name: product.sellerName,
          isOnline: false,
        ),
      ),
    );
  }

  void _showMessageUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seller chat is not available yet.')),
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
      color: const Color(0xFFE7EDF8),
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: Color(0xFF8D99B5),
      ),
    );

    final imageUrl = ApiConfig.resolveMediaUrl(product.imageAsset);
    if (imageUrl.isEmpty) return placeholder();

    final isNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    final isFilePath =
        imageUrl.startsWith('file:') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(imageUrl);

    if (isNetworkImage) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
      );
    }
    if (isFilePath) {
      final file = File(imageUrl);
      if (!file.existsSync()) return placeholder();
      return Image.file(file, fit: BoxFit.cover);
    }
    return Image.asset(
      imageUrl,
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
    if (normalized.isEmpty) return 'Not available';
    if (normalized.startsWith('+') && normalized.length > 4) {
      return '${normalized.substring(0, 4)} ${normalized.substring(4)}';
    }
    if (normalized.length == 11) {
      return '${normalized.substring(0, 4)} ${normalized.substring(4, 7)} ${normalized.substring(7)}';
    }
    return normalized;
  }
}

class _SellerCard extends StatelessWidget {
  final String sellerName;
  final VoidCallback onMessage;

  const _SellerCard({required this.sellerName, required this.onMessage});

  @override
  Widget build(BuildContext context) {
    final initial = sellerName.trim().isNotEmpty
        ? sellerName.trim()[0].toUpperCase()
        : 'S';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E0F1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8EEF9),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sold by',
                  style: TextStyle(
                    color: Color(0xFF7E8CAD),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  sellerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onMessage,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFE8EEF9),
              foregroundColor: const Color(0xFF4E5D7E),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Message',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF9AA7C5),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.1,
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);
}

class _DetailsTable extends StatelessWidget {
  final List<_DetailRow> rows;

  const _DetailsTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E0F1)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].label,
                      style: const TextStyle(
                        color: Color(0xFF7E8CAD),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              const Divider(height: 1, color: Color(0xFFDCE4F2)),
          ],
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFDDE5F3),
          disabledForegroundColor: const Color(0xFF8B98B5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onPressed;

  const _DeleteButton({required this.isDeleting, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 54,
      child: OutlinedButton(
        onPressed: isDeleting ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE53935),
          side: const BorderSide(color: Color(0xFFFFCDD2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isDeleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.delete_outline_rounded),
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;

  const _TopCircleButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
