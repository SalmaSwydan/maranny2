import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../utils/marketplace_product.dart';

class ListItemScreen extends StatefulWidget {
  final void Function(MarketplaceProduct product) onListed;

  const ListItemScreen({super.key, required this.onListed});

  @override
  State<ListItemScreen> createState() => _ListItemScreenState();
}

class _ListItemScreenState extends State<ListItemScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _sellerLocationController = TextEditingController();

  String? _imagePath;
  String _category = 'Equipment';
  String _condition = 'New';

  static const _categories = ['Equipment', 'Clothing', 'Accessories'];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _sellerNameController.dispose();
    _sellerPhoneController.dispose();
    _sellerLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() => _imagePath = xFile.path);
    }
  }

  Future<String?> _saveImageToAppStorage() async {
    if (_imagePath == null || _imagePath!.isEmpty) return null;
    final file = File(_imagePath!);
    if (!file.existsSync()) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final marketplaceDir = Directory('${dir.path}/marketplace_images');
      if (!await marketplaceDir.exists()) await marketplaceDir.create(recursive: true);
      final savedPath = '${marketplaceDir.path}/product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await file.copy(savedPath);
      return savedPath;
    } catch (_) {
      return _imagePath;
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product title')),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your product')),
      );
      return;
    }

    final sellerName = _sellerNameController.text.trim();
    final sellerPhone = _sellerPhoneController.text.trim();
    final sellerLocation = _sellerLocationController.text.trim();

    if (sellerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your contact number')),
      );
      return;
    }
    if (sellerLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your location')),
      );
      return;
    }

    final savedImagePath = await _saveImageToAppStorage();

    final product = MarketplaceProduct(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: _category,
      condition: _condition,
      price: price,
      imageAsset: savedImagePath ?? _imagePath ?? '',
      sellerName: sellerName.isNotEmpty ? sellerName : 'My Store',
      sellerRating: 4.5,
      reviewers: 0,
      location: sellerLocation,
      whatsapp: sellerPhone,
      description: description,
    );

    widget.onListed(product);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item listed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Gradient app bar
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
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                  ),
                  const Expanded(
                    child: Text(
                      'List your item',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    // Image upload - circular with camera icon
                    GestureDetector(
                      onTap: _pickImage,
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                            border: Border.all(color: AppColors.primaryBlue, width: 2),
                          ),
                          child: _imagePath != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_imagePath!),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.camera_alt, size: 48, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Product title
                    _buildLabel('What is the product title ?'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Product title',
                    ),
                    const SizedBox(height: 16),
                    // Price
                    _buildLabel('What is the product price ?'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _priceController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // Category
                    _buildLabel('What is the product category ?'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.6)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _category,
                          isExpanded: true,
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _category = v ?? _category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Condition (New / Used)
                    _buildLabel('Condition'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.6)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _condition,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'New', child: Text('New')),
                            DropdownMenuItem(value: 'Used', child: Text('Used')),
                          ],
                          onChanged: (v) => setState(() => _condition = v ?? _condition),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    _buildLabel('Describe your product'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.6)),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "How 's your product",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Contact info for buyers
                    _buildLabel('Seller / Contact info (shown to buyers)'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _sellerNameController,
                      hint: 'Store or seller name',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _sellerPhoneController,
                      hint: 'Your phone number (e.g. +20 100 123 4567)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _sellerLocationController,
                      hint: 'Your location (e.g. Cairo, Egypt)',
                    ),
                    const SizedBox(height: 20),
                    // Note box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightBlue.withOpacity(0.5)),
                      ),
                      child: const Text(
                        'Note: This is a display-only marketplace. You are responsible for all communications, transactions, and arrangements with buyers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // List item button
                    SizedBox(
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('List item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.6)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
