class Order {
  final int id;
  final String fullName;
  final String email;
  final String phoneNo;
  final String travelFrom;
  final String travelTo;
  final int taxiType;
  final String travelDateTime;
  final double totalFare;
  final String paymentType;
  final int paymentStatus;
  final String flightInfo;
  final String specialInstruction;
  final int statusFlag;

  Order({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNo,
    required this.travelFrom,
    required this.travelTo,
    required this.taxiType,
    required this.travelDateTime,
    required this.totalFare,
    required this.paymentType,
    required this.paymentStatus,
    required this.flightInfo,
    required this.specialInstruction,
    required this.statusFlag,
  });

  // Method to get the car name based on taxiType
  String carName() {
    switch (taxiType) {
      case 1:
        return 'SEDAN';
      case 2:
        return 'SUV';
      default:
        return 'VAN';
    }
  }

  // Optional: Factory constructor for creating an Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNo: json['phoneNo'] as String,
      travelFrom: json['travelFrom'] as String,
      travelTo: json['travelTo'] as String,
      taxiType: json['taxiType'] as int,
      travelDateTime: json['travelDateTime'] as String,
      totalFare: (json['totalFare'] as num).toDouble(),
      paymentType: json['paymentType'] as String,
      paymentStatus: json['paymentStatus'] as int,
      flightInfo: json['flightInfo'] as String,
      specialInstruction: json['specialInstruction'] as String,
      statusFlag: json['statusFlag'] as int,
    );
  }

  // Optional: Method to convert an Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNo': phoneNo,
      'travelFrom': travelFrom,
      'travelTo': travelTo,
      'taxiType': taxiType,
      'travelDateTime': travelDateTime,
      'totalFare': totalFare,
      'paymentType': paymentType,
      'paymentStatus': paymentStatus,
      'flightInfo': flightInfo,
      'specialInstruction': specialInstruction,
      'statusFlag': statusFlag,
    };
  }
}
