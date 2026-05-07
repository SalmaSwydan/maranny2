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
    print(
      '[MarketplaceRepository] marketplace list response -> '
      'url=${_buildLogUrl(ApiConfig.products)} '
      'query=$query category=$category '
      'response=${jsonEncode(response.data)}',
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
    print(
      '[MarketplaceRepository] product details response -> '
      'productId=$productId response=${jsonEncode(response.data)}',
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
    final imageUrl = _resolveImageUrlForApi(request);
    final resolvedCategoryId = await _resolveCategoryId(request);

    if (request.hasImage) {
      try {
        return await _createProductWithMultipart(
          request: request,
          imageUrl: imageUrl,
          resolvedCategoryId: resolvedCategoryId,
        );
      } on DioException catch (error) {
        developer.log(
          'Multipart marketplace create failed, falling back to JSON create -> status=${error.response?.statusCode} data=${jsonEncode(error.response?.data)}',
          name: 'MarketplaceRepository',
          error: error,
          stackTrace: error.stackTrace,
        );
      }
    }

    return _createProductJson(
      request: request,
      imageUrl: imageUrl,
      resolvedCategoryId: resolvedCategoryId,
    );
  }

  Future<int> _createProductJson({
    required CreateProductRequest request,
    required String? imageUrl,
    required int? resolvedCategoryId,
  }) async {
    final requestUrl = _buildLogUrl(ApiConfig.products);
    final requestBody = request.toApiJson(
      imageUrl: imageUrl,
      sportIds: const <int>[],
      categoryIdOverride: resolvedCategoryId,
    );
    final imageMimeType = _inferMimeType(request.imageFile?.path);

    developer.log(
      'Create product request prepared -> '
      'url=$requestUrl method=POST '
      'resolvedCategoryId=$resolvedCategoryId '
      'swaggerExpectedContentTypes=application/json,text/json,application/*+json '
      'imageSelected=${request.hasImage} '
      'imagePath=${request.imageFile?.path ?? ''} '
      'imageMimeType=$imageMimeType '
      'imageName=${request.imageFile == null ? '' : request.imageFile!.path.split(RegExp(r"[\/]")).last} '
      'body=${jsonEncode(requestBody)}',
      name: 'MarketplaceRepository',
    );
    print(
      '[MarketplaceRepository] Create product request prepared -> '
      'url=$requestUrl method=POST '
      'resolvedCategoryId=$resolvedCategoryId '
      'swaggerExpectedContentTypes=application/json,text/json,application/*+json '
      'imageSelected=${request.hasImage} '
      'imagePath=${request.imageFile?.path ?? ''} '
      'imageMimeType=$imageMimeType '
      'imageName=${request.imageFile == null ? '' : request.imageFile!.path.split(RegExp(r"[\/]")).last} '
      'body=${jsonEncode(requestBody)}',
    );

    try {
      return await _createProductWithPayload(
        request: request,
        payload: requestBody,
      );
    } on DioException catch (error) {
      if (_isCategoryNotFoundError(error)) {
        for (final fallbackCategoryId in _fallbackCategoryIdsFor(
          request.category,
          excluding: requestBody['categoryID'] as int?,
        )) {
          final retryBody = request.toApiJson(
            imageUrl: imageUrl,
            sportIds: const <int>[],
            categoryIdOverride: fallbackCategoryId,
          );
          developer.log(
            'Retrying create product with fallback category -> '
            'originalCategory=${request.category} fallbackCategoryId=$fallbackCategoryId body=${jsonEncode(retryBody)}',
            name: 'MarketplaceRepository',
          );
          print(
            '[MarketplaceRepository] Retrying create product with fallback category -> '
            'originalCategory=${request.category} fallbackCategoryId=$fallbackCategoryId body=${jsonEncode(retryBody)}',
          );
          try {
            return await _createProductWithPayload(
              request: request,
              payload: retryBody,
            );
          } on DioException catch (retryError) {
            if (!_isCategoryNotFoundError(retryError)) {
              rethrow;
            }
          }
        }
      }
      rethrow;
    }
  }

  Future<int> _createProductWithMultipart({
    required CreateProductRequest request,
    required String? imageUrl,
    required int? resolvedCategoryId,
  }) async {
    final requestUrl = _buildLogUrl(ApiConfig.products);
    final imagePath = request.imageFile!.path;
    final imageName = imagePath.split(RegExp(r'[\/]')).last;
    final imageExists = request.imageFile?.existsSync() ?? false;
    final imageLength = imageExists ? await request.imageFile!.length() : 0;
    final payload = <String, dynamic>{
      'productName': request.title,
      'description': request.description,
      'price': request.price,
      'condition': request.condition,
      'categoryID': resolvedCategoryId ?? request.categoryId ?? 1,
      'sportIDs': <int>[],
      'imageUrl': imageUrl?.trim() ?? '',
      'categoryName': request.category,
      'category': request.category,
      'image': await MultipartFile.fromFile(imagePath, filename: imageName),
    };

    developer.log(
      'Create product multipart request prepared -> '
      'url=$requestUrl method=POST contentType=${Headers.multipartFormDataContentType} '
      'formDataFields=${jsonEncode(payload.keys.toList())} '
      'formDataFileFields=${jsonEncode(<String>['image'])} '
      'imageField=image imagePath=$imagePath imageName=$imageName imageExists=$imageExists imageLength=$imageLength bodyFields=${jsonEncode(payload.keys.where((key) => key != 'image').toList())}',
      name: 'MarketplaceRepository',
    );
    print(
      '[MarketplaceRepository] Create product multipart request prepared -> '
      'url=$requestUrl method=POST contentType=${Headers.multipartFormDataContentType} '
      'formDataFields=${jsonEncode(payload.keys.toList())} '
      'formDataFileFields=${jsonEncode(<String>['image'])} '
      'imageField=image imagePath=$imagePath imageName=$imageName imageExists=$imageExists imageLength=$imageLength bodyFields=${jsonEncode(payload.keys.where((key) => key != 'image').toList())}',
    );

    final response = await _dio.post(
      ApiConfig.products,
      data: FormData.fromMap(payload),
      options: Options(
        method: 'POST',
        headers: <String, dynamic>{'Accept': 'application/json'},
        contentType: Headers.multipartFormDataContentType,
      ),
    );

    developer.log(
      'Create product multipart response -> status=${response.statusCode} data=${jsonEncode(response.data)}',
      name: 'MarketplaceRepository',
    );
    print(
      '[MarketplaceRepository] Create product multipart response -> status=${response.statusCode} data=${jsonEncode(response.data)}',
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


  Future<int?> _resolveCategoryId(CreateProductRequest request) async {
    try {
      final response = await _dio.get('/products/categories');
      developer.log(
        'Marketplace categories lookup -> response=${jsonEncode(response.data)}',
        name: 'MarketplaceRepository',
      );
      final data = response.data;
      final list = data is Map<String, dynamic>
          ? data['categories']
          : data;
      if (list is List) {
        final normalizedRequested = request.category.trim().toLowerCase();
        for (final item in list) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            final name = (map['name'] ?? map['categoryName'] ?? '').toString().trim().toLowerCase();
            if (name == normalizedRequested) {
              return _asInt(map['id'] ?? map['categoryID']);
            }
          }
        }
      }
    } on DioException catch (error) {
      developer.log(
        'Marketplace categories lookup failed -> status=${error.response?.statusCode} data=${jsonEncode(error.response?.data)}',
        name: 'MarketplaceRepository',
        error: error,
        stackTrace: error.stackTrace,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Marketplace categories lookup unexpected failure',
        name: 'MarketplaceRepository',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return _defaultCategoryIdForName(request.category);
  }

  bool _isCategoryNotFoundError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = (data['message'] ?? data['error'] ?? data['title'] ?? '').toString().toLowerCase();
      return message.contains('category not found');
    }
    return false;
  }

  List<int> _fallbackCategoryIdsFor(String categoryName, {int? excluding}) {
    final preferred = <int>[];
    switch (categoryName.trim().toLowerCase()) {
      case 'equipment':
        preferred.addAll(const [1, 2, 3, 4]);
        break;
      case 'accessories':
        preferred.addAll(const [2, 3, 4, 1]);
        break;
      case 'clothing':
        preferred.addAll(const [3, 2, 4, 1]);
        break;
      default:
        preferred.addAll(const [1, 2, 3, 4]);
        break;
    }
    return preferred.where((id) => id != excluding).toList(growable: false);
  }

  int _defaultCategoryIdForName(String categoryName) {
    switch (categoryName.trim().toLowerCase()) {
      case 'equipment':
        return 1;
      case 'accessories':
        return 2;
      case 'clothing':
        return 3;
      default:
        return 1;
    }
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
