import 'package:get/get.dart';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs; // To manage loading state

  @override
  void onInit() {
    super.onInit();
    fetchCart(); // ✅ Auto-fetch cart when initialized
  }

  // ✅ Helper: Resolve API URL dynamically
  String resolveUrl(String url) {
    if (url.contains('localhost')) {
      return url.replaceFirst('localhost', '10.0.2.2'); // Android Emulator
    }
    return url;
  }

  // ✅ Fetch the userId dynamically from SharedPreferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // ✅ Fetch the cart from the backend
  Future<void> fetchCart() async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) {
        print('❌ Error: User ID not found.');
        return;
      }

      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/cart/$userId'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['cart'] != null && data['cart']['items'] != null) {
          cartItems.value = (data['cart']['items'] as List).map((item) {
            return CartItem(
              id: item['_id'],
              productId: item['product_id']['_id'],
              name: item['product_id']['name'],
              price: (item['product_id']['price'] as num).toDouble(),
              imageUrl: resolveUrl(item['product_id']['image']),
              quantity: item['quantity'],
            );
          }).toList();
        } else {
          cartItems.clear();
        }
      } else {
        print('❌ Failed to fetch cart: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching cart: $e');
    }
  }

  // ✅ Add product to the cart
  Future<void> addToCart(Map<String, dynamic> product) async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty)
        throw Exception('User ID not found.');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/cart/add-item'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'product_id': product['_id'],
          'quantity': 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart(); // ✅ Refresh cart after update
      } else {
        print('❌ Failed to add product to cart: ${response.body}');
      }
    } catch (e) {
      print('❌ Error adding to cart: $e');
    }
  }

  // ✅ Cancel item from cart (Frontend + Backend)
  Future<void> cancelItem(
      String cartItemId, String productId, String userId) async {
    try {
      cartItems.removeWhere((item) => item.id == cartItemId); // UI update first

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
        await fetchCart(); // ✅ Refresh cart after deletion
      } else {
        print('❌ Failed to remove item: ${response.body}');
      }
    } catch (e) {
      print('❌ Error removing item: $e');
    }
  }

  // ✅ Update quantity in cart
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
        await fetchCart(); // ✅ Refresh cart after update
      } else {
        print('❌ Failed to update quantity: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating quantity: $e');
    }
  }

  // ✅ Place an Order
  Future<void> placeOrder(String address) async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Your cart is empty!');
      return;
    }

    final userId = await getUserId();
    if (userId == null || userId.isEmpty) {
      Get.snackbar('Error', 'User ID not found.');
      return;
    }

    final orderData = {
      "user_id": userId,
      "items": cartItems.map((item) {
        return {
          "product_id": item.productId, // Correct ID field
          "quantity": item.quantity,
          "price": item.price,
        };
      }).toList(),
      "total_price": totalAmount,
      "shipping_address": address,
      "payment_method": "Cash on Delivery",
      "status": "Pending",
    };

    try {
      isLoading.value = true; // Start loading

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/order/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        cartItems.clear(); // ✅ Clear cart after order
        Get.offAllNamed('/orderSuccess');
      } else {
        Get.snackbar('Order Failed', 'Please try again.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong.');
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  // ✅ Get total cart amount
  double get totalAmount {
    return cartItems.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}
