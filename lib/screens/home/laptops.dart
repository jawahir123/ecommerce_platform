import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/screens/products/productCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LaptopsScreen extends StatefulWidget {
  @override
  _LaptopsScreenState createState() => _LaptopsScreenState();
}

class _LaptopsScreenState extends State<LaptopsScreen> {
  final CartController cartController = Get.find();
  List<Map<String, dynamic>> laptops = [];
  bool isLoading = true;

  // ✅ Fetch Laptops (Change Category ID for Laptops)
  Future<void> fetchLaptops() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/api/products/677e1e829afc4f705d10177f')); // 🔥 Replace with Laptops Category ID

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['products'] != null) {
          List<dynamic> products = data['products'];

          setState(() {
            laptops = List<Map<String, dynamic>>.from(products.map((product) {
              // Convert image URL to work in Android Emulator
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
          print('❌ Error: No laptops found in the response.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('❌ Failed to load laptops. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching laptops: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLaptops();
  }

  // ✅ Show Laptop Details
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
                        'Laptops',
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
                itemCount: laptops.length,
                itemBuilder: (context, index) {
                  final laptop = laptops[index];
                  return GestureDetector(
                    onTap: () {
                      showProductDialog(context, laptop);
                    },
                    child: ProductCard(
                      imageUrl: laptop['image'],
                      name: laptop['name'],
                      price: laptop['price'] is int
                          ? laptop['price'].toDouble()
                          : laptop['price'] ?? 0.0,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
