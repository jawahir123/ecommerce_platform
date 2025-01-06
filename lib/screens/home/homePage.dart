import 'package:ecommerce_app/screens/home/search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'cart/cart_screen.dart';
import 'clothes.dart';
import 'mobiles.dart';

class Product {
  final String name;
  final double price;
  final String imageUrl;

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String? ?? 'Unknown', // Fallback to 'Unknown' if null
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Fallback to 0.0 if null
      imageUrl: json['imageUrl'] as String? ?? '', // Fallback to empty string if null
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = []; // Class-level variable to hold the fetched products
  bool isLoading = false;

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/products/getAll'); // Replace with your API endpoint
    try {
      setState(() {
        isLoading = true; // Set loading state before making the request
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract products list and parse it
        List<dynamic> productList = data['products'];

        // Map the fetched products to Product objects and assign them to the class-level variable
        setState(() {
          products = productList.map((product) {
            // Replace "localhost" with "10.0.2.2" in the image URL
            if (product['imageUrl'] != null) {
              product['imageUrl'] = product['imageUrl'].replaceFirst(
                'http://localhost:3000',
                'http://10.0.2.2:3000',
              );
            }
            return Product.fromJson(product);
          }).toList();
        });
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    } finally {
      setState(() {
        isLoading = false; // Reset loading state after fetching
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xff8A50FF),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      right: 30,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dhameeys App!",
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                        MySearchBAR(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 50,
                  bottom: -80,
                  child: Container(
                    height: 181,
                    width: 312,
                    decoration: BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: PageView(
                        children: [
                          RowWidget(),
                          RowWidget(),
                          RowWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 100),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      chipsWidget(
                        imgurl: "assets/images/3.png",
                        title: "Clothes",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClothesScreen()),
                          );
                        },
                      ),
                      chipsWidget(
                        imgurl: "assets/images/1.png",
                        title: "phones",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MobilesScreen()),
                          );
                        },
                      ),
                      chipsWidget(
                        imgurl: "assets/images/2.png",
                        title: "Watches",
                        onTap: () {
                          // Navigate to Watches screen
                        },
                      ),
                      chipsWidget(
                        imgurl: "assets/images/Laptop.png",
                        title: "laptops",
                        onTap: () {
                          // Navigate to Phones screen
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "New arrivals",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          backgroundColor: Color(0xff8A50FF),
                        ),
                        onPressed: fetchProducts,
                        child: Text("View All"),
                      ),
                    ],
                  ),
                  // Display products fetched from the API
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          itemCount: products.length,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Set crossAxisCount to 2 for 2 columns
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        product.imageUrl.isNotEmpty
                                            ? product.imageUrl
                                            : 'https://via.placeholder.com/150', // Fallback image
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('Error loading image: $error');
                                          return Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "\$${product.price.toStringAsFixed(2)}", // Format price to 2 decimal places
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                // Implement "add to cart" logic
                                              },
                                              icon: Icon(Icons.add),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RowWidget extends StatelessWidget {
  const RowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 181,
      width: 312,
      child: Row(
        children: [
          Image.asset(
            "assets/images/kabo.png",
            width: 100,
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Introduction"),
              SizedBox(height: 5),
              Text("Nike max 2090"),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Color(0xff8A50FF),
                ),
                child: Text("See"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget chipsWidget({
  required String imgurl,
  required String title,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Image.asset(
          imgurl,
          width: 45,
          height: 45,
        ),
        Text(title),
      ],
    ),
  );
}