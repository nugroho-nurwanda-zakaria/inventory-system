// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<String> products = [];

  final TextEditingController _controller = TextEditingController();

  void _addProduct() {
    setState(() {
      products.add(_controller.text);
    });
    _controller.clear();
  }

  void _deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  void _updateProduct(int index, String newName) {
    setState(() {
      products[index] = newName;
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
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Product Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addProduct,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(products[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _controller.text = products[index];
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Update Product'),
                                content: TextField(
                                  controller: _controller,
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateProduct(index, _controller.text);
                                      Navigator.of(context).pop();
                                      _controller.clear();
                                    },
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteProduct(index),
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
}
