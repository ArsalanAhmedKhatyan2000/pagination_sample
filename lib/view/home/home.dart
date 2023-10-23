import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../data/response/api_response.dart';
import '../../data/response/status.dart';
import '../../model/product_model.dart';
import '../../view_model/products_view_model.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController? scrollController = ScrollController();
  int limit = 10;
  bool isLoadingMoreProducts = false;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance
        .addPostFrameCallback((timeStamp) async => await _fetchProducts());
    scrollController?.addListener(() async => _scrollListener());
  }

  @override
  void dispose() {
    scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Products")),
      body: RefreshIndicator(
        onRefresh: () async => await _fetchProducts(),
        child: Consumer<ProductsViewModel>(
            builder: (context, productsViewModel, child) {
          ApiResponse<List<ProductModel>> listOfProducts =
              productsViewModel.getListOfProducts;
          switch (listOfProducts.status) {
            case Status.loading:
              return const Center(child: CircularProgressIndicator());
            case Status.error:
              return Center(child: Text(listOfProducts.message.toString()));
            case Status.completed:
              return listOfProducts.data == null || listOfProducts.data!.isEmpty
                  ? const Center(child: Text("OOPS! No Products Found"))
                  : ListView.separated(
                      itemCount: isLoadingMoreProducts
                          ? listOfProducts.data!.length + 1
                          : listOfProducts.data!.length,
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        return index < listOfProducts.data!.length
                            ? ProductCard(
                                productModel: listOfProducts.data![index])
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                      },
                    );
            default:
              return const Center(child: Text("OOPS! Something Went Wrong"));
          }
        }),
      ),
    );
  }

  Future<void> _fetchProducts() async {
    try {
      final productsViewModel =
          Provider.of<ProductsViewModel>(context, listen: false);
      await productsViewModel.fetchProducts(limit: limit.toString());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchMoreProducts() async {
    try {
      final productsViewModel =
          Provider.of<ProductsViewModel>(context, listen: false);
      await productsViewModel.fetchMoreProducts(limit: limit.toString());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _scrollListener() async {
    if (scrollController?.position.pixels ==
            scrollController?.position.maxScrollExtent &&
        isLoadingMoreProducts != true) {
      setState(() {
        limit + 10;
        isLoadingMoreProducts = true;
      });
      await _fetchMoreProducts();
      setState(() => isLoadingMoreProducts = false);
    }
  }
}
