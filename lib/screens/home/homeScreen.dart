import 'package:ecommerce_app/screens/cart/cart_screen.dart';
import 'package:ecommerce_app/screens/home/clothes.dart';
import 'package:ecommerce_app/screens/home/search.dart';
import 'package:ecommerce_app/screens/home/homePage.dart';
import 'package:ecommerce_app/screens/home/mobiles.dart';
import 'package:ecommerce_app/screens/home/message.dart';
import 'package:ecommerce_app/screens/home/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/cart_item.dart'; // Import CartItem model

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected index for BottomNavigationBar
  List<CartItem> cartItems = []; // Manage cartItems list here

  // List of screens for each tab
  final List<Widget> _screens = [
    HomePage(),
    MySearchBAR(),
    CartScreen(), // Placeholder, will be updated dynamically
    MessageScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  // Function to add an item to the cart
  void addToCart(Map<String, dynamic> product) {
    // Check if the product is already in the cart
    final existingIndex = cartItems.indexWhere(
      (item) => item.name == product['name'],
    );

    if (existingIndex >= 0) {
      // If the product exists, increase its quantity
      setState(() {
        cartItems[existingIndex].quantity++;
      });
    } else {
      // If the product doesn't exist, add it to the cart
      setState(() {
        cartItems.add(
          CartItem(
            name: product['name'],
            price: product['price'] is int
                ? product['price'].toDouble() // Convert int to double
                : product['price'] ?? 0.0, // Fallback to 0.0 if null
            imageUrl: product['image'],
          ),
        );
      });
    }

    print('${product['name']} added to cart');
  }

  @override
  Widget build(BuildContext context) {
    // Update the CartScreen with the current cartItems list
    _screens[2] = CartScreen();

    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handle tap on bottom nav items
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "search"),
          BottomNavigationBarItem(icon: Icon(Icons.card_travel), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Message"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined), label: "Profile"),
        ],
      ),
    );
  }
}