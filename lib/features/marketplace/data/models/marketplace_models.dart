import 'dart:io';

import '../../../../core/network/api_config.dart';

/// MARKETPLACE MODELS

class ProductModel {
  final int productId;
  final String title;
  final String description;
  final double price;
  final String condition;
  final String imageUrl;
  final String categoryName;
  final String sellerName;
  final String sellerPhone;
  final String location;
  final double rating;
  final int reviewsCount;
  final String createdAt;
  final int? ownerId;
  final int? sellerId;

  const ProductModel({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.condition,
    required this.imageUrl,
    required this.categoryName,
    required this.sellerName,
    required this.sellerPhone,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.createdAt,
    this.ownerId,
    this.sellerId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = _asMap(json['category']);
    final seller = _asMap(json['seller']) ?? _asMap(json['owner']);

    return ProductModel(
      productId: _asInt(json['productId'] ?? json['productID'] ?? json['id']),
      title: _firstNonEmptyString([
            _asNullableString(json['title']),
            _asNullableString(json['name']),
            _asNullableString(json['productName']),
          ]) ??
          'Product',
      description: _asString(json['description']),
      price: _asDouble(json['price']),
      condition: _firstNonEmptyString([
            _asNullableString(json['condition']),
            _asNullableString(json['status']),
          ]) ??
          'New',
      imageUrl: ApiConfig.resolveMediaUrl(
        _firstNonEmptyString([
          _asNullableString(json['imageUrl']),
          _asNullableString(json['imageURL']),
          _asNullableString(json['image']),
          _asNullableString(json['productImage']),
          _asNullableString(json['productImageUrl']),
          _asNullableString(json['photoUrl']),
          _asNullableString(json['imagePath']),
          _asNullableString(json['pictureUrl']),
          _asNullableString(json['photo']),
          _asNullableString(json['thumbnail']),
        ]),
      ),
      categoryName: _extractCategoryName(
            json['categoryName'],
            category,
            json['category'],
          ) ??
          'Equipment',
      sellerName: _firstNonEmptyString([
            _asNullableString(json['sellerName']),
            _asNullableString(json['storeName']),
            _asNullableString(seller?['name']),
            _asNullableString(seller?['fullName']),
          ]) ??
          'Seller',
      sellerPhone: _firstNonEmptyString([
            _asNullableString(json['sellerPhone']),
            _asNullableString(json['phoneNumber']),
            _asNullableString(json['contactPhone']),
            _asNullableString(json['whatsApp']),
            _asNullableString(json['whatsapp']),
            _asNullableString(seller?['phone']),
            _asNullableString(seller?['phoneNumber']),
            _asNullableString(seller?['contactPhone']),
            _asNullableString(seller?['whatsApp']),
            _asNullableString(seller?['whatsapp']),
          ]) ??
          '',
      location: _firstNonEmptyString([
            _asNullableString(json['sellerLocation']),
            _asNullableString(json['location']),
            _asNullableString(json['city']),
            _asNullableString(json['address']),
            _asNullableString(seller?['location']),
            _asNullableString(seller?['city']),
            _asNullableString(seller?['address']),
          ]) ??
          'Unknown',
      rating: _asDouble(
        json['rating'] ?? json['sellerRating'] ?? json['avgRating'],
      ),
      reviewsCount: _asInt(
        json['reviewsCount'] ?? json['reviewCount'] ?? json['totalReviews'],
      ),
      createdAt: _asString(
        json['createdAt'] ?? json['date'] ?? json['postedAt'],
      ),
      ownerId: _asNullableInt(json['ownerId']),
      sellerId: _asNullableInt(
        json['sellerId'] ?? seller?['id'] ?? seller?['clientID'],
      ),
    );
  }

  bool get hasPhone => sellerPhone.trim().isNotEmpty;
}

class PaginatedProducts {
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final List<ProductModel> products;

  const PaginatedProducts({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.products,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    final list =
        json['products'] ??
        json['items'] ??
        json['data'] ??
        json['results'] ??
        const <dynamic>[];

    final products = list is List
        ? list
            .whereType<Map>()
            .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false)
        : const <ProductModel>[];

    return PaginatedProducts(
      totalCount: _asInt(
        json['totalCount'] ?? json['count'] ?? json['total'] ?? products.length,
      ),
      page: _asInt(json['page'], fallback: 1),
      pageSize: _asInt(json['pageSize'], fallback: products.length),
      totalPages: _asInt(json['totalPages'], fallback: 1),
      products: products,
    );
  }
}

class CreateProductRequest {
  final String title;
  final double price;
  final String category;
  final String condition;
  final String description;
  final String sellerName;
  final String sellerPhone;
  final String location;
  final File? imageFile;

  const CreateProductRequest({
    required this.title,
    required this.price,
    required this.category,
    required this.condition,
    required this.description,
    required this.sellerName,
    required this.sellerPhone,
    required this.location,
    this.imageFile,
  });

  int? get categoryId => _categoryIdFromName(category);

  bool get hasImage => imageFile != null;

  Map<String, dynamic> toApiJson({
    String? imageUrl,
    List<int>? sportIds,
    int? categoryIdOverride,
  }) => {
    'productName': title,
    'description': description,
    'price': price,
    'condition': condition,
    'categoryID': categoryIdOverride ?? categoryId ?? 1,
    'sportIDs': List<int>.from(sportIds ?? const <int>[]),
    'imageUrl': imageUrl?.trim() ?? '',
    'categoryName': category,
    'category': category,
  };
}

int? _categoryIdFromName(String rawCategory) {
  switch (rawCategory.trim().toLowerCase()) {
    case 'equipment':
      return 1;
    case 'accessories':
      return 2;
    case 'clothing':
      return 3;
    default:
      return null;
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

int? _asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  final stringValue = value.toString();
  return stringValue.isEmpty ? fallback : stringValue;
}

String? _asNullableString(dynamic value) {
  if (value == null || value is Map || value is List) {
    return null;
  }
  final stringValue = value.toString().trim();
  return stringValue.isEmpty ? null : stringValue;
}

String? _firstNonEmptyString(List<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? _extractCategoryName(
  dynamic rootCategoryName,
  Map<String, dynamic>? category,
  dynamic rawCategory,
) {
  final direct = _firstNonEmptyString([
    _asNullableString(rootCategoryName),
    _asNullableString(category?['categoryName']),
    _asNullableString(category?['name']),
    _asNullableString(category?['title']),
  ]);
  if (direct != null) {
    return direct;
  }

  final raw = _asNullableString(rawCategory);
  if (raw == null) {
    return null;
  }

  final categoryNameMatch = RegExp(r'categoryName\s*:\s*([^,}]+)', caseSensitive: false).firstMatch(raw);
  if (categoryNameMatch != null) {
    return categoryNameMatch.group(1)?.trim();
  }

  if (!raw.contains('{') && !raw.contains('}')) {
    return raw.trim();
  }

  return null;
}
