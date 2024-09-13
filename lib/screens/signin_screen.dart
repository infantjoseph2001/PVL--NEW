import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:pvl/screens/change_password_screen.dart';
import 'package:pvl/screens/home_screen.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl/services/network_service.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

const double width = 200.0;
const double signInAlign = -1;
const double signUpAlign = -0.3;
const Color selectedColor = Colors.white;
const Color normalColor = Colors.grey;

class _SignInScreenState extends State<SignInScreen> {
  double xAlign = signInAlign;
  Color signInColor = selectedColor;
  Color signUpColor = normalColor;
  bool selectedValue = true;
  String buttonTitle = 'SIGN IN';
  Color buttonColor = Colors.red;
  bool checkedValue = true;
  bool _isSpinnerToShow = false;
  String _errorMsg = '';

  final TextEditingController _fullNameTc = TextEditingController();
  final TextEditingController _emailTc = TextEditingController();
  final TextEditingController _phoneTc = TextEditingController();
  final TextEditingController _passwordTc = TextEditingController();

  final FocusNode _emailFn = FocusNode();
  final FocusNode _fullNameFn = FocusNode();
  final FocusNode _phoneFn = FocusNode();
  final FocusNode _passwordFn = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataService = Provider.of<DataService>(context, listen: false);
      if (dataService.isUserLoggedIn && dataService.isKeepSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fullNameTc.dispose();
    _emailTc.dispose();
    _phoneTc.dispose();
    _passwordTc.dispose();
    _fullNameFn.dispose();
    _emailFn.dispose();
    _phoneFn.dispose();
    _passwordFn.dispose();
    super.dispose();
  }

  bool _validateEmail(String value) {
    final regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    return regex.hasMatch(value);
  }

  bool _validateToRegister() {
    bool isValid = true;
    _errorMsg = '';

    if (_passwordTc.text.length <= 5) {
      _errorMsg = 'Password length must be minimum 6';
      isValid = false;
    }

    if (_phoneTc.text.length != 10) {
      _errorMsg = "Invalid phone number";
      isValid = false;
    }

    if (!_validateEmail(_emailTc.text)) {
      _errorMsg = 'Invalid email address';
      isValid = false;
    }

    if (_fullNameTc.text.length <= 2) {
      _errorMsg = 'Please fill valid full name';
      isValid = false;
    }

    return isValid;
  }

  bool _validateToLogin() {
    bool isValid = true;
    _errorMsg = '';

    if (_passwordTc.text.length <= 5) {
      _errorMsg = 'Password length must be minimum 6';
      isValid = false;
    }

    if (!_validateEmail(_emailTc.text)) {
      _errorMsg = 'Invalid email address';
      isValid = false;
    }

    return isValid;
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
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/bgwall.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Stack(
                                      children: [
                                        AnimatedAlign(
                                          alignment: Alignment(xAlign, 0.3),
                                          duration: Duration(milliseconds: 300),
                                          child: Container(
                                            color: Colors.red,
                                            width: width * 0.5,
                                            height: 2,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              xAlign = signInAlign;
                                              signInColor = selectedColor;
                                              signUpColor = normalColor;
                                              buttonColor = Colors.red;
                                              buttonTitle = 'SIGN IN';
                                            });
                                          },
                                          child: Align(
                                            alignment: Alignment(-1, 0),
                                            child: Container(
                                              width: width * 0.5,
                                              alignment: Alignment.center,
                                              child: Text(
                                                'SIGN IN',
                                                style: TextStyle(
                                                  color: signInColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              xAlign = signUpAlign;
                                              signUpColor = selectedColor;
                                              signInColor = normalColor;
                                              buttonColor = Colors.blue;
                                              buttonTitle = 'SIGN UP';
                                            });
                                          },
                                          child: Align(
                                            alignment: Alignment(-0.3, 0),
                                            child: Container(
                                              width: width * 0.5,
                                              alignment: Alignment.center,
                                              child: Text(
                                                'SIGN UP',
                                                style: TextStyle(
                                                  color: signUpColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  child: Padding(
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
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (buttonTitle == 'SIGN UP')
                                          SignInTF(
                                            title: 'FULL NAME',
                                            controller: _fullNameTc,
                                            focusNode: _fullNameFn,
                                            keyboardType: TextInputType.text,
                                            capitalization: TextCapitalization.words,
                                            inputAction: TextInputAction.next,
                                            hint: 'Full Name',
                                          ),
                                        SizedBox(height: 10),
                                        SignInTF(
                                          title: 'EMAIL',
                                          controller: _emailTc,
                                          focusNode: _emailFn,
                                          keyboardType: TextInputType.emailAddress,
                                          capitalization: TextCapitalization.none,
                                          inputAction: TextInputAction.next,
                                          hint: 'Email',
                                          onSubmitted: (value) {
                                            FocusScope.of(context).nextFocus();
                                          },
                                        ),
                                        SizedBox(height: 10),
                                        if (buttonTitle == 'SIGN UP')
                                          SignInTF(
                                            title: 'PHONE NO',
                                            controller: _phoneTc,
                                            focusNode: _phoneFn,
                                            keyboardType: TextInputType.phone,
                                            capitalization: TextCapitalization.none,
                                            inputAction: TextInputAction.next,
                                            hint: 'Phone No',
                                          ),
                                        SizedBox(height: 10),
                                        Text(
                                          'PASSWORD',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: TextField(
                                            controller: _passwordTc,
                                            focusNode: _passwordFn,
                                            obscureText: true,
                                            style: TextStyle(color: Colors.white70),
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.done,
                                            cursorColor: Colors.teal,
                                            decoration: InputDecoration(
                                              hintText: 'Password',
                                              hintStyle: TextStyle(color: Colors.white70),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        if (buttonTitle == 'SIGN IN')
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Theme(
                                                  data: ThemeData(unselectedWidgetColor: Colors.teal),
                                                  child: CheckboxListTile(
                                                    title: Text(
                                                      "Keep Me Signed In",
                                                      style: TextStyle(fontSize: 12, color: Colors.white),
                                                    ),
                                                    value: checkedValue,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        checkedValue = newValue ?? false;
                                                      });
                                                    },
                                                    controlAffinity: ListTileControlAffinity.leading,
                                                    checkColor: Colors.black,
                                                    activeColor: Colors.teal,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  final email = _emailTc.text;
                                                  if (_validateEmail(email)) {
                                                    setState(() => _isSpinnerToShow = true);
                                                    final response = await NetworkService.shared.forgetPassword(email: email);
                                                    setState(() => _isSpinnerToShow = false);
                                                    if (response.code == 1) {
                                                      Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (context) => ChangePasswordScreen(
                                                            otp: response.data.toString(),
                                                            email: email,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      NetworkService.shared.showSnackBar(response.message, Colors.red, context);
                                                    }
                                                  } else {
                                                    NetworkService.shared.showSnackBar('Please provide valid email', Colors.red, context);
                                                  }
                                                },
                                                child: Text(
                                                  'Forgot Password?',
                                                  style: TextStyle(fontSize: 12, color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        SizedBox(height: 20),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 25),
                                          child: InkWell(
                                            onTap: () async {
                                              if (buttonTitle == 'SIGN UP') {
                                                if (_validateToRegister()) {
                                                  setState(() => _isSpinnerToShow = true);
                                                  final response = await NetworkService.shared.register(
                                                    fullName: _fullNameTc.text,
                                                    email: _emailTc.text,
                                                    phone: _phoneTc.text,
                                                    password: _passwordTc.text,
                                                    isKeepSignedIn: checkedValue,
                                                    context: context,
                                                  );
                                                  setState(() => _isSpinnerToShow = false);
                                                  if (response.code == 1) {
                                                    dataService.resetOpacityStatus();
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => HomeScreen()),
                                                    );
                                                  } else {
                                                    NetworkService.shared.showSnackBar(response.message, Colors.red, context);
                                                  }
                                                } else {
                                                  NetworkService.shared.showSnackBar(_errorMsg, Colors.red, context);
                                                }
                                              } else {
                                                if (_validateToLogin()) {
                                                  setState(() => _isSpinnerToShow = true);
                                                  final response = await NetworkService.shared.login(
                                                    email: _emailTc.text,
                                                    password: _passwordTc.text,
                                                    isKeepSignedIn: checkedValue,
                                                    context: context,
                                                  );
                                                  setState(() => _isSpinnerToShow = false);
                                                  if (response.code == 1) {
                                                    dataService.resetOpacityStatus();
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => HomeScreen()),
                                                    );
                                                  } else {
                                                    NetworkService.shared.showSnackBar(response.message, Colors.red, context);
                                                  }
                                                } else {
                                                  NetworkService.shared.showSnackBar(_errorMsg, Colors.red, context);
                                                }
                                              }
                                            },
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: buttonColor,
                                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  buttonTitle,
                                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          height: 60,
                                          child: Center(
                                            child: Text(
                                              'Person Vision Limousine is licensed by the Greater Toronto Airport Authority '
                                                  'with rights to operate our vehicles at the airport so that we can deliver best '
                                                  'in class services. Pearson Vision Limousine @2015',
                                              style: TextStyle(color: Colors.grey, fontSize: 13),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (dataService.isUserLoggedIn && dataService.isKeepSignedIn)
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
      },
    );
  }
}

class SignInTF extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextCapitalization capitalization;
  final TextInputAction inputAction;
  final String hint;
  final Function(String) onSubmitted;

  const SignInTF({
    Key? key,
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.capitalization,
    required this.inputAction,
    required this.hint,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        SizedBox(height: 5),
        Container(
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: onSubmitted,
            style: TextStyle(color: Colors.white70),
            keyboardType: keyboardType,
            textCapitalization: capitalization,
            textInputAction: inputAction,
            cursorColor: Colors.teal,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            ),
          ),
        ),
      ],
    );
  }
}
