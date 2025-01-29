import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/screens/home/clothes.dart';
import 'package:ecommerce_app/screens/home/laptops.dart';
import 'package:ecommerce_app/screens/home/mobiles.dart';
import 'package:ecommerce_app/screens/home/watches.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ✅ Theme Controller for Dark Mode Toggle
class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image'] != null
          ? json['image']
              .replaceFirst('http://localhost:3000', 'http://10.0.2.2:3000')
          : 'https://via.placeholder.com/150',
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CartController cartController = Get.find();
  final ThemeController themeController =
      Get.put(ThemeController()); // ✅ Add ThemeController

  List<String> bannerImages = [
    'assets/images/kabo.png',
    'assets/images/kabo2.png',
    'assets/images/1.png',
  ];

  List<Product> products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // ✅ Fetch Products
  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/products/getAll'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> productList = data['products'];

        setState(() {
          products =
              productList.map((product) => Product.fromJson(product)).toList();
        });
      } else {
        print('❌ Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Error fetching products: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(110), // ✅ Adjusted AppBar height
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xff8A50FF),
              elevation: 0,
              flexibleSpace: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Row for Welcome Text & Switch Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome,",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              "shukri,",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple),
                            ),
                          ],
                        ),
                        // ✅ Dark Mode Switch Button
                        Switch(
                          value: themeController.isDarkMode.value,
                          onChanged: (value) {
                            themeController.toggleTheme();
                          },
                          activeColor: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // ✅ Search Bar inside AppBar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintText: "Search...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10), // ✅ Adjust spacing after AppBar

                // ✅ Banner (Carousel Slider inside a Card)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    elevation: 5, // Shadow effect
                    color: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 160,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          autoPlayInterval: Duration(seconds: 3),
                        ),
                        items: bannerImages.map((imagePath) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // ✅ Categories Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      chipsWidget(
                          imgurl: "assets/images/3.png",
                          title: "Clothes",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ClothesScreen()))),
                      chipsWidget(
                          imgurl: "assets/images/1.png",
                          title: "Phones",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MobilesScreen()))),
                      chipsWidget(
                          imgurl: "assets/images/2.png",
                          title: "Watches",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Watches()))),
                      chipsWidget(
                          imgurl: "assets/images/Laptop.png",
                          title: "Laptops",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LaptopsScreen()))),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // ✅ New Arrivals Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("New Arrivals",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xff8A50FF)),
                        onPressed: fetchProducts,
                        child: Text("View All"),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // ✅ Display products in a GridView
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        itemCount: products.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 5,
                            child: Column(
                              children: [
                                Expanded(
                                    child: Image.network(product.imageUrl,
                                        fit: BoxFit.cover)),
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(product.name,
                                        style: TextStyle(fontSize: 18))),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ));
  }
}

// ✅ Widget for category buttons
Widget chipsWidget(
    {required String imgurl,
    required String title,
    required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Image.asset(imgurl, width: 45, height: 45),
        Text(title),
      ],
    ),
  );
}
