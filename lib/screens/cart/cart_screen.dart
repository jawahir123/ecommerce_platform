import 'package:ecommerce_app/screens/cart/checkout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/controllers/cart_controller.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController =
      Get.find(); // Get the CartController instance

  @override
  void initState() {
    super.initState();
    cartController.fetchCart(); // 🛑 Ensure cart data loads when screen opens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Color(0xFF7B3FF6),
      ),
      body: Column(
        children: [
          // Expanded ensures ListView takes available space
          Expanded(
            child: Obx(() {
              print("🛑 Cart Items: ${cartController.cartItems}");

              final cartItems = cartController.cartItems;

              return cartItems.isEmpty
                  ? Center(
                      child: Text(
                        'Your cart is empty.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (ctx, index) {
                        final cartItem = cartItems[index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading: Image.network(
                              cartItem.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error);
                              },
                            ),
                            title: Text(cartItem.name),
                            subtitle:
                                Text('\$${cartItem.price.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 🔻 Decrease Quantity (-)
                                IconButton(
                                  icon: Icon(Icons.remove, color: Colors.red),
                                  onPressed: cartItem.quantity > 1
                                      ? () async {
                                          await cartController
                                              .updateQuantityBackend(
                                            cartItem.id,
                                            cartItem.quantity -
                                                1, // Decrease quantity
                                          );
                                        }
                                      : null, // Disable if quantity is already 1
                                ),

                                // 🟢 Display Quantity
                                Text(cartItem.quantity.toString(),
                                    style: TextStyle(fontSize: 16)),

                                // 🔺 Increase Quantity (+)
                                IconButton(
                                  icon: Icon(Icons.add, color: Colors.green),
                                  onPressed: () async {
                                    await cartController.updateQuantityBackend(
                                      cartItem.id,
                                      cartItem.quantity +
                                          1, // Increase quantity
                                    );
                                  },
                                ),

                                // ❌ Cancel (Remove) Item
                                IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () async {
                                    final userId = await cartController
                                        .getUserId(); // Fetch User ID
                                    await cartController.cancelItem(
                                      cartItem.id, // Cart item ID
                                      cartItem
                                          .productId, // Product ID (ensure this exists)
                                      userId!, // User ID (non-null)
                                    );

                                    // Show snackbar confirmation
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              '${cartItem.name} removed from cart!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
            }),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            height: 70, // Fixed height to prevent overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  return Text(
                    'Total: \$${cartController.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                ElevatedButton(
                  onPressed: () {
                    Get.to(
                        () => CheckoutScreen()); // Navigate to CheckoutScreen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                  ),
                  child: Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
