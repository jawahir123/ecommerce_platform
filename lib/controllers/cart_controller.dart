import 'package:get/get.dart';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  // Helper method to resolve URL dynamically
  String resolveUrl(String url) {
    if (url.contains('localhost')) {
      if (GetPlatform.isAndroid) {
        return url.replaceFirst('localhost', '10.0.2.2'); // Android Emulator
      } else if (GetPlatform.isIOS) {
        return url; // iOS uses localhost
      } else {
        return url.replaceFirst(
            'localhost', '192.168.x.x'); // Replace with your machine's IP
      }
    }
    return url;
  }

  // Fetch the userId dynamically from SharedPreferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Fetch the cart from the backend
  Future<void> fetchCart() async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) {
        print('Error: User ID not found.');
        return;
      }

      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/cart/$userId'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['data'] != null) {
          cartItems.value = (data['data']['items'] as List).map((item) {
            return CartItem(
              id: item['_id'], // Assuming cart item has an ID
               productId: item['product_id']['_id'],
              name: item['product_id']['name'],
              price: (item['product_id']['price'] as num).toDouble(),
              imageUrl: resolveUrl(item['product_id']['image']),
              quantity: item['quantity'],
            );
          }).toList();
        }
      } else {
        print('Failed to fetch cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  // Add a product to the cart on the backend
  Future<void> addToCart(Map<String, dynamic> product) async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found.');
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/cart/add-item'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'product_id': product['_id'], // Use the product ID from the backend
          'quantity': 1, // Default quantity is 1
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Product added to cart successfully!');
        fetchCart(); // Refresh the cart after adding the item
      } else {
        print(
            'Failed to add product to cart. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('Error adding product to cart: $e');
    }
  }

  // Cancel an item from the cart (Remove from UI & Backend)
  // Cancel an item from the cart (Remove from UI & Backend)
Future<void> cancelItem(String cartItemId, String productId, String userId) async {
  try {
    // Step 1: Remove the item from the UI immediately
    cartItems.removeWhere((item) => item.id == cartItemId);
    print('Item removed from UI.');

    // Step 2: Send a request to backend to remove the item from the database
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/cart/remove-item'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'cart_item_id': cartItemId,
        'product_id': productId,
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      print('Item successfully removed from backend.');
    } else {
      print(
          'Failed to remove item from backend. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  } catch (e) {
    print('Error canceling item: $e');
  }
}

  // Update Quantity of a Cart Item
  Future<void> updateQuantityBackend(String cartItemId, int newQuantity) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/cart/update-item'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cart_item_id': cartItemId,
          'quantity': newQuantity,
        }),
      );
      if (response.statusCode == 200) {
        print('Quantity updated successfully');
        fetchCart(); // Refresh the cart
      } else {
        print('Failed to update quantity: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // Place an Order
  Future<void> placeOrder() async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found.');
      }

      // Create an order with all items in the cart
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'items': cartItems.map((item) {
            return {
              'product_id': item.id,
              'quantity': item.quantity,
              'price': item.price, // Ensure correct price is sent
              'totalPrice':
                  item.price * item.quantity, // Total price per product
            };
          }).toList(),
          'total_price': totalAmount, // Overall total price
          'status': 'Pending', // Default order status
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Order placed successfully!');
        cartItems.clear(); // Clear the cart after placing the order
        Get.snackbar('Success', 'Your order has been placed!',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        print('Failed to place order. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('Error placing order: $e');
    }
  }

  // Get total cart amount
  double get totalAmount {
    return cartItems.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}
