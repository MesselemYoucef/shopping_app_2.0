import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', title: '', price: 0.0, description: '', imageUrl: '');

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((_imageUrlController.text.isEmpty) ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() {
    final _isValide = _form.currentState!.validate();
    if (!_isValide) {
      return;
    }
    _form.currentState!.save();
    Provider.of<ProductsProvider>(context, listen: false)
        .addProduct(_editedProduct);
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Empty Field';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                        title: value!,
                        id: _editedProduct.id,
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the price.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a number';
                    }
                    if (double.parse(value) < 0) {
                      return 'Please enter a positive number';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                        title: _editedProduct.title,
                        id: _editedProduct.id,
                        price: double.parse(value!),
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.length < 10) {
                      return 'Should be at least 10 characters long';
                    }
                    return null;
                  },
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  focusNode: _descriptionFocusNode,
                  onSaved: (value) {
                    _editedProduct = Product(
                        title: _editedProduct.title,
                        id: _editedProduct.id,
                        price: _editedProduct.price,
                        description: value!,
                        imageUrl: _editedProduct.imageUrl);
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? const Text('Enter a URL')
                          : FittedBox(
                              fit: BoxFit.contain,
                              child: Image.network(
                                _imageUrlController.text,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Image URL'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an image url';
                          }
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'Please enter a valid url starts with (http) or (https)';
                          }
                          if (!value.endsWith('.png') &&
                              !value.endsWith('.jpg') &&
                              !value.endsWith('.jpeg')) {
                            return 'Please enter a valid image Url';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        onEditingComplete: () {
                          setState(() {});
                        },
                        focusNode: _imageUrlFocusNode,
                        onFieldSubmitted: (_) => _saveForm(),
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              id: _editedProduct.id,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: value!);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
