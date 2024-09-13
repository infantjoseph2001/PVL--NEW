import 'package:flutter/cupertino.dart';
import 'package:pvl/models/init_detail.dart';
import 'package:pvl/models/order.dart';
import 'package:pvl_master/models/init_detail.dart';
import 'package:pvl_master/models/order.dart';

class DataService extends ChangeNotifier {
  // Private fields with null safety
  bool _isUserLoggedIn = false;
  bool _isKeepSignedIn = false;
  int _userId = 0;
  Map<String, dynamic> _userDetails = {};
  InitDetail? _initDetail;  // Nullable because it might not be set initially
  List<Order> _pastOrders = [];

  // Getters
  bool get isUserLoggedIn => _isUserLoggedIn;
  bool get isKeepSignedIn => _isKeepSignedIn;
  int get userId => _userId;
  Map<String, dynamic> get userDetails => _userDetails;
  InitDetail? get initDetail => _initDetail;
  List<Order> get pastOrders => _pastOrders;

  // Setter for user login status
  void setUserLoggedInStatus(bool newValue) {
    _isUserLoggedIn = newValue;
    notifyListeners();
  }

  // Setter for keep signed in status
  void setKeepSignedInStatus(bool newValue) {
    _isKeepSignedIn = newValue;
    notifyListeners();
  }

  // Setter for user ID
  void setUserId(int newValue) {
    _userId = newValue;
    notifyListeners();
  }

  // Setter for user details
  void setUserDetails(Map<String, dynamic> newValue) {
    _userDetails = newValue;
    debugPrint('Got Stored: $newValue');
    notifyListeners();
  }

  // Setter for init detail
  void setInitDetail({required InitDetail newValue}) {
    _initDetail = newValue;
    notifyListeners(); // Notify listeners since init detail has changed
  }

  // Private fields for opacity status
  bool _onlineBookOpacityStatus = false;
  bool _pickUpAirportOpacityStatus = false;
  bool _pastOrdersOpacityStatus = false;
  bool _callOpacityStatus = false;
  bool _moreInformationOpacityStatus = false;

  // Getters for opacity status
  bool get onlineBookOpacityStatus => _onlineBookOpacityStatus;
  bool get pickUpAirportOpacityStatus => _pickUpAirportOpacityStatus;
  bool get pastOrdersOpacityStatus => _pastOrdersOpacityStatus;
  bool get callOpacityStatus => _callOpacityStatus;
  bool get moreInformationOpacityStatus => _moreInformationOpacityStatus;

  // Set opacity status with delay and notify listeners accordingly
  void setOpacityStatusToZero() {
    _onlineBookOpacityStatus = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 200), () {
      _pickUpAirportOpacityStatus = true;
      notifyListeners();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _pastOrdersOpacityStatus = true;
      notifyListeners();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _callOpacityStatus = true;
      notifyListeners();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _moreInformationOpacityStatus = true;
      notifyListeners();
    });
  }

  // Reset all opacity statuses and notify listeners
  void resetOpacityStatus() {
    _onlineBookOpacityStatus = false;
    _pickUpAirportOpacityStatus = false;
    _pastOrdersOpacityStatus = false;
    _callOpacityStatus = false;
    _moreInformationOpacityStatus = false;
    notifyListeners();
  }

  // Setter for past orders
  void setPastOrders(List<Order> newValue) {
    _pastOrders = newValue;
    notifyListeners();
  }

  // Remove an order from the past orders list by index
  void removeOrderFromPastOrders(int index) {
    if (index >= 0 && index < _pastOrders.length) {
      _pastOrders.removeAt(index);
      notifyListeners();
    }
  }
}
