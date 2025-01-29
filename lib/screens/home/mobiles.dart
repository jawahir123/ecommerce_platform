import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/screens/products/productCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MobilesScreen extends StatefulWidget {
  @override
  _MobilesScreenState createState() => _MobilesScreenState();
}

class _MobilesScreenState extends State<MobilesScreen> {
  List<Map<String, dynamic>> mobiles = [];
  bool isLoading = true;
  final CartController cartController =
      Get.find(); // Get the CartController instance
  String userId = ""; // Dynamic userId

  // Function to resolve URLs dynamically based on platform
  String resolveUrl(String url) {
    if (url.contains('localhost')) {
      if (GetPlatform.isAndroid) {
        return url.replaceFirst('localhost', '10.0.2.2'); // Android Emulator
      } else if (GetPlatform.isIOS) {
        return url; // iOS uses localhost
      } else {
        return url.replaceFirst(
            'localhost', '192.168.x.x'); // Replace with your machine's IP
      }
    }
    return url;
  }

  // Function to fetch userId dynamically
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });

    if (userId.isEmpty) {
      print('Error: User ID not found. Please log in.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to use the app.')),
      );
    }
  }

  // Function to fetch products from the backend
  Future<void> fetchProducts(String categoryId) async {
    setState(() {
      isLoading = true; // Set loading to true while fetching
    });

    try {
      final response = await http.get(
        Uri.parse(resolveUrl('http://localhost:3000/api/products/$categoryId')),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['products'] != null) {
          List<dynamic> products = data['products'];

          setState(() {
            mobiles = List<Map<String, dynamic>>.from(products.map((product) {
              if (product['image'] != null) {
                product['image'] = resolveUrl(product['image']);
              }
              return product;
            }));
            isLoading = false;
          });
        } else {
          print('Error: No products found in the response.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserId(); // Load user ID dynamically
    fetchProducts('6770428ee220c228e4440550'); // Pass categoryId here
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
                        'Mobiles',
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
                  childAspectRatio: 0.7, // Fixed aspect ratio for better UI
                ),
                itemCount: mobiles.length,
                itemBuilder: (context, index) {
                  final mobile = mobiles[index];
                  return GestureDetector(
                    onTap: () {
                      showProductDialog(context, mobile);
                    },
                    child: ProductCard(
                      imageUrl: mobile['image'],
                      name: mobile['name'],
                      price: mobile['price'] is int
                          ? mobile['price'].toDouble()
                          : mobile['price'] ?? 0.0,
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Show product details dialog
  void showProductDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            product['name'] ?? 'Unnamed Product',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: 150,
                  child: Image.network(
                    resolveUrl(product['image']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error);
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
                  'Price: \$${product['price'] ?? 'N/A'}',
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
                  if (userId.isEmpty) {
                    throw Exception('User not logged in.');
                  }
                  await cartController
                      .addToCart(product); // Pass the product map
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${product['name']} added to cart!')),
                  );
                  Navigator.pop(context); // Close dialog
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add to cart: $e')),
                  );
                }
              },
              child: Text("Add to Cart"),
            ),
          ],
        );
      },
    );
  }
}
