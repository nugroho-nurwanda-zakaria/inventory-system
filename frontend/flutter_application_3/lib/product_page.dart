import 'package:flutter/material.dart';

class Product {
  int? id;
  String? name;
  int? qty;
  int? categoryId;
  String? urlProductImage;

  Product({this.id, this.name, this.qty, this.categoryId, this.urlProductImage});
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _categoryIdController = TextEditingController();
  final TextEditingController _urlProductImageController = TextEditingController();

  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Replace this with your actual fetch logic
      await Future.delayed(const Duration(seconds: 2));
      _products = [
        Product(id: 1, name: 'Product 1', qty: 10, categoryId: 1),
        Product(id: 2, name: 'Product 2', qty: 5, categoryId: 2),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final newProduct = Product(
      id: _products.length + 1,
      name: _nameController.text,
      qty: int.parse(_qtyController.text),
      categoryId: int.parse(_categoryIdController.text),
      urlProductImage: _urlProductImageController.text,
    );

    setState(() {
      _products.add(newProduct);
    });
  }

  Future<void> _editProduct(Product product) async {
    _nameController.text = product.name ?? '';
    _qtyController.text = product.qty?.toString() ?? '';
    _categoryIdController.text = product.categoryId?.toString() ?? '';
    _urlProductImageController.text = product.urlProductImage ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(_nameController, 'Name'),
                _buildTextFormField(_qtyController, 'Quantity', keyboardType: TextInputType.number),
                _buildTextFormField(_categoryIdController, 'Category ID', keyboardType: TextInputType.number),
                _buildTextFormField(_urlProductImageController, 'Image URL'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  product.name = _nameController.text;
                  product.qty = int.parse(_qtyController.text);
                  product.categoryId = int.parse(_categoryIdController.text);
                  product.urlProductImage = _urlProductImageController.text;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(int productId) async {
    setState(() {
      _products.removeWhere((product) => product.id == productId);
    });
  }

  TextFormField _buildTextFormField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the $labelText';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Product Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _showAddProductDialog(context),
              child: const Text('Add New Product'),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? const Center(child: Text('Error loading products'))
                      : _products.isEmpty
                          ? const Center(child: Text('No products found'))
                          : ListView.builder(
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                var product = _products[index];
                                return ListTile(
                                  title: Text(product.name ?? ''),
                                  subtitle: Text('Qty: ${product.qty}, Category ID: ${product.categoryId}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editProduct(product),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _showDeleteConfirmationDialog(context, product.id!),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    _nameController.clear();
    _qtyController.clear();
    _categoryIdController.clear();
    _urlProductImageController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(_nameController, 'Name'),
                _buildTextFormField(_qtyController, 'Quantity', keyboardType: TextInputType.number),
                _buildTextFormField(_categoryIdController, 'Category ID', keyboardType: TextInputType.number),
                _buildTextFormField(_urlProductImageController, 'Image URL'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addProduct().then((_) {
                Navigator.of(context).pop();
              });
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteProduct(productId).then((_) {
                Navigator.of(context).pop();
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

