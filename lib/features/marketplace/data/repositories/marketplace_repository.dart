import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/marketplace_models.dart';

class MarketplaceRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<ProductModel>> getProducts({
    String? query,
    String? category,
  }) async {
    final response = await _dio.get(
      ApiConfig.products,
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
      },
    );
    developer.log(
      'Marketplace fetch -> url=${_buildLogUrl(ApiConfig.products)} query=$query category=$category response=${jsonEncode(response.data)}',
      name: 'MarketplaceRepository',
    );
    final parsed = _parseProductsResponse(response.data);
    developer.log(
      'Marketplace parsed products count=${parsed.length}',
      name: 'MarketplaceRepository',
    );
    return _filterProducts(parsed, query: query, category: category);
  }

  Future<ProductModel> getProductDetails(int productId) async {
    final response = await _dio.get('${ApiConfig.products}/$productId');
    developer.log(
      'Marketplace product details -> productId=$productId response=${jsonEncode(response.data)}',
      name: 'MarketplaceRepository',
    );
    final data = response.data as Map<String, dynamic>;
    final productJson = _extractProductJson(data) ?? data;
    return ProductModel.fromJson(productJson);
  }

  Future<List<ProductModel>> searchProducts({
    required String query,
    String? category,
  }) async {
    return getProducts(query: query, category: category);
  }

  Future<int> createProduct(CreateProductRequest request) async {
    final requestUrl = _buildLogUrl(ApiConfig.products);
    final requestBody = request.toApiJson(
      imageUrl: _resolveImageUrlForApi(request),
    );
    final imageMimeType = _inferMimeType(request.imageFile?.path);

    developer.log(
      'Create product request prepared -> '
      'url=$requestUrl method=POST '
      'swaggerExpectedContentTypes=application/json,text/json,application/*+json '
      'imageSelected=${request.hasImage} '
      'imagePath=${request.imageFile?.path ?? ''} '
      'imageMimeType=$imageMimeType '
      'imageName=${request.imageFile == null ? '' : request.imageFile!.path.split(RegExp(r"[\\/]")).last} '
      'body=${jsonEncode(requestBody)}',
      name: 'MarketplaceRepository',
    );
    print(
      '[MarketplaceRepository] Create product request prepared -> '
      'url=$requestUrl method=POST '
      'swaggerExpectedContentTypes=application/json,text/json,application/*+json '
      'imageSelected=${request.hasImage} '
      'imagePath=${request.imageFile?.path ?? ''} '
      'imageMimeType=$imageMimeType '
      'imageName=${request.imageFile == null ? '' : request.imageFile!.path.split(RegExp(r"[\\/]")).last} '
      'body=${jsonEncode(requestBody)}',
    );
    return _createProductWithPayload(
      request: request,
      payload: requestBody,
    );
  }

  Future<int> _createProductWithPayload({
    required CreateProductRequest request,
    required Map<String, dynamic> payload,
  }) async {
    final requestUrl = _buildLogUrl(ApiConfig.products);
    final options = Options(
      method: 'POST',
      headers: <String, dynamic>{
        'Accept': 'application/json',
        'Content-Type': Headers.jsonContentType,
      },
      contentType: Headers.jsonContentType,
    );

    _logCreateRequest(
      request: request,
      requestUrl: requestUrl,
      options: options,
      payload: payload,
    );

    try {
      final response = await _dio.post(
        ApiConfig.products,
        data: payload,
        options: options,
      );
      developer.log(
        'Create product response -> '
        'status=${response.statusCode} '
        'data=${jsonEncode(response.data)}',
        name: 'MarketplaceRepository',
      );
      print(
        '[MarketplaceRepository] Create product response -> '
        'status=${response.statusCode} '
        'data=${jsonEncode(response.data)}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _asInt(
          data['productId'] ??
              data['productID'] ??
              data['id'] ??
              data['data']?['productId'] ??
              data['data']?['id'],
        );
      }
      return 0;
    } on DioException catch (error) {
      _logCreateError(
        requestUrl: requestUrl,
        payload: payload,
        error: error,
      );
      rethrow;
    }
  }

  List<ProductModel> _filterProducts(
    List<ProductModel> products, {
    String? query,
    String? category,
  }) {
    final trimmedQuery = query?.trim().toLowerCase() ?? '';
    final selectedCategory = category?.trim() ?? 'All';

    final filtered = products.where((product) {
      final matchesCategory = selectedCategory == 'All'
          ? true
          : selectedCategory == 'Used'
              ? product.condition.toLowerCase() == 'used'
              : product.categoryName.toLowerCase() ==
                  selectedCategory.toLowerCase();

      final haystack = [
        product.title,
        product.categoryName,
        product.description,
        product.sellerName,
        product.location,
      ].join(' ').toLowerCase();
      final matchesQuery =
          trimmedQuery.isEmpty ? true : haystack.contains(trimmedQuery);

      return matchesCategory && matchesQuery;
    }).toList(growable: false);

    developer.log(
      'Marketplace filters -> selectedCategory=$selectedCategory searchQuery=$trimmedQuery filteredResults=${filtered.length}',
      name: 'MarketplaceRepository',
    );

    return filtered;
  }

  String _buildLogUrl(String path) {
    final baseUrl = _dio.options.baseUrl;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (baseUrl.endsWith('/') && path.startsWith('/')) {
      return '${baseUrl.substring(0, baseUrl.length - 1)}$path';
    }
    if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      return '$baseUrl/$path';
    }
    return '$baseUrl$path';
  }

  void _logCreateRequest({
    required CreateProductRequest request,
    required String requestUrl,
    required Options options,
    required Map<String, dynamic> payload,
  }) {
    final headers = _sanitizeHeaders(<String, dynamic>{
      ..._dio.options.headers,
      ...?options.headers,
    });
    final finalContentType =
        options.contentType ?? _dio.options.contentType ?? 'application/json';
    final payloadDescription = jsonEncode(payload);
    final formFieldNames = payload.keys.toList(growable: false);
    final imageExtension = request.imageFile == null
        ? ''
        : _fileExtension(request.imageFile!.path);
    final imageMimeType = _inferMimeType(request.imageFile?.path);

    final message =
        'Create product request -> '
        'url=$requestUrl '
        'method=${options.method ?? 'POST'} '
        'contentType=$finalContentType '
        'headers=${jsonEncode(headers)} '
        'fieldNames=${jsonEncode(formFieldNames)} '
        'body=$payloadDescription '
        'imageSelected=${request.hasImage} '
        'imageField=imageUrl '
        'imagePath=${request.imageFile?.path ?? ''} '
        'imageName=${request.imageFile == null ? '' : request.imageFile!.path.split(RegExp(r"[\\/]")).last} '
        'imageExtension=$imageExtension '
        'imageMimeType=$imageMimeType';

    developer.log(message, name: 'MarketplaceRepository');
    print('[MarketplaceRepository] $message');
  }

  void _logCreateError({
    required String requestUrl,
    required Map<String, dynamic> payload,
    required DioException error,
  }) {
    final responseData = error.response?.data;
    final responseStatus = error.response?.statusCode;
    final finalContentType = Headers.jsonContentType;
    final payloadDescription = jsonEncode(payload);
    final formFieldNames = payload.keys.toList(growable: false);
    final validationErrors = _extractValidationErrors(responseData);

    final message =
        'Create product error -> '
        'url=$requestUrl '
        'method=POST '
        'contentType=$finalContentType '
        'fieldNames=${jsonEncode(formFieldNames)} '
        'imageField=imageUrl '
        'status=$responseStatus '
        'response=${jsonEncode(responseData)} '
        'validationErrors=${jsonEncode(validationErrors)} '
        'dioMessage=${error.message} '
        'requestData=$payloadDescription';

    developer.log(
      message,
      name: 'MarketplaceRepository',
      error: error,
      stackTrace: error.stackTrace,
    );
    print('[MarketplaceRepository] $message');
    print('[MarketplaceRepository] Create product raw response.data -> $responseData');
    print(
      '[MarketplaceRepository] Create product validation errors -> '
      '${jsonEncode(validationErrors)}',
    );
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization') {
        sanitized[entry.key] = '[REDACTED]';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  String _fileExtension(String path) {
    final fileName = path.split(RegExp(r'[\\/]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _inferMimeType(String? path) {
    final extension = _fileExtension(path ?? '');
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return extension.isEmpty ? '' : 'application/octet-stream';
    }
  }

  String? _resolveImageUrlForApi(CreateProductRequest request) {
    final path = request.imageFile?.path ?? '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return null;
  }

  Map<String, dynamic>? _extractValidationErrors(dynamic responseData) {
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
}

Map<String, dynamic>? _extractProductJson(Map<String, dynamic> data) {
  final product = data['product'];
  if (product is Map<String, dynamic>) {
    return product;
  }
  if (product is Map) {
    return Map<String, dynamic>.from(product);
  }
  return null;
}

List<ProductModel> _parseProductsResponse(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }
  if (data is Map<String, dynamic>) {
    return PaginatedProducts.fromJson(data).products;
  }
  return const <ProductModel>[];
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
