import 'package:ecommerce_app/screens/cart/cart_screen.dart';
import 'package:ecommerce_app/screens/products/productCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MobilesScreen extends StatefulWidget {
  @override
  _MobilesScreenState createState() => _MobilesScreenState();
}

class _MobilesScreenState extends State<MobilesScreen> {
  List<Map<String, dynamic>> mobiles = [];
  bool isLoading = true;
  List<Map<String, dynamic>> cartItems = [];

  // Function to fetch products from the backend
  Future<void> fetchProducts(String categoryId) async {
    setState(() {
      isLoading = true; // Set loading to true while fetching
    });

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/api/products/categoryID/$categoryId'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['products'] != null) {
          List<dynamic> products = data['products'];

          // Set the mobiles list with the fetched products
          setState(() {
            mobiles = List<Map<String, dynamic>>.from(products.map((product) {
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

  // Function to add product to the cart
  void addToCart(Map<String, dynamic> product) {
    setState(() {
      cartItems.add({
        ...product,
        'quantity': 1, // Default quantity is 1
      });
    });
    print('${product['name']} added to cart');
  }

  @override
  void initState() {
    super.initState();
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
                          ? mobile['price'].toDouble() // Convert int to double
                          : mobile['price'] ?? 0.0, // Fallback to 0.0 if null
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add To Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show product details dialog
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
            product['name'] ?? 'Unnamed Product', // Fallback if name is null
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
                  'Price: \$${product['price'] ?? 'N/A'}', // Fallback if price is null
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
              onPressed: () {
                addToCart(product); // Add to cart functionality
                Navigator.pop(context); // Close dialog
              },
              child: Text("Add to Cart"),
            ),
          ],
        );
      },
    );
  }
}