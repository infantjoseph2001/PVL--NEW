import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:pvl/screens/home_screen.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl/services/network_service.dart';
import 'package:pvl_master/screens/home_screen.dart';
import 'package:pvl_master/services/network_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timer_button/timer_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? otp; // Make otp nullable
  OtpVerificationScreen({this.otp});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool _isSpinnerToShow = false;
  late TextEditingController _otpTC;
  late FocusNode _otpFN;
  String _oneTimePass = '';

  @override
  void initState() {
    super.initState();
    _otpTC = TextEditingController();
    _otpFN = FocusNode();
    if (widget.otp != null) {
      _oneTimePass = widget.otp!;
    }
  }

  @override
  void dispose() {
    _otpTC.dispose();
    _otpFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (context, dataService, child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
          inAsyncCall: _isSpinnerToShow,
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/bgwall.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          color: Colors.white.withOpacity(0.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 50),
                              Center(
                                child: Container(
                                  height: 70,
                                  width: 220,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/logo.png'),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white,
                                        offset: Offset(0, 0),
                                        blurRadius: 15.0,
                                        spreadRadius: 5.0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Mobile Number Verification",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      CustomOtpTF(
                                        controller: _otpTC,
                                        focusNode: _otpFN,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        hint: "Enter Received OTP",
                                        onSubmitted: () {
                                          String otp = _otpTC.text;
                                          if (otp.length == 6) {
                                            if (otp == _oneTimePass) {
                                              int userId = dataService.userId;
                                              String name = dataService.userDetails['name'];
                                              String email = dataService.userDetails['email'];
                                              String mobileNo = dataService.userDetails['mobileNo'];

                                              NetworkService.shared.verifyOtp(
                                                userId: userId,
                                                name: name,
                                                email: email,
                                                phoneNo: mobileNo,
                                                context: context,
                                              );

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => HomeScreen(),
                                                ),
                                              );
                                            } else {
                                              NetworkService.shared.showSnackBar(
                                                "Invalid OTP",
                                                Colors.red,
                                                context,
                                              );
                                            }
                                          } else {
                                            NetworkService.shared.showSnackBar(
                                              "Invalid OTP",
                                              Colors.red,
                                              context,
                                            );
                                          }
                                        },
                                      ),
                                      SizedBox(height: 5),
                                      TimerButton(
                                        label: "RESEND OTP",
                                        timeOutInSeconds: 30,
                                        onPressed: () async {
                                          String mobileNo = dataService.userDetails['mobileNo'];
                                          setState(() => _isSpinnerToShow = true);
                                          ServerResponse response = await NetworkService.shared.loginViaOtp(
                                            mobileNo: mobileNo,
                                            context: context,
                                          );
                                          setState(() => _isSpinnerToShow = false);
                                          if (response.code == 1) {
                                            NetworkService.shared.showSnackBar(
                                              "OTP Sent to the given mobile no.",
                                              Colors.green,
                                              context,
                                            );
                                            setState(() {
                                              _oneTimePass = response.data.toString();
                                            });
                                          } else {
                                            NetworkService.shared.showSnackBar(
                                              response.message,
                                              Colors.red,
                                              context,
                                            );
                                          }
                                        },
                                        disabledColor: Colors.transparent,
                                        color: Colors.transparent,
                                        disabledTextStyle: TextStyle(
                                          fontSize: 13.0,
                                          color: Colors.red,
                                        ),
                                        activeTextStyle: TextStyle(
                                          fontSize: 13.0,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(text: 'By creating an account, you agree to our '),
                                            TextSpan(
                                              text: 'Terms of Service',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "OTP: $_oneTimePass",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              launch("tel://18556611577");
                                            },
                                            child: Container(
                                              height: 80,
                                              width: 200,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 35,
                                                    width: 35,
                                                    child: Image.asset('assets/images/phoneIcon.png'),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Call to Book',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Text(
                                                    '24 hours a day, 7 days a week',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Person Vision Limousine is licensed by the Greater Toronto Airport Authority '
                                    'with rights to operate our vehicles at the airport so that we can deliver best '
                                    'in class services. Pearson Vision Limousine @2015',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
