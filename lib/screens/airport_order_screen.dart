import 'package:flutter/material.dart';
import 'package:flutter_picker_view/picker_view.dart';
import 'package:flutter_picker_view/picker_view_popup.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:pvl/models/booking_order.dart';
import 'package:pvl/screens/online_booking_screen.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl/services/network_service.dart';
import 'package:pvl_master/services/data_service.dart';
import 'package:pvl_master/services/network_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class AirportOrderScreen extends StatefulWidget {
  @override
  _AirportOrderScreenState createState() => _AirportOrderScreenState();
}

class _AirportOrderScreenState extends State<AirportOrderScreen> {
  final TextEditingController _fullNameTc = TextEditingController();
  final TextEditingController _emailTc = TextEditingController();
  final TextEditingController _airportTerminalTc = TextEditingController();
  final TextEditingController _flightInfoTc = TextEditingController();
  final FocusNode _fullNameFn = FocusNode();
  final FocusNode _emailFn = FocusNode();
  final FocusNode _airportTerminalFn = FocusNode();
  final FocusNode _flightInfoFn = FocusNode();

  bool _isSpinnerToShow = false;

  final List<String> _terminalOptions = [
    'Terminal 3 - Toronto Pearson Airport',
    'Terminal 1 - Toronto Pearson Airport'
  ];

  bool validateEmail(String value) {
    final pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final regex = RegExp(pattern);
    return regex.hasMatch(value);
  }

  void _showTerminalOptionPicker({
    required List<String> items,
    required String title,
  }) {
    final PickerController pickerController =
    PickerController(count: 1, selectedItems: [0]);

    PickerViewPopup.showMode(
      PickerShowMode.AlertDialog,
      controller: pickerController,
      context: context,
      title: Text(title),
      cancel: Text('Cancel'),
      onCancel: () {},
      confirm: Text('Confirm'),
      onConfirm: (controller) async {
        final selectedItem = items[controller.selectedRowAt(section: 0)];
        _airportTerminalTc.text = selectedItem;
      },
      onSelectRowChanged: (section, row) {},
      builder: (context, popup) {
        return SizedBox(
          height: 200,
          child: popup,
        );
      },
      itemExtent: 40,
      numberofRowsAtSection: (section) => items.length,
      itemBuilder: (section, row) => Text(items[row]),
    );
  }

  String changeDateFormat(DateTime serverDate) {
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(serverDate);
  }

  String changeTimeFormat(DateTime serverDate) {
    final DateFormat formatter = DateFormat.jm();
    return formatter.format(serverDate);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataService>(context, listen: false).resetOpacityStatus();
    });
    final userDetails = Provider.of<DataService>(context, listen: false).userDetails;
    _fullNameTc.text = userDetails['name'] ?? '';
    _emailTc.text = userDetails['email'] ?? '';
    _airportTerminalTc.text = 'Terminal 3 - Toronto Pearson Airport';
  }

  @override
  void dispose() {
    _fullNameTc.dispose();
    _emailTc.dispose();
    _airportTerminalTc.dispose();
    _flightInfoTc.dispose();
    _fullNameFn.dispose();
    _emailFn.dispose();
    _airportTerminalFn.dispose();
    _flightInfoFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        return Scaffold(
          body: ModalProgressHUD(
            inAsyncCall: _isSpinnerToShow,
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  height: screenHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/carBg.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: (screenHeight / 2) - 125,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    'https://media0.giphy.com/media/cYHPG7CgfTM9DzW8YL/giphy.gif?cid=790b76110c3645109aec5924d417348e50bd226b166bc4c0&rid=giphy.gif&ct=g'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 20,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 40,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.arrow_back_ios),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(height: 65),
                                Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        height: 40,
                                        width: 125,
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
                                            ),
                                          ],
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () => launch("tel://18556611577"),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/images/phoneIcon.png', height: 25, width: 25),
                                            SizedBox(height: 5),
                                            Text(
                                              "CALL FOR BOOKING",
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 8),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'ONLINE BOOKING',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                Text(
                                  '- A minimum of 2 hours is needed for Pickup -',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CustomTfOne(
                                          title: 'Full Name',
                                          isMandatory: true,
                                          controller: _fullNameTc,
                                          focusNode: _fullNameFn,
                                          keyPadType: TextInputType.text,
                                          inputAction: TextInputAction.next,
                                          hintText: 'Full Name',
                                          capitalization: TextCapitalization.words,
                                          isReadOnly: false,
                                          onSubmitted: (value) => FocusScope.of(context).requestFocus(_emailFn),
                                        ),
                                        CustomTfOne(
                                          title: 'Email',
                                          isMandatory: true,
                                          controller: _emailTc,
                                          focusNode: _emailFn,
                                          keyPadType: TextInputType.emailAddress,
                                          inputAction: TextInputAction.done,
                                          hintText: 'Email',
                                          capitalization: TextCapitalization.none,
                                          isReadOnly: false,
                                          onSubmitted: (value) => FocusScope.of(context).unfocus(),
                                        ),
                                        GestureDetector(
                                          onTap: () => _showTerminalOptionPicker(
                                            items: _terminalOptions,
                                            title: 'AIRPORT TERMINALS',
                                          ),
                                          child: AbsorbPointer(
                                            absorbing: true,
                                            child: CustomTfOne(
                                              title: 'Airport Terminal',
                                              isMandatory: true,
                                              controller: _airportTerminalTc,
                                              focusNode: _airportTerminalFn,
                                              keyPadType: TextInputType.text,
                                              inputAction: TextInputAction.done,
                                              hintText: 'Airport Terminal',
                                              capitalization: TextCapitalization.words,
                                              isReadOnly: true,
                                            ),
                                          ),
                                        ),
                                        CustomTfOne(
                                          title: 'Flight Info',
                                          isMandatory: true,
                                          controller: _flightInfoTc,
                                          focusNode: _flightInfoFn,
                                          keyPadType: TextInputType.text,
                                          inputAction: TextInputAction.done,
                                          hintText: 'Flight Info',
                                          capitalization: TextCapitalization.words,
                                          isReadOnly: false,
                                          onSubmitted: (val) => FocusScope.of(context).unfocus(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                  child: InkWell(
                                    onTap: () async {
                                      final fullName = _fullNameTc.text;
                                      if (fullName.length < 3) {
                                        NetworkService.shared.showSnackBar("Please provide your name", Colors.red, context);
                                        return;
                                      }
                                      final phone = dataService.userDetails['mobileNo'] ?? '';

                                      final email = _emailTc.text;
                                      if (!validateEmail(email)) {
                                        NetworkService.shared.showSnackBar('Invalid Email', Colors.red, context);
                                        return;
                                      }

                                      final pickUpAddress = _airportTerminalTc.text;
                                      final flightInfo = _flightInfoTc.text;
                                      if (flightInfo.isEmpty) {
                                        NetworkService.shared.showSnackBar("Please provide flight info such as Flight No.", Colors.red, context);
                                        return;
                                      }

                                      final currentDate = DateTime.now().add(Duration(hours: 2));
                                      final date = changeDateFormat(currentDate);
                                      final time = changeTimeFormat(currentDate);

                                      final bookingOrder = BookingOrder(
                                        bookingOption: 4,
                                        phone: phone,
                                        fullName: fullName,
                                        flightInfo: flightInfo,
                                        email: email,
                                        pickDate: date,
                                        pickTime: time,
                                        travelFrom: pickUpAddress,
                                        travelTo: '',
                                        carType: 1,
                                        specialRequest: '',
                                        wakeUp: '',
                                        paymentType: 2,
                                        corporateAccNo: '',
                                      );
                                      setState(() => _isSpinnerToShow = true);
                                      final response = await NetworkService.shared.bookOrder(bookingOrder: bookingOrder);
                                      setState(() => _isSpinnerToShow = false);
                                      if (response.code == 1) {
                                        Alert(
                                          context: context,
                                          type: AlertType.success,
                                          title: "SUCCESS",
                                          desc: response.message,
                                          buttons: [
                                            DialogButton(
                                              child: Text(
                                                "OK",
                                                style: TextStyle(color: Colors.white, fontSize: 18),
                                              ),
                                              onPressed: () => Navigator.popUntil(context, ModalRoute.withName('HomeScreen')),
                                              color: Colors.blue,
                                            ),
                                          ],
                                        ).show();
                                      } else {
                                        NetworkService.shared.showSnackBar(response.message, Colors.red, context);
                                      }
                                    },
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'BOOK ORDER',
                                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
