class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String image;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.stock,
  });

  // Convert JSON to Product object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      category: json['category']['name'], // Assuming the category is populated
      image: json['image'],
      stock: json['stock'],
    );
  }

  // Convert Product object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'stock': stock,
    };
  }
}
