import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pvl/screens/get_otp_screen.dart';
import 'package:pvl/screens/signin_screen.dart';
import 'package:flutter/services.dart';
import 'package:pvl/services/constants.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl/services/network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitSettings();
    });
  }

  Future<void> _getInitSettings() async {
    final response = await NetworkService.shared.getInitDetails(context: context);

    final prefs = await SharedPreferences.getInstance();
    final isUserLoggedIn = prefs.getBool(kUserLoggedInKey) ?? false;
    final userId = prefs.getInt(kUserIdKey) ?? 0;
    final userDetailsString = prefs.getString(kUserDetailsKey);
    final isKeepSignIn = prefs.getBool(kKeepSignInKey) ?? false;

    print(
        'UserLoggedInStatus: $isUserLoggedIn; UserId: $userId, UserDetails: $userDetailsString; IsKeepSignIn: $isKeepSignIn');

    Provider.of<DataService>(context, listen: false)
        .setUserLoggedInStatus(isUserLoggedIn);

    Provider.of<DataService>(context, listen: false)
        .setKeepSignedInStatus(isKeepSignIn);

    Provider.of<DataService>(context, listen: false)
        .setUserId(userId);

    if (userDetailsString != null) {
      final userDetails = jsonDecode(userDetailsString) as Map<String, dynamic>;

      final name = userDetails['name'] ?? '';
      final email = userDetails['email'] ?? '';
      final phone = userDetails['mobileNo'] ?? '';

      final userDetailsMap = {
        'name': name,
        'email': email,
        'mobileNo': phone
      };

      Provider.of<DataService>(context, listen: false)
          .setUserDetails(userDetailsMap);
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => GetOtpScreen(),
        settings: RouteSettings(name: 'GetOtpScreen'),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.black),
    );
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgwall.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            height: 70,
            width: 220,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(0, 0),
                  blurRadius: 15.0,
                  spreadRadius: 5.0,
                ),
              ],
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
