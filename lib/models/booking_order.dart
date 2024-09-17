class BookingOrder {
  final int bookingOption;
  final String phone;
  final String fullName;
  final String flightInfo;
  final String email;
  final String pickDate;
  final String pickTime;
  final String travelFrom;
  final String travelTo;
  final int carType;
  final String specialRequest;
  final String wakeUp;
  final int paymentType;
  final String corporateAccNo;

  BookingOrder({
    required this.bookingOption,
    required this.phone,
    required this.fullName,
    required this.flightInfo,
    required this.email,
    required this.pickDate,
    required this.pickTime,
    required this.travelFrom,
    required this.travelTo,
    required this.carType,
    required this.specialRequest,
    required this.wakeUp,
    required this.paymentType,
    required this.corporateAccNo,
  });

  // Optional: Factory constructor for creating BookingOrder from JSON
  factory BookingOrder.fromJson(Map<String, dynamic> json) {
    return BookingOrder(
      bookingOption: json['bookingOption'] as int,
      phone: json['phone'] as String,
      fullName: json['fullName'] as String,
      flightInfo: json['flightInfo'] as String,
      email: json['email'] as String,
      pickDate: json['pickDate'] as String,
      pickTime: json['pickTime'] as String,
      travelFrom: json['travelFrom'] as String,
      travelTo: json['travelTo'] as String,
      carType: json['carType'] as int,
      specialRequest: json['specialRequest'] as String,
      wakeUp: json['wakeUp'] as String,
      paymentType: json['paymentType'] as int,
      corporateAccNo: json['corporateAccNo'] as String,
    );
  }

  // Optional: Method to convert BookingOrder to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingOption': bookingOption,
      'phone': phone,
      'fullName': fullName,
      'flightInfo': flightInfo,
      'email': email,
      'pickDate': pickDate,
      'pickTime': pickTime,
      'travelFrom': travelFrom,
      'travelTo': travelTo,
      'carType': carType,
      'specialRequest': specialRequest,
      'wakeUp': wakeUp,
      'paymentType': paymentType,
      'corporateAccNo': corporateAccNo,
    };
  }
}
