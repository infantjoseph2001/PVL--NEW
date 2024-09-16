import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pvl/models/booking_order.dart';
import 'package:pvl/models/init_detail.dart';
import 'package:pvl/models/order.dart';
import 'package:pvl/services/constants.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl_master/services/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';

class ServerResponse {
  final int code;
  final String message;
  final dynamic data;

  ServerResponse({required this.code, required this.message, this.data});
}

class NetworkService {
  static final NetworkService shared = NetworkService();

  Future<void> storeLoginStatus(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kUserLoggedInKey, newValue);
  }

  Future<void> storeUserId(int newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kUserIdKey, newValue);
  }

  Future<void> storeKeepLoginStatus(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kKeepSignInKey, newValue);
  }

  Future<void> storeUserDetails(Map<String, String> userDetails) async {
    final prefs = await SharedPreferences.getInstance();
    final userDetailsStr = jsonEncode(userDetails);
    await prefs.setString(kUserDetailsKey, userDetailsStr);
  }

  void showSnackBar(String text, Color bgColor, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: bgColor,
      ),
    );
  }

  String changeDateFormat(String serverDate) {
    final reqDate = serverDate
        .replaceAll(RegExp(r'[-:]'), '')
        .replaceAll('T', '');
    final dateWithT = reqDate.substring(0, 8) + 'T' + reqDate.substring(8);
    final dateTime = DateTime.parse(dateWithT);
    return formatDate(dateTime, [MM, dd, ', ', yyyy, ', ', hh, ':', nn, am]);
  }

  Future<ServerResponse> getInitDetails(BuildContext context) async {
    try {
      final url = Uri.parse(kUrlToGetInit);
      final response = await http.post(url, headers: kHeader);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final responseCode = jsonData['Code'];
        final responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          final responseData = jsonData['Data'];
          final googleApiKey = responseData['google_map_key'] ?? '';
          final upgradeFlag = responseData['upgrade'];

          final initDetail = InitDetail(
            googleApiKey: googleApiKey,
            upgradeFlag: upgradeFlag,
          );
          Provider.of<DataService>(context, listen: false)
              .setInitDetail(initDetail);

          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        } else {
          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        }
      } else {
        final message = jsonData['Message'];
        return ServerResponse(
          code: 0,
          message: message,
          data: null,
        );
      }
    } catch (e) {
      return ServerResponse(
        code: 0,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ServerResponse> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required bool isKeepSignedIn,
    required BuildContext context,
  }) async {
    try {
      final params = {
        'fullname': fullName,
        'email': email,
        'phone_no': phone,
        'password': password,
      };
      final body = jsonEncode(params);
      final url = Uri.parse(kUrlToRegister);
      final response = await http.post(url, headers: kHeader, body: body);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final responseCode = jsonData['Code'];
        final responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          final responseData = jsonData['Data'];
          final userId = responseData['Id'] ?? 0;
          final fullName = responseData['FirstName'] ?? '';
          final phoneNo = responseData['Phone'] ?? '';

          await storeUserId(userId);
          await storeLoginStatus(true);
          await storeKeepLoginStatus(isKeepSignedIn);
          await storeUserDetails({
            'name': fullName,
            'email': email,
            'mobileNo': phoneNo,
          });

          final dataService = Provider.of<DataService>(context, listen: false);
          dataService.setUserId(userId);
          dataService.setUserLoggedInStatus(true);
          dataService.setKeepSignedInStatus(isKeepSignedIn);
          dataService.setUserDetails({
            'name': fullName,
            'email': email,
            'mobileNo': phoneNo,
          });

          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        } else {
          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        }
      } else {
        final message = jsonData['Message'];
        return ServerResponse(
          code: 0,
          message: message,
          data: null,
        );
      }
    } catch (e) {
      return ServerResponse(
        code: 0,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ServerResponse> login({
    required String email,
    required String password,
    required bool isKeepSignedIn,
    required BuildContext context,
  }) async {
    try {
      final params = {
        'email': email,
        'password': password,
      };
      final body = jsonEncode(params);
      final url = Uri.parse(kUrlToLogin);
      final response = await http.post(url, headers: kHeader, body: body);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final responseCode = jsonData['Code'];
        final responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          final responseData = jsonData['Data'];
          final userId = responseData['Id'] ?? 0;
          final fullName = responseData['FirstName'] ?? '';
          final phoneNo = responseData['Phone'] ?? '';

          await storeUserId(userId);
          await storeLoginStatus(true);
          await storeKeepLoginStatus(isKeepSignedIn);
          await storeUserDetails({
            'name': fullName,
            'email': email,
            'mobileNo': phoneNo,
          });

          final dataService = Provider.of<DataService>(context, listen: false);
          dataService.setUserId(userId);
          dataService.setUserLoggedInStatus(true);
          dataService.setKeepSignedInStatus(isKeepSignedIn);
          dataService.setUserDetails({
            'name': fullName,
            'email': email,
            'mobileNo': phoneNo,
          });

          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        } else {
          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        }
      } else {
        final message = jsonData['Message'];
        return ServerResponse(
          code: 0,
          message: message,
          data: null,
        );
      }
    } catch (e) {
      return ServerResponse(
        code: 0,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ServerResponse> getHistory(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(kUserIdKey);
      final params = {'user_id': userId};
      final body = jsonEncode(params);
      final url = Uri.parse(kUrlToGetPastOrders);
      final response = await http.post(url, headers: kHeader, body: body);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final responseCode = jsonData['Code'];
        final responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          final responseData = jsonData['Data'];
          final pastOrders = responseData.map<Order>((rD) {
            final orderId = rD['Id'];
            final fullName = rD['FirstName'] ?? '';
            final email = rD['Email'] ?? '';
            final phoneNo = rD['Phone'] ?? '';
            final travelFrom = rD['TravelFrom'] ?? '';
            final travelTo = rD['TravelTo'] ?? '';
            final taxiType = rD['TaxiType'] ?? 0;
            final travelTimeServer = rD['FullOrderDate'] ?? '';
            final travelDate = travelTimeServer.isNotEmpty
                ? changeDateFormat(travelTimeServer)
                : '';
            final totalFare = rD['TotalFare'];
            final paymentType = rD['PaymentType'];
            final paymentStatus = rD['PaymentStatus'];
            final flightInfo = rD['AddNotes'] ?? '';
            final specialInstruction = rD['MoreInfo'] ?? '';
            final orderStatusFlag = rD['flg'];

            return Order(
              id: orderId,
              fullName: fullName,
              email: email,
              phoneNo: phoneNo,
              travelFrom: travelFrom,
              travelTo: travelTo,
              taxiType: taxiType,
              travelDateTime: travelDate,
              totalFare: totalFare,
              paymentType: paymentType,
              paymentStatus: paymentStatus,
              flightInfo: flightInfo,
              specialInstruction: specialInstruction,
              statusFlag: orderStatusFlag,
            );
          }).toList();

          Provider.of<DataService>(context, listen: false)
              .setPastOrders(pastOrders);

          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        } else {
          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        }
      } else {
        final message = jsonData['Message'];
        return ServerResponse(
          code: 0,
          message: message,
          data: null,
        );
      }
    } catch (e) {
      return ServerResponse(
        code: 0,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ServerResponse> forgetPassword(String email) async {
    try {
      final params = {'email': email};
      final body = jsonEncode(params);
      final url = Uri.parse(kUrlToForgetPassword);
      final response = await http.post(url, headers: kHeader, body: body);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final responseCode = jsonData['Code'];
        final responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          final otp = jsonData['Data'];
          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: otp,
          );
        } else {
          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        }
      } else {
        final message = jsonData['Message'];
        return ServerResponse(
          code: 0,
          message: message,
          data: null,
        );
      }
    } catch (e) {
      return ServerResponse(
        code: 0,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ServerResponse> changePassword(String email, String password) async {
    try {
      final params = {
        'email': email,
        'password': password,
      };
      final body = jsonEncode(params);
      final url = Uri.parse(kUrlToChangePassword);
      final response = await http.post(url, headers: kHeader, body: body);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final responseCode = jsonData['Code'];
        final responseMessage = jsonData['Message'];
        return ServerResponse(
          code: responseCode,
          message: responseMessage,
          data: null,
        );
      } else {
        final message = jsonData['Message'];
        return ServerResponse(
          code: 0,
          message: message,
          data: null,
        );
      }
    } catch (e) {
      return ServerResponse(
        code: 0,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ServerResponse> cancelOrder({
    required int orderId,
    required BuildContext context,
  }) async {
    try {
      final params = {'order_id': orderId};
      final body = jsonEncode(params);
      final url = Uri.parse(kUrlToCancelTheOrder);
      final response = await http.post(url, headers: kHeader, body: body);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final responseCode = jsonData['Code'];
        final responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          final responseData = jsonData['Data'];
          final pastOrders = responseData.map<Order>((rD) {
            final orderId = rD['Id'];
            final fullName = rD['FirstName'] ?? '';
            final email = rD['Email'] ?? '';
            final phoneNo = rD['Phone'] ?? '';
            final travelFrom = rD['TravelFrom'] ?? '';
            final travelTo = rD['TravelTo'] ?? '';
            final taxiType = rD['TaxiType'] ?? 0;
            final travelTimeServer = rD['FullOrderDate'] ?? '';
            final travelDate = travelTimeServer.isNotEmpty
                ? changeDateFormat(travelTimeServer)
                : '';
            final totalFare = rD['TotalFare'];
            final paymentType = rD['PaymentType'];
            final paymentStatus = rD['PaymentStatus'];
            final flightInfo = rD['AddNotes'] ?? '';
            final specialInstruction = rD['MoreInfo'] ?? '';
            final orderStatusFlag = rD['flg'];

            return Order(
              id: orderId,
              fullName: fullName,
              email: email,
              phoneNo: phoneNo,
              travelFrom: travelFrom,
              travelTo: travelTo,
              taxiType: taxiType,
              travelDateTime: travelDate,
              totalFare: totalFare,
              paymentType: paymentType,
              paymentStatus: paymentStatus,
              flightInfo: flightInfo,
              specialInstruction: specialInstruction,
              statusFlag: orderStatusFlag,
            );
          }).toList();

          Provider.of<DataService>(context, listen: false)
              .setPastOrders(pastOrders);

          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        } else {
          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        }
      } else {
        final message = jsonData['Message'];
        return ServerResponse(
          code: 0,
          message: message,
          data: null,
        );
      }
    } catch (e) {
      return ServerResponse(
        code: 0,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ServerResponse> removeOrder({
    required int orderId,
    required int index,
    required BuildContext context,
  }) async {
    try {
      final params = {'order_id': orderId};
      final body = jsonEncode(params);
      final url = Uri.parse(kUrlToRemoveOrderFromHistory);
      final response = await http.post(url, headers: kHeader, body: body);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final responseCode = jsonData['Code'];
        final responseMessage = jsonData['Message'];

        if (responseCode == 1) {
          Provider.of<DataService>(context, listen: false)
              .removeOrderFromPastOrders(index: index);

          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        } else {
          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        }
      } else {
        final message = jsonData['Message'];
        return ServerResponse(
          code: 0,
          message: message,
          data: null,
        );
      }
    } catch (e) {
      return ServerResponse(
        code: 0,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ServerResponse> loginViaOtp({
    required String mobileNo,
    required BuildContext context,
  }) async {
    try {
      final params = {
        'phoneno': mobileNo,
        'password': '',
      };
      final body = jsonEncode(params);
      final url = Uri.parse(kUrlToLoginViaOtp);
      final response = await http.post(url, headers: kHeader, body: body);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final responseCode = jsonData['ResponseCode'];
        final responseMessage = jsonData['ResponseMessage'];

        if (responseCode == 1) {
          final otp = jsonData['OTP'];
          final responseData = jsonData['ResponseData'];
          final userId = responseData['Id'] ?? 0;
          final fName = responseData['FirstName'] ?? '';
          final fullName = fName == 'Guest' ? '' : fName;
          final phoneNo = responseData['Phone'] ?? '';
          final email = responseData['Email']?.contains('pearsonvision') == true ? '' : responseData['Email'] ?? '';

          await storeUserId(userId);
          await storeLoginStatus(true);
          await storeKeepLoginStatus(true);
          await storeUserDetails({
            'name': fullName,
            'email': email,
            'mobileNo': phoneNo,
          });

          final dataService = Provider.of<DataService>(context, listen: false);
          dataService.setUserId(userId);
          dataService.setUserLoggedInStatus(true);
          dataService.setKeepSignedInStatus(true);
          dataService.setUserDetails({
            'name': fullName,
            'email': email,
            'mobileNo': phoneNo,
          });

          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: otp,
          );
        } else {
          return ServerResponse(
            code: responseCode,
            message: responseMessage,
            data: null,
          );
        }
      } else {
        final message = jsonData['Message'];
        return ServerResponse(
          code: 0,
          message: message,
          data: null,
        );
      }
    } catch (e) {
      return ServerResponse(
        code: 0,
        message: e.toString(),
        data: null,
      );
    }
  }

  void verifyOtp({
    required int userId,
    required String name,
    required String email,
    required String phoneNo,
    required BuildContext context,
  }) {
    storeUserId(userId);
    storeLoginStatus(true);
    storeKeepLoginStatus(true);

    final userDetails = {
      'name': name,
      'email': email,
      'mobileNo': phoneNo,
    };
    storeUserDetails(userDetails);

    final dataService = Provider.of<DataService>(context, listen: false);
    dataService.setUserId(userId);
    dataService.setUserLoggedInStatus(true);
    dataService.setKeepSignedInStatus(true);
    dataService.setUserDetails(userDetails);
  }
}
