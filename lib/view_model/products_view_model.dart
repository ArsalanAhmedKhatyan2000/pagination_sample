import 'package:flutter/material.dart';
import 'package:pagination_sample/data/response/api_response.dart';
import 'package:pagination_sample/model/product_model.dart';

import '../repository/products_repository.dart';

class ProductsViewModel with ChangeNotifier {
  final ProductRepository productsRepo = ProductRepository();

  // Fetch Products Work Started
  ApiResponse<List<ProductModel>> _listOfProducts = ApiResponse.loading();
  ApiResponse<List<ProductModel>> get getListOfProducts => _listOfProducts;
  set setListOfProducts(ApiResponse<List<ProductModel>> listOfProducts) {
    _listOfProducts = listOfProducts;
    notifyListeners();
  }

  Future<void> fetchProducts({required String limit}) async {
    try {
      setListOfProducts = ApiResponse.loading();
      List<ProductModel> list = [];
      final response = await productsRepo.fetchProducts(limit: limit);
      for (var i = 0; i < response.length; i++) {
        list.add(ProductModel.fromJson(response[i]));
      }
      setListOfProducts = ApiResponse.completed(list);
    } catch (e) {
      setListOfProducts = ApiResponse.error(e.toString());
      rethrow;
    }
    notifyListeners();
  }

  // Fetch More Products Work Started
  bool _isMoreProductsLoading = false;
  bool get getIsMoreProductsLoading => _isMoreProductsLoading;
  set setIsMoreProductsLoading(bool isLoading) {
    _isMoreProductsLoading = isLoading;
    notifyListeners();
  }

  Future<void> fetchMoreProducts({required String limit}) async {
    try {
      setIsMoreProductsLoading = true;
      final response = await productsRepo.fetchProducts(limit: limit);
      for (var i = 0; i < response.length; i++) {
        _listOfProducts.data?.add(ProductModel.fromJson(response[i]));
      }
      setIsMoreProductsLoading = false;
    } catch (e) {
      setIsMoreProductsLoading = false;
      rethrow;
    }
    notifyListeners();
  }
}
