import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';

class ProductRepository {
  final BaseApiServices networkServices = NetworkApiServices();

  Future<dynamic> fetchProducts({required String limit}) async {
    try {
      dynamic responseJson = await networkServices
          .getApiResponse("https://fakestoreapi.com/products?limit=$limit");
      return responseJson;
    } catch (e) {
      rethrow;
    }
  }
}
