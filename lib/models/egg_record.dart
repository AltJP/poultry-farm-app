class EggRecord {
  final int? id;
  final String date;
  final int quantity;
  final String status;

  EggRecord({
    this.id,
    required this.date,
    required this.quantity,
    required this.status,
  });

  // Convert an Egg Record object into a Map to save to your SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'quantity': quantity,
      'status': status,
    };
  }

  // Convert a Map from SQLite back into a clean Egg Record object
  factory EggRecord.fromMap(Map<String, dynamic> map) {
    return EggRecord(
      id: map['id'],
      date: map['date'],
      quantity: map['quantity'],
      status: map['status'],
    );
  }
}