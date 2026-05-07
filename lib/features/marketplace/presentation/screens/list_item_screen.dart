import 'dart:io';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/egypt_locations.dart';
import '../../../../core/utils/profile_validators.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../utils/marketplace_product.dart';

class ListItemScreen extends StatefulWidget {
  final void Function(MarketplaceProduct product) onListed;

  const ListItemScreen({super.key, required this.onListed});

  @override
  State<ListItemScreen> createState() => _ListItemScreenState();
}

class _ListItemScreenState extends State<ListItemScreen> {
  final MarketplaceRepository _repository = MarketplaceRepository();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _sellerLocationController = TextEditingController();

  String? _imagePath;
  String _category = 'Equipment';
  String _condition = 'New';
  bool _isSubmitting = false;

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

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim();
    final description = _descriptionController.text.trim();
    final sellerName = _sellerNameController.text.trim();
    final sellerPhone = _sellerPhoneController.text.trim();
    final sellerLocation = _sellerLocationController.text.trim();

    if (title.isEmpty) {
      _showMessage('Please enter a product title');
      return;
    }
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      _showMessage('Please enter a valid price');
      return;
    }
    if (description.isEmpty) {
      _showMessage('Please describe your product');
      return;
    }
    if (description.length < 10) {
      _showMessage('Please write a more detailed description');
      return;
    }
    if (sellerName.isEmpty) {
      _showMessage('Please enter the seller or store name');
      return;
    }
    if (sellerPhone.isEmpty) {
      _showMessage('Please enter your contact number');
      return;
    }
    if (!ProfileValidators.isValidEgyptPhone(sellerPhone)) {
      _showMessage('Please enter a valid Egyptian phone number');
      return;
    }
    if (sellerLocation.isEmpty) {
      _showMessage('Please enter your location');
      return;
    }
    if (!ProfileValidators.isValidLocation(sellerLocation)) {
      _showMessage('Please choose a valid Cairo/Giza area');
      return;
    }

    final request = CreateProductRequest(
      title: title,
      price: price,
      category: _category,
      condition: _condition,
      description: description,
      sellerName: sellerName,
      sellerPhone: ProfileValidators.normalizeEgyptPhone(sellerPhone),
      location: sellerLocation,
      imageFile: _imagePath != null && _imagePath!.isNotEmpty
          ? File(_imagePath!)
          : null,
    );

    final selectedImagePath = request.imageFile?.path ?? '';
    final selectedImageExists = request.imageFile?.existsSync() ?? false;
    developer.log(
      'List item image submit debug -> '
      'endpoint=createProduct '
      'category=$_category '
      'condition=$_condition '
      'selectedImagePath=$selectedImagePath '
      'selectedImageExists=$selectedImageExists',
      name: 'ListItemScreen',
    );
    print(
      '[ListItemScreen] image submit debug -> '
      'endpoint=createProduct '
      'category=$_category '
      'condition=$_condition '
      'selectedImagePath=$selectedImagePath '
      'selectedImageExists=$selectedImageExists',
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final productId = await _repository.createProduct(request);
      ProductModel? createdProduct;
      if (productId > 0) {
        try {
          createdProduct = await _repository.getProductDetails(productId);
        } catch (_) {}
      }

      final mappedProduct = createdProduct != null
          ? MarketplaceProduct.fromApi(createdProduct)
          : MarketplaceProduct(
              id: productId.toString(),
              title: request.title,
              category: request.category,
              condition: request.condition,
              price: request.price,
              imageAsset: _imagePath ?? '',
              sellerName: request.sellerName,
              sellerRating: 0,
              reviewers: 0,
              location: request.location,
              whatsapp: request.sellerPhone,
              description: request.description,
            );

      widget.onListed(mappedProduct);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item listed successfully!')),
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final validationErrors = _extractValidationErrorsMap(responseData);
      developer.log(
        'List item submit failed -> '
        'status=${error.response?.statusCode} '
        'data=$responseData '
        'validationErrors=$validationErrors '
        'message=${error.message}',
        name: 'ListItemScreen',
        error: error,
        stackTrace: error.stackTrace,
      );
      print(
        '[ListItemScreen] List item submit failed -> '
        'status=${error.response?.statusCode} '
        'data=$responseData '
        'validationErrors=$validationErrors '
        'message=${error.message}',
      );
      if (!mounted) {
        return;
      }
      _showMessage(_friendlyCreateError(error));
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not list your item right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _friendlyCreateError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final validationMessage = _extractValidationMessage(data);
      if (validationMessage != null) {
        return validationMessage;
      }
    }

    if (statusCode == 400) {
      return 'Please check your product details and try again.';
    }
    if (statusCode == 401) {
      return 'Your session expired. Please sign in again and retry.';
    }
    if (statusCode == 403) {
      return 'Your account is not allowed to list items right now.';
    }
    if (statusCode == 404) {
      return 'Marketplace create route is not available on the current backend.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error while listing your item. Please try again.';
    }
    return 'Could not list your item right now. Please try again.';
  }

  String? _extractValidationMessage(Map<String, dynamic> data) {
    final direct = data['message'] ?? data['error'] ?? data['title'];
    if (direct is String && direct.trim().isNotEmpty) {
      return direct.trim();
    }

    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is String && first.trim().isNotEmpty) {
        return first.trim();
      }
    }

    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          if (first is String && first.trim().isNotEmpty) {
            return first.trim();
          }
        }
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractValidationErrorsMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final errors = responseData['errors'];
      if (errors is Map<String, dynamic>) {
        return errors;
      }
      if (errors is Map) {
        return Map<String, dynamic>.from(errors);
      }
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    GestureDetector(
                      onTap: _isSubmitting ? null : _pickImage,
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                            border: Border.all(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
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
                              : Icon(
                                  Icons.camera_alt,
                                  size: 48,
                                  color: Colors.grey.shade600,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('What is the product title ?'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Product title',
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('What is the product price ?'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _priceController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('What is the product category ?'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.6),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _category,
                          isExpanded: true,
                          items: _categories
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(c),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _isSubmitting
                              ? null
                              : (v) =>
                                    setState(() => _category = v ?? _category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Condition'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.6),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _condition,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'New',
                              child: Text('New'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Used',
                              child: Text('Used'),
                            ),
                          ],
                          onChanged: _isSubmitting
                              ? null
                              : (v) => setState(
                                  () => _condition = v ?? _condition,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Describe your product'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.6),
                        ),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        enabled: !_isSubmitting,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "How's your product",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    _buildLocationDropdown(),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.lightBlue.withValues(alpha: 0.5),
                        ),
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
                    SizedBox(
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
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'List item',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) => TextField(
    controller: controller,
    enabled: !_isSubmitting,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryBlue.withValues(alpha: 0.6),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryBlue.withValues(alpha: 0.6),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  Widget _buildLocationDropdown() {
    final areas = EgyptLocations.allAreas;
    final value = areas.contains(_sellerLocationController.text.trim())
        ? _sellerLocationController.text.trim()
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text('Your location (e.g. Nasr City)'),
          isExpanded: true,
          items: areas
              .map(
                (area) =>
                    DropdownMenuItem<String>(value: area, child: Text(area)),
              )
              .toList(growable: false),
          onChanged: _isSubmitting
              ? null
              : (v) {
                  if (v == null) return;
                  setState(() => _sellerLocationController.text = v);
                },
        ),
      ),
    );
  }
}
