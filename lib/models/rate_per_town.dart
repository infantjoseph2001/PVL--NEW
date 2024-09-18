class RatePerTown {
  final String name;
  final String amount;

  RatePerTown({
    required this.name,
    required this.amount,
  });

  // Factory constructor for creating RatePerTown from JSON
  factory RatePerTown.fromJson(Map<String, dynamic> json) {
    return RatePerTown(
      name: json['name'] as String,
      amount: json['amount'] as String,
    );
  }

  // Method to convert RatePerTown to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}
