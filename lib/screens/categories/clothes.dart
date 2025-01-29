import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/screens/products/productCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ClothesScreen extends StatefulWidget {
  @override
  _ClothesScreenState createState() => _ClothesScreenState();
}

class _ClothesScreenState extends State<ClothesScreen> {
  final CartController cartController = Get.find(); // ✅ Get CartController
  List<Map<String, dynamic>> clothes = [];
  bool isLoading = true;
  String? userId; // ✅ Store user ID

  @override
  void initState() {
    super.initState();
    loadUserId();
    fetchProducts('6772e0408dc3342f6981137f'); // Pass categoryId here
  }

  // ✅ Load User ID from SharedPreferences
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });

    if (userId == null || userId!.isEmpty) {
      Get.snackbar("Error", "User ID not found. Please log in.");
    }
  }

  // ✅ Fetch products from the backend
  Future<void> fetchProducts(String categoryId) async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/api/products/$categoryId'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['products'] != null) {
          List<dynamic> products = data['products'];

          setState(() {
            clothes = List<Map<String, dynamic>>.from(products.map((product) {
              if (product['image'] != null) {
                product['image'] = product['image'].replaceFirst(
                  'http://localhost:3000',
                  'http://10.0.2.2:3000',
                );
              }
              return product;
            }));
            isLoading = false;
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

  // ✅ Show product details & Add to Cart
  void showProductDialog(BuildContext context, Map<String, dynamic> product) {
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
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (userId == null || userId!.isEmpty) {
                  Get.snackbar("Error", "User ID not found. Please log in.");
                  return;
                }

                try {
                  await cartController.addToCart(product);
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
                        'Clothes',
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
                itemCount: clothes.length,
                itemBuilder: (context, index) {
                  final cloth = clothes[index];
                  return GestureDetector(
                    onTap: () {
                      showProductDialog(context, cloth);
                    },
                    child: ProductCard(
                      imageUrl: cloth['image'],
                      name: cloth['name'],
                      price: cloth['price'] is int
                          ? cloth['price'].toDouble()
                          : cloth['price'] ?? 0.0,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
