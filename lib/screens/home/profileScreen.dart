import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For API calls
import 'package:shared_preferences/shared_preferences.dart'; // For storing and retrieving the token

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData; // To store user/admin profile data
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchProfile(); // Fetch profile on screen load
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> fetchProfile() async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Authorization token not found');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Parse response data
        setState(() {
          profileData = jsonDecode(response.body); // Update profileData
          isLoading = false; // Set loading to false
        });
        print("Profile fetched successfully: $profileData");
      } else {
        setState(() {
          isLoading = false; // Stop loading even if profile fetch fails
        });
        print("Failed to fetch profile: ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading if error occurs
      });
      print("Error fetching profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 111, 26, 222),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader
          : profileData != null
              ? buildProfileContent() // Build profile content if data exists
              : const Center(
                  child: Text(
                    "Failed to load profile",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
    );
  }

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
                backgroundImage: AssetImage(
                    'assets/images/kabo.png'), // Replace with user's profile image
              ),
              const SizedBox(height: 10),
              Text(
                fullname, // User's name
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                email, // User's email
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                "Role: $role", // User's role
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Edit Profile
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Show dynamic content based on role
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 209, 203, 203),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: role == 'user'
                ? buildUserContent()
                : role == 'admin'
                    ? buildAdminContent()
                    : const Center(
                        child: Text("No additional content"),
                      ),
          ),
        ),
      ],
    );
  }

  Widget buildUserContent() {
    List<dynamic> orders = profileData?['additionalInfo']['orders'] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          leading: const Icon(Icons.shopping_bag,
              color: Color.fromARGB(255, 165, 36, 188)),
          title: Text(
            order['orderId'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(order['status']),
          trailing: Text(
            "\$${order['amount']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget buildAdminContent() {
    List<dynamic> businesses =
        profileData?['additionalInfo']['managedBusinesses'] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        final business = businesses[index];
        return ListTile(
          leading: const Icon(Icons.business,
              color: Color.fromARGB(255, 165, 36, 188)),
          title: Text(
            business['name'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text("License: ${business['license']}"),
        );
      },
    );
  }
}
