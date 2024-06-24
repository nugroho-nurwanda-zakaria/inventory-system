import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/category_model.dart';

enum CategoryState { initial, loading, success, error, noData }

class CategoryProvider extends ChangeNotifier {
  final formCategory = GlobalKey<FormState>();
  final String baseUrl = 'http://192.168.1.105:3000';
  final TextEditingController nameController = TextEditingController();

  CategoryState _categoryState = CategoryState.initial;
  List<Data> _listCategory = [];

  CategoryState get categoryState => _categoryState;
  List<Data> get listCategory => _listCategory;

  Future<void> getCategory(BuildContext context) async {
    try {
      _setState(CategoryState.loading);
      
      final response = await Dio().get('$baseUrl/categories');
      final result = CategoryModel.fromJson(response.data);

      _listCategory = result.data ?? [];
      _setState(_listCategory.isEmpty ? CategoryState.noData : CategoryState.success);
    } on DioException catch (e) {
      _handleError(context, e);
    }
  }

  Future<void> createCategory(BuildContext context) async {
    if (!_validateForm()) {
      _showAlertFieldEmpty(context);
      return;
    }

    try {
      final requestModel = {'name': nameController.text};
      final response = await Dio().post('$baseUrl/categories', data: requestModel);

      if (response.statusCode == 201 && response.data['message'] == 'Success') {
        _handleSuccess(context, 'Category created successfully');
        nameController.clear();
        await getCategory(context);
      } else {
        _handleFailed(context, response.data['error'] ?? 'Failed to create category');
      }
    } on DioException catch (e) {
      _handleError(context, e);
    }
  }

  Future<void> detailCategory(BuildContext context, int id) async {
    try {
      final response = await Dio().get('$baseUrl/categories/$id');
      if (response.data['message'] == 'Success') {
        nameController.text = response.data['data']['name'];
      } else {
        _handleFailed(context, response.data['message'] ?? 'Category not found');
      }
    } on DioException catch (e) {
      _handleError(context, e);
    }
    notifyListeners();
  }

  Future<void> updateCategory(BuildContext context, int id) async {
    if (!_validateForm()) {
      _showAlertFieldEmpty(context);
      return;
    }

    try {
      final requestModel = {'name': nameController.text};
      final response = await Dio().patch('$baseUrl/categories/$id', data: requestModel);

      if (response.statusCode == 200 && response.data['message'] == 'Success') {
        _handleSuccess(context, 'Category updated successfully');
        nameController.clear();
        await getCategory(context);
      } else {
        _handleFailed(context, response.data['error'] ?? 'Failed to update category');
      }
    } on DioException catch (e) {
      _handleError(context, e);
    }
  }

  Future<void> deleteCategory(BuildContext context, int id) async {
    try {
      final response = await Dio().delete('$baseUrl/categories/$id');

      if (response.statusCode == 200 && response.data['message'] == 'Success') {
        _handleSuccess(context, 'Category deleted successfully');
        await getCategory(context);
      } else {
        _handleFailed(context, response.data['message'] ?? 'Failed to delete category');
      }
    } on DioException catch (e) {
      _handleError(context, e);
    }
  }

  void _setState(CategoryState state) {
    _categoryState = state;
    notifyListeners();
  }

  void _handleSuccess(BuildContext context, String message) {
    alertSuccess(context, message);
  }

  void _handleFailed(BuildContext context, String message) {
    alertFailed(context, message);
  }

  void _handleError(BuildContext context, DioException e) {
    _setState(CategoryState.error);
    alertFailed(context, 'Error: ${e.message}');
  }

  bool _validateForm() {
    return formCategory.currentState?.validate() ?? false;
  }

  void _showAlertFieldEmpty(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              SizedBox(height: 8),
              Text('Please fill in the fields', textAlign: TextAlign.center),
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