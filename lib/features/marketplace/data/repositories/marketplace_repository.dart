import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../models/marketplace_models.dart';

class MarketplaceRepository {
  final Dio _dio = ApiClient.dio;

  Future<PaginatedProducts> browseProducts({
    int? categoryId, int? sportId, double? maxPrice,
    String? condition, String? search,
    int page = 1, int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConfig.products,
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (sportId != null)    'sportId':    sportId,
        if (maxPrice != null)   'maxPrice':   maxPrice,
        if (condition != null)  'condition':  condition,
        if (search != null)     'search':     search,
        'page': page, 'pageSize': pageSize,
      },
    );
    return PaginatedProducts.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<ProductModel> getProductDetails(int productId) async {
    final response =
    await _dio.get('${ApiConfig.products}/$productId');
    return ProductModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<int> createProduct(CreateProductRequest request) async {
    final response = await _dio.post(
        ApiConfig.products, data: request.toJson());
    return response.data['productId'] as int;
  }

  Future<String> updateProduct(
      int productId, Map<String, dynamic> updates) async {
    final response = await _dio.put(
        '${ApiConfig.products}/$productId', data: updates);
    return response.data['message'] as String;
  }

  Future<String> deleteProduct(int productId) async {
    final response =
    await _dio.delete('${ApiConfig.products}/$productId');
    return response.data['message'] as String;
  }
}