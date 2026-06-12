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
  static final RegExp _egyptMarketplacePhoneRegex = RegExp(
    r'^(?:\+20|0)1[0125][0-9]{8}$',
  );

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
    if (!_isValidMarketplacePhone(sellerPhone)) {
      _showMessage('Please enter a valid Egyptian mobile number.');
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
    if (_imagePath == null || _imagePath!.isEmpty) {
      _showMessage('Please attach a product photo');
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
      showPhoneNumber: true,
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
              pickupLocation: request.location,
              whatsapp: request.sellerPhone,
              showPhoneNumber: request.showPhoneNumber,
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

  bool _isValidMarketplacePhone(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    return _egyptMarketplacePhoneRegex.hasMatch(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 22),
              const Text(
                'SELL YOUR GEAR',
                style: TextStyle(
                  color: Color(0xFF91A0C0),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.4,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'List your item.',
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add the key details buyers need, then publish it to the marketplace.',
                style: TextStyle(
                  color: Color(0xFF657392),
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 22),
              _buildPhotoPicker(),
              const SizedBox(height: 18),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.deepBlue,
                size: 18,
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDE7FA)),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: AppColors.deepBlue,
            size: 19,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFDDE7FA)),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBlue.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7FF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDDE7FA)),
              ),
              child: _imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Image.file(
                        File(_imagePath!),
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.add_a_photo_rounded,
                      color: AppColors.deepBlue,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product photo',
                    style: TextStyle(
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Required. Tap to choose a clear image.',
                    style: TextStyle(
                      color: Color(0xFF7A86A5),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB7C2DA)),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDDE7FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('Product title'),
          const SizedBox(height: 8),
          _buildTextField(controller: _titleController, hint: 'Product title'),
          const SizedBox(height: 16),
          _buildLabel('Price'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _priceController,
            hint: '0 LE',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildLabel('Category'),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            value: _category,
            items: _categories,
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          _buildLabel('Condition'),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            value: _condition,
            items: const ['New', 'Used'],
            onChanged: (value) => setState(() => _condition = value),
          ),
          const SizedBox(height: 16),
          _buildLabel('Description'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _descriptionController,
            hint: "How's your product?",
            maxLines: 5,
          ),
          const SizedBox(height: 20),
          _buildSectionPill('Seller / contact info'),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _sellerNameController,
            hint: 'Store or seller name',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _sellerPhoneController,
            hint: 'Phone number (e.g. +20 100 123 4567)',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildLocationDropdown(),
          const SizedBox(height: 18),
          _buildNotice(),
          const SizedBox(height: 22),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w900,
      color: AppColors.deepBlue,
      letterSpacing: 0.2,
      fontFamily: 'Inter',
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    enabled: !_isSubmitting,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: const TextStyle(
      color: AppColors.deepBlue,
      fontWeight: FontWeight.w700,
      fontFamily: 'Inter',
    ),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDDE7FA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDDE7FA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.lightBlue, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7FA)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(18),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    item.toString(),
                    style: const TextStyle(
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: _isSubmitting
              ? null
              : (selected) {
                  if (selected == null) return;
                  onChanged(selected);
                },
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    final areas = EgyptLocations.allAreas;
    final value = areas.contains(_sellerLocationController.text.trim())
        ? _sellerLocationController.text.trim()
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7FA)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text('Your location (e.g. Nasr City)'),
          isExpanded: true,
          borderRadius: BorderRadius.circular(18),
          items: areas
              .map(
                (area) => DropdownMenuItem<String>(
                  value: area,
                  child: Text(
                    area,
                    style: const TextStyle(
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
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

  Widget _buildSectionPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.deepBlue,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBlue.withValues(alpha: 0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.deepBlue, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You are responsible for all communications, transactions, and arrangements with buyers.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.deepBlue,
                height: 1.35,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.24),
              blurRadius: 16,
              offset: const Offset(0, 8),
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
              borderRadius: BorderRadius.circular(18),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
                  ),
                ),
        ),
      ),
    );
  }
}
