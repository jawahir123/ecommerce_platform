import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/screens/products/productCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

class WatchesScreen extends StatefulWidget {
  @override
  _WatchesScreenState createState() => _WatchesScreenState();
}

class _WatchesScreenState extends State<WatchesScreen> {
  final CartController cartController = Get.find();
  List<Map<String, dynamic>> watches = [];
  bool isLoading = true;

  // ✅ Function to fetch products from the backend
  Future<void> fetchProducts(String categoryId) async {
    setState(() {
      isLoading = true; // Set loading to true while fetching
    });

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/api/products/$categoryId'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['products'] != null) {
          List<dynamic> products = data['products'];

          // ✅ Set the watches list with the fetched products
          setState(() {
            watches = List<Map<String, dynamic>>.from(products.map((product) {
              // Replace "localhost" with "10.0.2.2" in the image URL
              if (product['image'] != null) {
                product['image'] = product['image'].replaceFirst(
                  'http://localhost:3000',
                  'http://10.0.2.2:3000',
                );
              }
              return product;
            }));
            isLoading = false; // Set loading to false once data is fetched
          });
        } else {
          print('⚠️ No products found in the response.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('❌ Failed to load products. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts('677e1e9c9afc4f705d101781');
  }

  // ✅ Show product details dialog
  void showProductDialog(BuildContext context, Map<String, dynamic> product) {
    print('Product Data: $product');
    print('Image URL: ${product['image']}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            product['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: 150,
                  child: Image.network(
                    product['image'] ?? 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Icon(Icons.error, color: Colors.red);
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  product['description'] ?? "No description available.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Text(
                  'Price: \$${product['price'].toString()}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Close"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await cartController.addToCart({
                    "_id": product['_id'],
                    "name": product['name'],
                    "price": product['price'],
                    "image": product['image'],
                  });
                  Get.snackbar("Success", "${product['name']} added to cart!");
                  Navigator.pop(context);
                } catch (e) {
                  Get.snackbar("Error", "Failed to add to cart: $e");
                }
              },
              child: Text("Add to Cart"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: Container(
              color: const Color(0xFF7B3FF6),
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'Watches',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: watches.length,
                itemBuilder: (context, index) {
                  final watch = watches[index];
                  return GestureDetector(
                    onTap: () {
                      showProductDialog(context, watch);
                    },
                    child: ProductCard(
                      imageUrl: watch['image'],
                      name: watch['name'],
                      price: watch['price'] is int
                          ? watch['price'].toDouble() // Convert int to double
                          : watch['price'] ?? 0.0, // Fallback to 0.0 if null
                    ),
                  );
                },
              ),
      ),
    );
  }
}
