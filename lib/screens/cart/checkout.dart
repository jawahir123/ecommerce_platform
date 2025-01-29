import 'package:ecommerce_app/screens/home/homeScreen.dart';
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
  var isLoading = false.obs; // Observable for loading state
  String userId = "";

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  // ✅ Load User ID from SharedPreferences
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });

    if (userId.isEmpty) {
      Get.snackbar("Error", "User ID not found. Please log in.");
    }
  }

  // ✅ Function to place order
  Future<void> placeOrder() async {
    if (_addressController.text.isEmpty) {
      Get.snackbar("Error", "Please enter your shipping address.");
      return;
    }

    if (cartController.cartItems.isEmpty) {
      Get.snackbar("Error", "Your cart is empty.");
      return;
    }

    final userId =
        await cartController.getUserId(); // ✅ Ensure user ID is fetched
    if (userId == null || userId.isEmpty) {
      Get.snackbar("Error", "User ID is missing. Please log in.");
      return;
    }

    // ✅ Correct JSON Payload
    final orderData = {
      "user_id": userId, // 🔥 Fixed user_id
      "items": cartController.cartItems.map((item) {
        return {
          "product_id": item.productId, // 🔥 Ensure correct field
          "quantity": item.quantity,
          "price": item.price,
        };
      }).toList(),
      "total_price": cartController.totalAmount, // 🔥 Fixed total_price
      "shipping_address": _addressController.text,
      "payment_method": "Cash on Delivery",
      "status": "Pending",
    };

    try {
      isLoading.value = true; // ✅ Show loading indicator
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/order/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      print("🛑 Place Order Response: ${response.body}"); // ✅ Debug response

      if (response.statusCode == 201) {
        cartController.cartItems.clear(); // ✅ Clear cart after success
        _showSuccessPopup(); // ✅ Show Thank You Popup
      } else {
        print('❌ Order failed: ${response.body}');
        Get.snackbar("Error", "Order placement failed.");
      }
    } catch (e) {
      print('❌ Error placing order: $e');
      Get.snackbar("Error", "Something went wrong. Please try again.");
    } finally {
      isLoading.value = false; // ✅ Hide loading indicator
    }
  }

  // ✅ Show success popup instead of navigating to another screen
  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 10),
                Text("Thank You!",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          content: Text(
            "Your order has been placed successfully.\nWe appreciate your shopping with us!",
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close popup
                  Get.offAll(() => HomeScreen()); // ✅ Redirect to HomeScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("OK"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Checkout"), backgroundColor: Color(0xFF7B3FF6)),
      body: Obx(
        () => isLoading.value
            ? Center(child: CircularProgressIndicator()) // 🔥 Loading indicator
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // ✅ Cart Items List
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

                    // ✅ Shipping Address Input
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: "Shipping Address",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),

                    // ✅ Total Price
                    Obx(() => Text(
                          "Total: \$${cartController.totalAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(height: 20),

                    // ✅ Place Order Button
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
