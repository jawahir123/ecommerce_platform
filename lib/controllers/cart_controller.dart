import 'package:get/get.dart';
import 'package:ecommerce_app/models/cart_item.dart';

class CartController extends GetxController {
  // Observable list of cart items
  var cartItems = <CartItem>[].obs;

  // Add a product to the cart
  void addToCart(Map<String, dynamic> product) {
    final existingIndex = cartItems.indexWhere(
      (item) => item.name == product['name'],
    );

    if (existingIndex >= 0) {
      // If the product exists, increase its quantity
      cartItems[existingIndex].quantity++;
    } else {
      // If the product doesn't exist, add it to the cart
      cartItems.add(
        CartItem(
          name: product['name'],
          price: product['price'] is int
              ? product['price'].toDouble()
              : product['price'] ?? 0.0,
          imageUrl: product['image'],
        ),
      );
    }

    print('${product['name']} added to cart');
  }

  // Remove an item from the cart
  void removeFromCart(int index) {
    cartItems.removeAt(index);
  }

  // Update the quantity of an item in the cart
  void updateQuantity(int index, int quantity) {
    cartItems[index].quantity = quantity;
  }

  // Calculate the total amount of the cart
  double get totalAmount {
    return cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}