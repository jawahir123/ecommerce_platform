import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find(); // Get the CartController instance

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Color(0xFF7B3FF6),
      ),
      body: Obx(() {
        final cartItems = cartController.cartItems;

        return cartItems.isEmpty
            ? Center(
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : Column(
                children: [
                  // Expand ListView to take up available space
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (ctx, index) {
                        final cartItem = cartItems[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            subtitle: Text('\$${cartItem.price.toStringAsFixed(2)}'),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total: \$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: cartItem.quantity > 1
                                          ? () async {
                                              await cartController.updateQuantityBackend(
                                                cartItem.id,
                                                cartItem.quantity - 1,
                                              );
                                            }
                                          : null,
                                    ),
                                    Text(cartItem.quantity.toString()),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () async {
                                        await cartController.updateQuantityBackend(
                                          cartItem.id,
                                          cartItem.quantity + 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onLongPress: () async {
                              await cartController.removeFromCartBackend(cartItem.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Footer for total amount and checkout button
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.white,
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
                            // Implement checkout functionality
                            print('Proceeding to checkout...');
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
              );
      }),
    );
  }
}
