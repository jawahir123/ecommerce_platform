import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartController cartController = Get.find();
  final TextEditingController _addressController = TextEditingController();
  String userId = "";
  var isLoading = false.obs; // Observable for loading state

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  // Load User ID from SharedPreferences
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  // Function to place order
  Future<void> placeOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your shipping address')),
      );
      return;
    }

    if (cartController.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    final orderData = {
      "user_id": userId, // Matches backend schema
      "items": cartController.cartItems.map((item) {
        return {
          "product_id": item.id, // Matches backend schema
          "quantity": item.quantity,
          "price": item.price,
        };
      }).toList(),
      "totalPrice":
          cartController.totalAmount, // Matches `totalPrice` in schema
      "shipping_address": _addressController.text,
      "payment_method": "Cash on Delivery",
      "status": "Pending",
    };

    try {
      isLoading.value = true; // Start loading
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        cartController.cartItems.clear(); // Clear the cart
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
        Get.offAllNamed('/orderSuccess'); // Navigate to success page
      } else {
        print('Failed to place order: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placement failed')),
        );
      }
    } catch (e) {
      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong! Please try again.')),
      );
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Checkout"), backgroundColor: Color(0xFF7B3FF6)),
      body: Obx(
        () => isLoading.value
            ? Center(child: CircularProgressIndicator()) // Loading indicator
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartController.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartController.cartItems[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: Image.network(
                                item.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error, color: Colors.red);
                                },
                              ),
                              title: Text(item.name),
                              subtitle: Text(
                                  "\$${item.price.toStringAsFixed(2)} x ${item.quantity}"),
                              trailing: Text(
                                  "\$${(item.price * item.quantity).toStringAsFixed(2)}"),
                            ),
                          );
                        },
                      ),
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: "Shipping Address",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Obx(() => Text(
                        "Total: \$${cartController.totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Place Order",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
