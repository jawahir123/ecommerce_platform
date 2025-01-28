import 'package:get/get.dart';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  // Fetch the cart from the backend
  Future<void> fetchCart(String userId) async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/cart/$userId'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['data'] != null) {
          cartItems.value = (data['data']['items'] as List).map((item) {
            return CartItem(
              id: item['_id'], // Assuming cart item has an ID
              name: item['product_id']['name'],
              price: (item['product_id']['price'] as num).toDouble(),
              imageUrl: item['product_id']['image'],
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
  Future<void> addToCart(String userId, Map<String, dynamic> product) async {
    try {
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
        fetchCart(userId); // Refresh the cart after adding the item
      } else {
        print(
            'Failed to add product to cart. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('Error adding product to cart: $e');
    }
  }

  // Update quantity of a cart item on the backend
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
        fetchCart('your_user_id_here'); // Update cart from backend
      } else {
        print('Failed to update quantity: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // Remove an item from the cart on the backend
  Future<void> removeFromCartBackend(String cartItemId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/cart/remove-item'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cart_item_id': cartItemId,
        }),
      );

      if (response.statusCode == 200) {
        print('Item removed successfully');
        fetchCart('your_user_id_here'); // Update cart from backend
      } else {
        print('Failed to remove item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  // Get total cart amount
  double get totalAmount {
    return cartItems.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}
