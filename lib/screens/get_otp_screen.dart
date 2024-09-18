import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:pvl/screens/home_screen.dart';
import 'package:pvl/screens/otp_verification_screen.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl/services/network_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GetOtpScreen extends StatefulWidget {
  @override
  _GetOtpScreenState createState() => _GetOtpScreenState();
}

class _GetOtpScreenState extends State<GetOtpScreen> {
  bool _isSpinnerToShow = false;
  final TextEditingController _mobileTC = TextEditingController();
  final FocusNode _mobileFN = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isUserLoggedIn = Provider.of<DataService>(context, listen: false).isUserLoggedIn;

      if (isUserLoggedIn) {
        Provider.of<DataService>(context, listen: false).resetOpacityStatus();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (cxt) => HomeScreen(),
            settings: RouteSettings(name: 'HomeScreen'),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mobileTC.dispose();
    _mobileFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (cxt, dataService, child) {
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
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.0),
                          ),
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
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Pearson Vision Limousine Welcomes you!!!",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          CustomOtpTF(
                                            controller: _mobileTC,
                                            focusNode: _mobileFN,
                                            keyboardType: TextInputType.phone,
                                            inputAction: TextInputAction.done,
                                            hint: "Enter your mobile no.",
                                            onSubmitted: () async {
                                              FocusScope.of(context).unfocus();
                                              dataService.resetOpacityStatus();
                                              String mobileNo = _mobileTC.text;
                                              if (mobileNo.length == 10) {
                                                setState(() => _isSpinnerToShow = true);
                                                ServerResponse response = await NetworkService.shared
                                                    .loginViaOtp(mobileNo: mobileNo, context: context);
                                                setState(() => _isSpinnerToShow = false);
                                                if (response.code == 1) {
                                                  int otp = response.data;
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext otpVerificationCxt) {
                                                        return OtpVerificationScreen(
                                                          otp: otp.toString(),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                } else {
                                                  NetworkService.shared.showSnackBar(
                                                    response.message,
                                                    Colors.red,
                                                    context,
                                                  );
                                                }
                                              } else {
                                                NetworkService.shared.showSnackBar(
                                                  'Invalid Mobile Number',
                                                  Colors.red,
                                                  context,
                                                );
                                              }
                                            },
                                          ),
                                          SizedBox(height: 20),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "By continuing you may receive an SMS for verification",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            height: 80,
                                            width: 200,
                                            child: GestureDetector(
                                              onTap: () => launch("tel://18556611577"),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset('assets/images/phoneIcon.png', height: 35, width: 35),
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 60,
                                child: Center(
                                  child: Text(
                                    'Pearson Vision Limousine is licensed by the Greater Toronto Airport Authority '
                                        'with rights to operate our vehicles at the airport so that we can deliver the best '
                                        'in class services. Pearson Vision Limousine @2015',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (dataService.isUserLoggedIn)
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bgwall.png'),
                        fit: BoxFit.cover,
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

class CustomOtpTF extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextInputAction inputAction;
  final String hint;
  final VoidCallback onSubmitted;

  CustomOtpTF({
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.inputAction,
    required this.hint,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(color: Colors.black, fontSize: 18),
        keyboardType: keyboardType,
        textInputAction: inputAction,
        cursorColor: Colors.teal,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.arrow_forward, size: 30, color: Colors.red),
            onPressed: onSubmitted,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        ),
        onSubmitted: (_) => onSubmitted(),
      ),
    );
  }
}
