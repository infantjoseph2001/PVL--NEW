class BookingOption {
  final int id;
  final String name;
  final String fullName;

  BookingOption({
    required this.id,
    required this.name,
    required this.fullName,
  });

  // Factory constructor for creating BookingOption from JSON
  factory BookingOption.fromJson(Map<String, dynamic> json) {
    return BookingOption(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['fullName'] as String,
  }

  // Method to convert BookingOption to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
    };
  }
}
