import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_3/providers/product_provider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).getProductByUserId(context);
    });
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
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.productState == ProductState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (productProvider.productState == ProductState.nodata) {
                    return const Center(child: Text('No products found'));
                  } else if (productProvider.productState == ProductState.error) {
                    return const Center(child: Text('Error loading products'));
                  } else {
                    return ListView.builder(
                      itemCount: productProvider.listProduct?.length ?? 0,
                      itemBuilder: (context, index) {
                        var product = productProvider.listProduct![index];
                        return ListTile(
                          title: Text(product.name ?? ''),
                          subtitle: Text('Qty: ${product.qty}, Category ID: ${product.categoryId}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditProductDialog(context, product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteConfirmationDialog(context, product.id!),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.clearControllers(); // Clear the controllers before showing the dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: Form(
          key: productProvider.formProduct,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: productProvider.nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: productProvider.qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: productProvider.categoryIdController,
                  decoration: const InputDecoration(labelText: 'Category ID'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the category ID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: productProvider.urlProductImageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
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
              productProvider.createProduct(context).then((_) {
                Navigator.of(context).pop();
              });
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, dynamic product) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.detailProduct(context, product.id).then((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Product'),
          content: Form(
            key: productProvider.formProduct,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: productProvider.nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the product name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: productProvider.qtyController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the quantity';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: productProvider.categoryIdController,
                    decoration: const InputDecoration(labelText: 'Category ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the category ID';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: productProvider.urlProductImageController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
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
                productProvider.updateProduct(context, product.id).then((_) {
                  Navigator.of(context).pop();
                });
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, int productId) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
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
              productProvider.deleteProduct(context, productId).then((_) {
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
