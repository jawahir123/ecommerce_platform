import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/screens/auth/login.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/screens/home/homeScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ecommerce App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      initialBinding: BindingsBuilder(() {
        Get.put(CartController()); // Initialize CartController
      }),
    );
  }
}
