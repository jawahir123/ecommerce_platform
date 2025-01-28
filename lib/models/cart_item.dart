class CartItem {
  final String id; // Unique identifier for the cart item
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id, // Add required id field
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}
