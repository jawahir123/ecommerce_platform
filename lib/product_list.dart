import 'package:ecommerce_app/models/product.dart';
import 'package:flutter/material.dart';
import './services/ProductService.dart';

// class ProductList extends StatelessWidget {
//   const ProductList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Product List'),
//       ),
//       body: FutureBuilder<List<Product>>(
//         future: ProductService.fetchProducts(), // Fetch products from API
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No products found.'));
//           } else {
//             final products = snapshot.data!;

//             return ListView.builder(
//               itemCount: products.length,
//               itemBuilder: (context, index) {
//                 final product = products[index];

//                 return Card(
//                   child: ListTile(
//                     leading: Container(
//                       width: 50, // Set the width of the image container
//                       height: 50, // Set the height of the image container
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: NetworkImage(product.image),
//                           fit: BoxFit.cover, // Ensure image is clipped to fit
//                         ),
//                       ),
//                     ),
//                     title: Text(product.name),
//                     subtitle: Text('\$${product.price}'),
//                     trailing: Text('Stock: ${product.stock}'),
//                     onTap: () {
//                       // Navigate to product details page
//                     },
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

import './screens/products/productCard.dart'; // Import the ProductCard widget

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: FutureBuilder<List<Product>>(
        future: ProductService.fetchProducts(), // Fetch products from API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found.'));
          } else {
            final products = snapshot.data!;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                // Use the custom ProductCard widget here
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ProductCard(
                    imageUrl: product
                        .image, // Assuming product.image contains image URL
                    name: product.name,
                    price: product.price,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
