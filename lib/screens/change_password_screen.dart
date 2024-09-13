import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:pvl/screens/signin_screen.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl/services/network_service.dart';

import '../services/network_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String otp;
  final String email;

  const ChangePasswordScreen({Key? key, required this.otp, required this.email}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isSpinnerToShow = false;
  final TextEditingController _emailTc = TextEditingController();
  final TextEditingController _passwordTc = TextEditingController();
  final TextEditingController _otpTc = TextEditingController();
  final FocusNode _emailFn = FocusNode();
  final FocusNode _passwordFn = FocusNode();
  final FocusNode _otpFn = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailTc.text = widget.email;
  }

  @override
  void dispose() {
    _emailTc.dispose();
    _passwordTc.dispose();
    _otpTc.dispose();
    _emailFn.dispose();
    _passwordFn.dispose();
    _otpFn.dispose();
    super.dispose();
  }

  bool validateEmail(String value) {
    final pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final regex = RegExp(pattern);
    return regex.hasMatch(value);
  }

  Future<void> _changePassword() async {
    final email = _emailTc.text;
    if (!validateEmail(email)) {
      NetworkService.shared.showSnackBar('Please provide a valid email', Colors.red, context);
      return;
    }

    final password = _passwordTc.text;
    if (password.length < 6) {
      NetworkService.shared.showSnackBar('Password length must be minimum 6 characters', Colors.red, context);
      return;
    }

    final otp = _otpTc.text;
    if (otp != widget.otp) {
      NetworkService.shared.showSnackBar('Provided OTP does not match the one sent to the email', Colors.red, context);
      return;
    }

    setState(() => _isSpinnerToShow = true);

    final response = await NetworkService.shared.changePassword(email: email, password: password);

    setState(() => _isSpinnerToShow = false);

    if (response.code == 1) {
      NetworkService.shared.showSnackBar(response.message, Colors.green, context);
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pop();
    } else {
      NetworkService.shared.showSnackBar(response.message, Colors.red, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: ModalProgressHUD(
            inAsyncCall: _isSpinnerToShow,
            child: SafeArea(
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Container(
                    height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bgwall.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          color: Colors.white70,
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  'CHANGE PASSWORD',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back, size: 25),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Center(
                            child: Text(
                              'PEARSON VISION LIMOUSINE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 26,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SignInTF(
                                  title: 'EMAIL',
                                  controller: _emailTc,
                                  focusNode: _emailFn,
                                  keyBoardType: TextInputType.emailAddress,
                                  capitalization: TextCapitalization.none,
                                  inputAction: TextInputAction.next,
                                  hint: "Email",
                                ),
                                SizedBox(height: 10),
                                SignInTF(
                                  title: 'PASSWORD',
                                  controller: _passwordTc,
                                  focusNode: _passwordFn,
                                  keyBoardType: TextInputType.text,
                                  capitalization: TextCapitalization.none,
                                  inputAction: TextInputAction.next,
                                  hint: "Password",
                                ),
                                SizedBox(height: 10),
                                SignInTF(
                                  title: 'OTP',
                                  controller: _otpTc,
                                  focusNode: _otpFn,
                                  keyBoardType: TextInputType.number,
                                  capitalization: TextCapitalization.none,
                                  inputAction: TextInputAction.done,
                                  hint: "Provide OTP sent to the email",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: InkWell(
                            onTap: _changePassword,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Center(
                                child: Text(
                                  'CHANGE PASSWORD',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
