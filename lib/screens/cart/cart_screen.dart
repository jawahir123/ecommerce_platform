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
            : ListView.builder(
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
                                    ? () => cartController.updateQuantity(index, cartItem.quantity - 1)
                                    : null,
                              ),
                              Text(cartItem.quantity.toString()),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () => cartController.updateQuantity(index, cartItem.quantity + 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onLongPress: () {
                        cartController.removeFromCart(index); // Remove item on long press
                      },
                    ),
                  );
                },
              );
      }),
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
              Obx(() {
                return Text(
                  'Total: \$${cartController.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
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
      ),
    );
  }
}