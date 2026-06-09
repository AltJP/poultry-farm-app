class Chicken {
  final int? id;
  final String name;
  final int quantity;
  final String status;

  Chicken({
    this.id,
    required this.name,
    required this.quantity,
    required this.status,
  });

  // Convert a Chicken object into a Map structure to save it to your SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'status': status,
    };
  }

  // Convert a Map row pulling from your SQLite database back into a usable Chicken object
  factory Chicken.fromMap(Map<String, dynamic> map) {
    return Chicken(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      status: map['status'],
    );
  }
}