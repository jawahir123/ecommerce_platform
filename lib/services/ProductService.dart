// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/product.dart'; // Assuming the Product model is saved as 'product.dart'

// class ProductService {
//   static const String apiUrl =
//       'http://10.0.2.2:3000/api/products/getAll'; // Your API endpoint

//   // Fetch all products from the API
//   static Future<List<Product>> fetchProducts() async {
//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.map((product) => Product.fromJson(product)).toList();
//       } else {
//         throw Exception('Failed to load products');
//       }
//     } catch (error) {
//       print('Error fetching products: $error');
//       rethrow;
//     }
//   }
// }

// class ProductService {
//   static const String apiUrl =
//       'http://10.0.2.2:3000/api/products/getAll'; // Your API endpoint

//   // Fetch all products from the API
//   static Future<List<Product>> fetchProducts() async {
//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data =
//             json.decode(response.body); // Change to Map
//         final List<dynamic> productData =
//             data['products']; // Extract 'products' key

//         return productData.map((product) => Product.fromJson(product)).toList();
//       } else {
//         throw Exception('Failed to load products');
//       }
//     } catch (error) {
//       print('Error fetching products: $error');
//       rethrow;
//     }
//   }
// }
