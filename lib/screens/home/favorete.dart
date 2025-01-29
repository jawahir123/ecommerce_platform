import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  List<dynamic> orderHistory = []; // ✅ Store user's order history
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  // ✅ Get stored authentication token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // ✅ Fetch profile data
  Future<void> fetchProfile() async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Authorization token not found');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profileData = data;
          userId = data['id'];
        });

        if (userId != null) {
          fetchUserOrders(userId!);
        }
      } else {
        print("❌ Failed to fetch profile: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ Fetch User Orders
  Future<void> fetchUserOrders(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/order/user/$userId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data['success'] == true && data['orders'] != null) {
          setState(() {
            orderHistory.clear();
            orderHistory.addAll(data['orders']);
          });
          print("✅ Orders Loaded: ${orderHistory.length}");
        } else {
          print("⚠️ No orders found");
        }
      } else {
        print(
            "❌ Failed to fetch orders: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 111, 26, 222),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileData != null
              ? buildProfileContent()
              : const Center(
                  child: Text(
                    "Failed to load profile",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
    );
  }

  // ✅ Build User Profile UI
  Widget buildProfileContent() {
    String fullname = profileData?['fullname'] ?? 'No fullname';
    String email = profileData?['email'] ?? 'No Email';
    String role = profileData?['role'] ?? 'No Role';

    return Column(
      children: [
        const SizedBox(height: 50),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/kabo.png'),
              ),
              const SizedBox(height: 10),
              Text(
                fullname,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ✅ Display Order History
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 209, 203, 203),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: role == 'customer'
                ? buildOrderHistory()
                : const Center(child: Text("No additional content")),
          ),
        ),
      ],
    );
  }

  // ✅ Display Order History without Order ID
  Widget buildOrderHistory() {
    if (orderHistory.isEmpty) {
      return Center(
        child: Text("No orders found."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orderHistory.length,
      itemBuilder: (context, index) {
        final order = orderHistory[index];

        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            leading: Icon(Icons.shopping_cart, color: Colors.blue),
            title: Text(
              "Total Price: \$${order['total_price']}", // ✅ Removed Order ID
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${order['status']}"),
                Text("Date: ${order['createdAt']}"),
              ],
            ),
            children: [
              Column(
                children: List.generate(order['items'].length, (i) {
                  var item = order['items'][i];
                  return ListTile(
                    leading: Icon(Icons.shopping_bag, color: Colors.green),
                    title: Text("${item['product_id']['name']}"),
                    subtitle: Text(
                        "Quantity: ${item['quantity']} - Price: \$${item['price']}"),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
