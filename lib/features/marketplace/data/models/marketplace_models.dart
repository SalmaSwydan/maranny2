/// ─────────────────────────────────────────────────────────────
/// MARKETPLACE MODELS
/// ─────────────────────────────────────────────────────────────

class ProductModel {
  final int    productID;
  final String productName;
  final String description;
  final double price;
  final String condition;
  final String? imageUrl;
  final ProductCategory    category;
  final ProductSeller      seller;
  final List<SportRef>     sports;

  const ProductModel({
    required this.productID, required this.productName,
    required this.description, required this.price,
    required this.condition, required this.category,
    required this.seller, required this.sports, this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      ProductModel(
        productID:   json['productID']   as int,
        productName: json['productName'] as String,
        description: json['description'] as String,
        price:       (json['price']      as num).toDouble(),
        condition:   json['condition']   as String,
        imageUrl:    json['imageUrl']    as String?,
        category: ProductCategory.fromJson(
            json['category'] as Map<String, dynamic>),
        seller: ProductSeller.fromJson(
            json['seller'] as Map<String, dynamic>),
        sports: (json['sports'] as List<dynamic>? ?? [])
            .map((e) =>
            SportRef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ProductCategory {
  final int    categoryID;
  final String categoryName;

  const ProductCategory(
      {required this.categoryID, required this.categoryName});

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        categoryID:   json['categoryID']   as int,
        categoryName: json['categoryName'] as String,
      );
}

class ProductSeller {
  final int    clientID;
  final String name;
  final String? email;
  final String? phone;

  const ProductSeller({
    required this.clientID, required this.name,
    this.email, this.phone,
  });

  factory ProductSeller.fromJson(Map<String, dynamic> json) =>
      ProductSeller(
        clientID: json['clientID'] as int,
        name:     json['name']     as String,
        email:    json['email']    as String?,
        phone:    json['phone']    as String?,
      );
}

class SportRef {
  final int    id;
  final String name;

  const SportRef({required this.id, required this.name});

  factory SportRef.fromJson(Map<String, dynamic> json) =>
      SportRef(id: json['id'] as int, name: json['name'] as String);
}

class PaginatedProducts {
  final int                totalCount;
  final int                page;
  final int                pageSize;
  final int                totalPages;
  final List<ProductModel> products;

  const PaginatedProducts({
    required this.totalCount, required this.page,
    required this.pageSize, required this.totalPages,
    required this.products,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) =>
      PaginatedProducts(
        totalCount: json['totalCount'] as int,
        page:       json['page']       as int,
        pageSize:   json['pageSize']   as int,
        totalPages: json['totalPages'] as int,
        products: (json['products'] as List<dynamic>)
            .map((e) =>
            ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CreateProductRequest {
  final String    productName;
  final String    description;
  final double    price;
  final String    condition;
  final int       categoryID;
  final List<int> sportIDs;
  final String?   imageUrl;

  const CreateProductRequest({
    required this.productName, required this.description,
    required this.price, required this.condition,
    required this.categoryID, required this.sportIDs,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'description': description,
    'price':       price,
    'condition':   condition,
    'categoryID':  categoryID,
    'sportIDs':    sportIDs,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };
}