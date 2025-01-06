import 'package:flutter/material.dart';

class Product {
  final String name;
  final String category;
  final double price;

//constructor
  const Product({
    required this.name,
    required this.category,
    required this.price,
  });
}

class ProductListingPage extends StatefulWidget {
  const ProductListingPage({super.key});

  @override
  _ProductListingPageState createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  List<Product> products = [
    Product(name: 'Laptop', category: 'Electronics', price: 1000),
    Product(name: 'Phone', category: 'Electronics', price: 800),
    Product(name: 'T-Shirt', category: 'Clothing', price: 20),
    Product(name: 'Jeans', category: 'Clothing', price: 40),
    Product(name: 'Blender', category: 'Home Appliances', price: 50),
    Product(name: 'Toaster', category: 'Home Appliances', price: 30),
  ];

  String? selectedCategory;
  String? sortOption;

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = products;

    if (selectedCategory != null) {
      filteredProducts = filteredProducts
          .where((product) => product.category == selectedCategory)
          .toList();
    }

    if (sortOption != null) {
      if (sortOption == 'Price: Low to High') {
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (sortOption == 'Price: High to Low') {
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      }
    }

    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 129, 219, 231),
          title: const Text('Product Listing',
              style: TextStyle(
                fontSize: 30.0,
              ))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: const Text(
                    'Filter by Category',
                    style: TextStyle(fontSize: 30),
                  ),
                  value: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  items: [
                    'Electronics',
                    'Clothing',
                    'Home Appliances',
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  hint: const Text(
                    'Sort by',
                    style: TextStyle(fontSize: 30),
                  ),
                  value: sortOption,
                  onChanged: (value) {
                    setState(() {
                      sortOption = value;
                    });
                  },
                  items: [
                    'Price: Low to High',
                    'Price: High to Low',
                  ].map((sort) {
                    return DropdownMenuItem(
                      value: sort,
                      child: Text(sort),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  title: Text(
                    product.name,
                    style: const TextStyle(fontSize: 30.0),
                  ),
                  subtitle: Text(
                    product.category,
                    style: const TextStyle(fontSize: 30.0),
                  ),
                  trailing: Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 30.0),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
