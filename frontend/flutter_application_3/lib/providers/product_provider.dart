import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_3/models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  // Key
  final formProduct = GlobalKey<FormState>();

  // SharedPreferences instance
  late SharedPreferences _sharedPref;

  // State
  ProductState productState = ProductState.initial;

  // Base URL for API
  String url = 'http://192.168.1.105:3000';

  // Product attributes
  var name = '';
  var qty = '';
  var categoryId = '';
  var urlProductImage = '';
  List<Data>? listProduct = [];

  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController categoryIdController = TextEditingController();
  final TextEditingController urlProductImageController = TextEditingController();

  // Fetch products by user ID
  Future<void> getProductByUserId(BuildContext context) async {
    _sharedPref = await SharedPreferences.getInstance();
    var userId = _sharedPref.getInt('id');

    try {
      productState = ProductState.loading;
      notifyListeners();

      var response = await Dio().get('$url/products/user/$userId');
      var result = ProductModel.fromJson(response.data);

      if (result.data!.isEmpty) {
        productState = ProductState.nodata;
      } else {
        productState = ProductState.success;
        listProduct = result.data;
      }
    } on DioException catch (e) {
      print('Error: ${e.message}');
      productState = ProductState.error;
    }
    notifyListeners();
  }

  // Create a new product
  Future<void> createProduct(BuildContext context) async {
    try {
      _sharedPref = await SharedPreferences.getInstance();
      var userId = _sharedPref.getInt('id');

      var requestModel = {
        'name': nameController.text,
        'qty': qtyController.text,
        'categoryId': categoryIdController.text,
        'url': urlProductImageController.text,
        'createdBy': userId
      };

      var response = await Dio().post('$url/products/$userId', data: requestModel);

      if (response.statusCode == 201 && response.data['message'] == 'success') {
        alertSuccess(context, 'Product created successfully');
        clearControllers();
        getProductByUserId(context);
      } else {
        alertFailed(context, response.data['message']);
      }
    } on DioException catch (e) {
      print('Error: ${e.message}');
      alertFailed(context, 'Error creating product');
    }
    notifyListeners();
  }

  // Fetch product details by product ID
  Future<void> detailProduct(BuildContext context, int id) async {
    try {
      var response = await Dio().get('$url/products/$id');
      var data = response.data['data'];
      nameController.text = data['name'];
      qtyController.text = data['qty'].toString();
      categoryIdController.text = data['categoryId'].toString();
      urlProductImageController.text = data['url'];
    } on DioException catch (e) {
      print('Error: ${e.message}');
      alertFailed(context, 'Error fetching product details');
    }
    notifyListeners();
  }

  // Update an existing product
  Future<void> updateProduct(BuildContext context, int id) async {
    try {
      _sharedPref = await SharedPreferences.getInstance();
      var userId = _sharedPref.getInt('id');

      var requestModel = {
        'name': nameController.text,
        'qty': qtyController.text,
        'categoryId': categoryIdController.text,
        'url': urlProductImageController.text,
        'updatedBy': userId
      };

      var response = await Dio().patch('$url/products/$id', data: requestModel);
      if (response.statusCode == 200 && response.data['message'] == 'success') {
        alertSuccess(context, 'Product updated successfully');
        getProductByUserId(context);
      } else {
        alertFailed(context, response.data['message']);
      }
    } on DioException catch (e) {
      print('Error: ${e.message}');
      alertFailed(context, 'Error updating product');
    }
    notifyListeners();
  }

  // Delete a product by ID
  Future<void> deleteProduct(BuildContext context, int id) async {
    try {
      var response = await Dio().delete('$url/products/$id');
      if (response.statusCode == 200 && response.data['message'] == 'Product deleted successfully') {
        Navigator.pop(context);
        getProductByUserId(context);
      } else {
        alertFailed(context, response.data['message']);
      }
    } on DioException catch (e) {
      print('Error: ${e.message}');
      alertFailed(context, 'Error deleting product');
    }
    notifyListeners();
  }

  // Clear controllers
  void clearControllers() {
    nameController.clear();
    qtyController.clear();
    categoryIdController.clear();
    urlProductImageController.clear();
  }

  // Alert message for success
  void alertSuccess(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 50),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Alert message for failure
  void alertFailed(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 50),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

enum ProductState { initial, loading, success, error, nodata }
