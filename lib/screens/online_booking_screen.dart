import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker_view/picker_view.dart';
import 'package:flutter_picker_view/picker_view_popup.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:pvl/models/booking_option.dart';
import 'package:pvl/models/booking_order.dart';
import 'package:pvl/models/car_type.dart';
import 'package:pvl/models/init_detail.dart';
import 'package:pvl/models/rate_per_town.dart';
import 'package:pvl/services/constants.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl/services/network_service.dart';
import 'package:pvl_master/models/booking_option.dart';
import 'package:pvl_master/models/car_type.dart';
import 'package:pvl_master/models/rate_per_town.dart';
import 'package:pvl_master/services/network_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:url_launcher/url_launcher.dart';

class OnlineBookingScreen extends StatefulWidget {
  @override
  _OnlineBookingScreenState createState() => _OnlineBookingScreenState();
}

enum AddressType { PickUpAddress, DropOffAddress }

class _OnlineBookingScreenState extends State<OnlineBookingScreen> {
  ///MARK: Variables
  TextEditingController _fullNameTc = new TextEditingController();
  TextEditingController _phoneTc = new TextEditingController();
  TextEditingController _emailTc = new TextEditingController();
  TextEditingController _bookingOptionsTc = new TextEditingController();
  TextEditingController _pickUpAddressTc = new TextEditingController();
  TextEditingController _dropOffAddressTc = new TextEditingController();
  TextEditingController _pickupDateTc = new TextEditingController();
  TextEditingController _pickupTimeTc = new TextEditingController();
  TextEditingController _vehicleTypeTc = new TextEditingController();
  TextEditingController _mapForPriceTc = new TextEditingController();
  TextEditingController _listOfTownsTc = new TextEditingController();
  TextEditingController _priceTc = new TextEditingController();
  TextEditingController _noOfPassengersTc = new TextEditingController();
  TextEditingController _noOfBagsTc = new TextEditingController();
  TextEditingController _specialInstrutionsTc = new TextEditingController();
  TextEditingController _paymentOptionTc = new TextEditingController();
  TextEditingController _corporateAccountTc = new TextEditingController();
  TextEditingController _flightInfoTc = new TextEditingController();

  FocusNode _fullNameFn = new FocusNode();
  FocusNode _phoneFn = new FocusNode();
  FocusNode _emailFn = new FocusNode();
  FocusNode _bookingOptionsFn = new FocusNode();
  FocusNode _pickUpAddressFn = new FocusNode();
  FocusNode _dropOffAddressFn = new FocusNode();
  FocusNode _pickupDateFn = new FocusNode();
  FocusNode _pickupTimeFn = new FocusNode();
  FocusNode _vehicleTypeFn = new FocusNode();
  FocusNode _mapForPriceFn = new FocusNode();
  FocusNode _listOfTownsFn = new FocusNode();
  FocusNode _priceFn = new FocusNode();
  FocusNode _noOfPassengersFn = new FocusNode();
  FocusNode _noOfBagsFn = new FocusNode();
  FocusNode _specialInstructionsFn = new FocusNode();
  FocusNode _paymentOptionsFn = new FocusNode();
  FocusNode _corporateAccountFn = new FocusNode();
  FocusNode _flightInfoFn = new FocusNode();

  bool _isPickUpTcReadOnly = false;
  bool _isDropOffReadOnly = false;

  BuildContext _cxt;
  // List<Widget> _formWidgets = [];
  int _noOfForms = 6;
  int _currentIndex = 0;
  BookingOption _selectedBookingOption = BookingOption(
      id: 1,
      name: 'To Pearson Intl Airport',
      fullName: 'Pearson International Airport');
  CarType _selectedCar = CarType(id: 1, name: 'SEDAN');
  PaymentType _selectedPaymentType = PaymentType(id: 2, name: "Cash");
  bool _isSpinnerToShow = false;

  List<BookingOption> _bookingOptions = [
    BookingOption(
        id: 1,
        name: 'To Pearson Intl Airport',
        fullName: 'Pearson International Airport'),
    BookingOption(id: 2, name: 'From One to Another Address', fullName: ''),
    BookingOption(
        id: 3,
        name: 'To Island/Billy Bishop Airport',
        fullName: 'Billy Bishop Airport'),
    BookingOption(
        id: 4,
        name: 'From Pearson Airport',
        fullName: 'Pearson International Airport'),
    BookingOption(
        id: 5, name: 'From Buffalo Airport', fullName: 'Buffalo Airport'),
  ];
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();
  List<CarType> _carTypes = [
    CarType(id: 1, name: 'SEDAN'),
    CarType(id: 2, name: 'SUV'),
    CarType(id: 3, name: 'VAN')
  ];

  List<PaymentType> _paymentOptions = [
    PaymentType(id: 1, name: "Corprate Account"),
    PaymentType(id: 2, name: "Cash"),
    PaymentType(id: 3, name: "Credit"),
    PaymentType(id: 4, name: "Debit")
  ];

  List<String> _priceMapsOptions = [
    'East GTA Limousine Tariffs',
    'West GTA Limousine Tariffs',
    'Limousine Out of Town Tariffs',
    'List of Towns'
  ];

  List<RatePerTown> _ratePerTownOptions = [];
  String _pickTimeInstruction = '';

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  _setRatePerTownOptions() {
    List<String> keys = [];
    List<String> values = [];
    for (Map<String, String> rate in rates) {
      for (var key in rate.keys) {
        keys.add(key);
      }

      for (var val in rate.values) {
        values.add(val);
      }
    }

    _ratePerTownOptions = [];
    for (var i = 0; i < keys.length; i++) {
      RatePerTown ratePerTown = RatePerTown(name: keys[i], amount: values[i]);
      _ratePerTownOptions.add(ratePerTown);
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex == 0) {
      return true;
    } else {
      if (_currentIndex == 3) {
        if (_selectedBookingOption.id == 5) {
          setState(() {
            _pickTimeInstruction =
            "- A minimum of 4 hours is needed for Pickup -";
          });
        } else {
          setState(() {
            _pickTimeInstruction =
            "- A minimum of 2 hours is needed for Pickup -";
          });
        }
      } else {
        setState(() {
          _pickTimeInstruction = "";
        });
      }
      setState(() {
        _currentIndex--;
      });
      itemScrollController.scrollTo(
          index: _currentIndex,
          duration: Duration(seconds: 1),
          curve: Curves.easeOutSine);

      return false;
    }
  }

  _dispose() {
    _fullNameTc.dispose();
    _phoneTc.dispose();
    _emailTc.dispose();
    _bookingOptionsTc.dispose();
    _pickUpAddressTc.dispose();
    _dropOffAddressTc.dispose();
    _pickupDateTc.dispose();
    _pickupTimeTc.dispose();
    _vehicleTypeTc.dispose();
    _mapForPriceTc.dispose();
    _listOfTownsTc.dispose();
    _priceTc.dispose();
    _paymentOptionTc.dispose();
    _corporateAccountTc.dispose();
    _fullNameFn.dispose();
    _phoneFn.dispose();
    _emailFn.dispose();
    _noOfPassengersTc.dispose();
    _noOfBagsTc.dispose();
    _specialInstrutionsTc.dispose();
    _flightInfoTc.dispose();
    _bookingOptionsFn.dispose();
    _pickUpAddressFn.dispose();
    _dropOffAddressFn.dispose();
    _pickupDateFn.dispose();
    _pickupTimeFn.dispose();
    _vehicleTypeFn.dispose();
    _mapForPriceFn.dispose();
    _listOfTownsFn.dispose();
    _priceFn.dispose();
    _noOfPassengersFn.dispose();
    _noOfBagsFn.dispose();
    _specialInstructionsFn.dispose();
    _paymentOptionsFn.dispose();
    _corporateAccountFn.dispose();
    _flightInfoFn.dispose();
  }

  void _showBookingOptionPicker({
    List<BookingOption> items,
    String title,
  }) {
    PickerController pickerController =
    PickerController(count: 1, selectedItems: [0]);

    PickerViewPopup.showMode(PickerShowMode.AlertDialog,
        controller: pickerController,
        context: context,
        title: Text(title),
        cancel: Text(
          'cancel',
        ),
        onCancel: () {
          // Scaffold.of(_cxt).showSnackBar(
          //     SnackBar(content: Text('AlertDialogPicker.cancel')));
        },
        confirm: Text(
          'confirm',
        ),
        onConfirm: (controller) async {
          List<int> selectedItems = [];
          selectedItems.add(controller.selectedRowAt(section: 0));
          String selValue = items[controller.selectedRowAt(section: 0)].name;
          _bookingOptionsTc.text = selValue;
          int selectedIndex = controller.selectedRowAt(section: 0);
          switch (selectedIndex) {
            case 0:
              setState(() {
                _pickUpAddressTc.text = '';
                _isPickUpTcReadOnly = false;
                _dropOffAddressTc.text =
                    _bookingOptions[selectedIndex].fullName;
                _isDropOffReadOnly = true;
              });
              break;
            case 1:
              setState(() {
                _pickUpAddressTc.text = '';
                _isPickUpTcReadOnly = false;
                _dropOffAddressTc.text = '';
                _isDropOffReadOnly = false;
              });
              break;
            case 2:
              setState(() {
                _pickUpAddressTc.text = '';
                _isPickUpTcReadOnly = false;
                _dropOffAddressTc.text =
                    _bookingOptions[selectedIndex].fullName;
                _isDropOffReadOnly = true;
              });
              break;
            case 3:
              setState(() {
                _pickUpAddressTc.text = _bookingOptions[selectedIndex].fullName;
                _isPickUpTcReadOnly = true;
                _dropOffAddressTc.text = '';
                _isDropOffReadOnly = false;
              });
              break;
            case 4:
              setState(() {
                _pickUpAddressTc.text = _bookingOptions[selectedIndex].fullName;
                _isPickUpTcReadOnly = true;
                _dropOffAddressTc.text = '';
                _isDropOffReadOnly = false;
              });
              break;
            default:
              setState(() {
                _pickUpAddressTc.text = '';
                _isPickUpTcReadOnly = false;
                _dropOffAddressTc.text = '';
                _isDropOffReadOnly = false;
              });
              break;
          }
          _selectedBookingOption = _bookingOptions[selectedIndex];
          _pickupDateTc.text = "";
          _pickupTimeTc.text = "";
        },
        onSelectRowChanged: (section, row) {
          String selValue = items[row].name;
        },
        builder: (context, popup) {
          return Container(
            height: 200,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          return items.length;
        },
        itemBuilder: (section, row) {
          return Text(
            items[row].name,
          );
        });
  }

  _showCarTypePicker({
    List<CarType> items,
    String title,
  }) {
    PickerController pickerController =
    PickerController(count: 1, selectedItems: [0]);

    PickerViewPopup.showMode(PickerShowMode.AlertDialog,
        controller: pickerController,
        context: context,
        title: Text(title),
        cancel: Text(
          'cancel',
        ),
        onCancel: () {
          // Scaffold.of(_cxt).showSnackBar(
          //     SnackBar(content: Text('AlertDialogPicker.cancel')));
        },
        confirm: Text(
          'confirm',
        ),
        onConfirm: (controller) async {
          List<int> selectedItems = [];
          selectedItems.add(controller.selectedRowAt(section: 0));
          String selValue = items[controller.selectedRowAt(section: 0)].name;
          int selectedIndex = controller.selectedRowAt(section: 0);
          _vehicleTypeTc.text = selValue;
          _selectedCar = _carTypes[selectedIndex];
        },
        onSelectRowChanged: (section, row) {
          String selValue = items[row].name;
        },
        builder: (context, popup) {
          return Container(
            height: 200,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          return items.length;
        },
        itemBuilder: (section, row) {
          return Text(
            items[row].name,
          );
        });
  }

  _showPaymentTypePicker({
    List<PaymentType> items,
    String title,
  }) {
    PickerController pickerController =
    PickerController(count: 1, selectedItems: [0]);

    PickerViewPopup.showMode(PickerShowMode.AlertDialog,
        controller: pickerController,
        context: context,
        title: Text(title),
        cancel: Text(
          'cancel',
        ),
        onCancel: () {
          // Scaffold.of(_cxt).showSnackBar(
          //     SnackBar(content: Text('AlertDialogPicker.cancel')));
        },
        confirm: Text(
          'confirm',
        ),
        onConfirm: (controller) async {
          List<int> selectedItems = [];
          selectedItems.add(controller.selectedRowAt(section: 0));
          String selValue = items[controller.selectedRowAt(section: 0)].name;
          int selectedIndex = controller.selectedRowAt(section: 0);
          _paymentOptionTc.text = selValue;
          _selectedPaymentType = _paymentOptions[selectedIndex];
        },
        onSelectRowChanged: (section, row) {
          String selValue = items[row].name;
        },
        builder: (context, popup) {
          return Container(
            height: 200,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          return items.length;
        },
        itemBuilder: (section, row) {
          return Text(
            items[row].name,
          );
        });
  }

  _showMapsTypePicker({
    List<String> items,
    String title,
  }) {
    PickerController pickerController =
    PickerController(count: 1, selectedItems: [0]);

    PickerViewPopup.showMode(PickerShowMode.AlertDialog,
        controller: pickerController,
        context: context,
        title: Text(title),
        cancel: Text(
          'cancel',
        ),
        onCancel: () {
          // Scaffold.of(_cxt).showSnackBar(
          //     SnackBar(content: Text('AlertDialogPicker.cancel')));
        },
        confirm: Text(
          'confirm',
        ),
        onConfirm: (controller) async {
          List<int> selectedItems = [];
          selectedItems.add(controller.selectedRowAt(section: 0));
          String selValue = items[controller.selectedRowAt(section: 0)];
          int selectedIndex = controller.selectedRowAt(section: 0);
          _mapForPriceTc.text = selValue;
        },
        onSelectRowChanged: (section, row) {
          String selValue = items[row];
        },
        builder: (context, popup) {
          return Container(
            height: 200,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          return items.length;
        },
        itemBuilder: (section, row) {
          return Text(
            items[row],
          );
        });
  }

  _showRatePerTownPicker({
    List<RatePerTown> items,
    String title,
  }) {
    PickerController pickerController =
    PickerController(count: 1, selectedItems: [0]);

    PickerViewPopup.showMode(PickerShowMode.AlertDialog,
        controller: pickerController,
        context: context,
        title: Text(title),
        cancel: Text(
          'cancel',
        ),
        onCancel: () {
          // Scaffold.of(_cxt).showSnackBar(
          //     SnackBar(content: Text('AlertDialogPicker.cancel')));
        },
        confirm: Text(
          'confirm',
        ),
        onConfirm: (controller) async {
          List<int> selectedItems = [];
          selectedItems.add(controller.selectedRowAt(section: 0));
          String selValue = items[controller.selectedRowAt(section: 0)].name;
          int selectedIndex = controller.selectedRowAt(section: 0);
          _listOfTownsTc.text = selValue;
          _priceTc.text = _ratePerTownOptions[selectedIndex].amount;
        },
        onSelectRowChanged: (section, row) {
          String selValue = items[row].name;
        },
        builder: (context, popup) {
          return Container(
            height: 200,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          return items.length;
        },
        itemBuilder: (section, row) {
          return Text(
            items[row].name,
          );
        });
  }

  _getAddress(AddressType type, BuildContext context) async {
    InitDetail initDetail =
        Provider.of<DataService>(context, listen: false).initDetail;
    Prediction prediction = await PlacesAutocomplete.show(
        offset: 0,
        radius: 1000,
        strictbounds: false,
        region: "ca",
        language: "en",
        context: context,
        mode: Mode.overlay,
        apiKey: initDetail.googleApiKey,
        components: [new Component(Component.country, "ca")],
        types: [],
        hint: "Search Your Address",
        startText: "");

    //AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg

    if (prediction != null) {
      print(prediction.description);
      if (type == AddressType.PickUpAddress) {
        _pickUpAddressTc.text = prediction.description;
      } else {
        _dropOffAddressTc.text = prediction.description;
      }
    } else {
      NetworkService.shared
          .showSnackBar('No address got selected', Colors.grey, context);
      print("No address got selected");
    }
  }

  String changeDateFormat(DateTime serverDate) {
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    final String formatted = formatter.format(serverDate);
    return formatted;
  }

  String changeTimeFormat(DateTime serverDate) {
    final DateFormat formatter = DateFormat.jm();
    final String formatted = formatter.format(serverDate);
    return formatted;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _bookingOptionsTc.text = _bookingOptions[0].name;
        _dropOffAddressTc.text = _bookingOptions[0].fullName;
        _isDropOffReadOnly = true;
        _vehicleTypeTc.text = _selectedCar.name;
        _paymentOptionTc.text = _selectedPaymentType.name;
      });
      Provider.of<DataService>(context, listen: false).resetOpacityStatus();
      Map<String, dynamic> userDetails =
          Provider.of<DataService>(context, listen: false).userDetails;
      _fullNameTc.text = userDetails['name'];
      _emailTc.text = userDetails['email'];
      _phoneTc.text = userDetails['mobileNo'];
    });
    _setRatePerTownOptions();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cxt = context;
    double screenHeight = MediaQuery.of(context).size.height;
    double contentRectWidth = MediaQuery.of(context).size.width - 40;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Consumer<DataService>(builder: (ctx, dataService, child) {
          return Scaffold(
            body: ModalProgressHUD(
              inAsyncCall: _isSpinnerToShow,
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/carBg.png'),
                            fit: BoxFit.fill)),
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
                                    fit: BoxFit.cover),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_currentIndex == 0) {
                                  Navigator.pop(context);
                                } else {
                                  if (_currentIndex == 3) {
                                    if (_selectedBookingOption.id == 5) {
                                      setState(() {
                                        _pickTimeInstruction =
                                        "- A minimum of 4 hours is needed for Pickup -";
                                      });
                                    } else {
                                      setState(() {
                                        _pickTimeInstruction =
                                        "- A minimum of 2 hours is needed for Pickup -";
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _pickTimeInstruction = "";
                                    });
                                  }
                                  setState(() {
                                    _currentIndex--;
                                  });
                                  itemScrollController.scrollTo(
                                      index: _currentIndex,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.easeOutSine);
                                }
                              },
                              child: Padding(
                                padding:
                                const EdgeInsets.only(top: 20, left: 20),
                                child: Container(
                                  height: 40,
                                  width: 50,
                                  child: Icon(Icons.arrow_back_ios),
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 65,
                                ),
                                Stack(children: [
                                  Center(
                                    child: Container(
                                      height: 40,
                                      width: 125,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/logo.png'),
                                              fit: BoxFit.cover),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.white,
                                                offset: Offset(0, 0),
                                                blurRadius: 15.0,
                                                spreadRadius: 5.0)
                                          ],
                                          color: Colors.transparent),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          launch("tel://18556611577");
                                        },
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 25,
                                                width: 25,
                                                child: Image.asset(
                                                    'assets/images/phoneIcon.png'),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                "CALL FOR BOOKING",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 8),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'ONLINE BOOKING',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                Text(
                                  _pickTimeInstruction,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      child: Container(
                                        child: ScrollablePositionedList.builder(
                                          physics:
                                          NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _noOfForms,
                                          itemBuilder: (context, index) {
                                            if (index == 0) {
                                              return Container(
                                                height: double.infinity,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    40,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                                  children: [
                                                    CustomTfOne(
                                                      title: 'Full Name',
                                                      isMandatory: true,
                                                      controller: _fullNameTc,
                                                      focusNode: _fullNameFn,
                                                      keyPadType:
                                                      TextInputType.text,
                                                      inputAction:
                                                      TextInputAction.next,
                                                      hintText: 'Full Name',
                                                      capitalization:
                                                      TextCapitalization
                                                          .words,
                                                      isReadOnly: false,
                                                      onSubmitted: (value) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            _phoneFn);
                                                      },
                                                    ),
                                                    CustomTfOne(
                                                      title: 'Phone',
                                                      isMandatory: true,
                                                      controller: _phoneTc,
                                                      focusNode: _phoneFn,
                                                      keyPadType:
                                                      TextInputType.phone,
                                                      inputAction:
                                                      TextInputAction.done,
                                                      hintText: 'Phone',
                                                      capitalization:
                                                      TextCapitalization
                                                          .none,
                                                      isReadOnly: false,
                                                      onSubmitted: (value) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            new FocusNode());
                                                      },
                                                    ),
                                                    CustomTfOne(
                                                      title: 'Email',
                                                      isMandatory: true,
                                                      controller: _emailTc,
                                                      focusNode: _emailFn,
                                                      keyPadType: TextInputType
                                                          .emailAddress,
                                                      inputAction:
                                                      TextInputAction.done,
                                                      hintText: "Email",
                                                      capitalization:
                                                      TextCapitalization
                                                          .none,
                                                      isReadOnly: false,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (index == 1) {
                                              return Container(
                                                height: double.infinity,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    40,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showBookingOptionPicker(
                                                            items:
                                                            _bookingOptions,
                                                            title:
                                                            'BOOKING OPTIONS');
                                                      },
                                                      child: AbsorbPointer(
                                                        absorbing: true,
                                                        child: CustomTfOne(
                                                          title:
                                                          'Booking Option',
                                                          isMandatory: true,
                                                          controller:
                                                          _bookingOptionsTc,
                                                          focusNode:
                                                          _bookingOptionsFn,
                                                          keyPadType:
                                                          TextInputType
                                                              .text,
                                                          inputAction:
                                                          TextInputAction
                                                              .done,
                                                          hintText:
                                                          'Booking Option',
                                                          capitalization:
                                                          TextCapitalization
                                                              .words,
                                                          isReadOnly: true,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (!_isPickUpTcReadOnly) {
                                                          _getAddress(
                                                              AddressType
                                                                  .PickUpAddress,
                                                              context);
                                                        }
                                                      },
                                                      child: AbsorbPointer(
                                                        absorbing: true,
                                                        child: CustomTfOne(
                                                          title:
                                                          'Pickup Address',
                                                          isMandatory: true,
                                                          controller:
                                                          _pickUpAddressTc,
                                                          focusNode:
                                                          _pickUpAddressFn,
                                                          keyPadType:
                                                          TextInputType
                                                              .text,
                                                          inputAction:
                                                          TextInputAction
                                                              .done,
                                                          hintText:
                                                          'Pickup Address',
                                                          capitalization:
                                                          TextCapitalization
                                                              .words,
                                                          isReadOnly:
                                                          _isPickUpTcReadOnly,
                                                          onSubmitted: (val) {
                                                            // _getAddress(AddressType
                                                            //     .PickUpAddress);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (!_isDropOffReadOnly) {
                                                          _getAddress(
                                                              AddressType
                                                                  .DropOffAddress,
                                                              context);
                                                        }
                                                      },
                                                      child: AbsorbPointer(
                                                        absorbing: true,
                                                        child: CustomTfOne(
                                                          title:
                                                          'Dropoff Address',
                                                          isMandatory: true,
                                                          controller:
                                                          _dropOffAddressTc,
                                                          focusNode:
                                                          _dropOffAddressFn,
                                                          keyPadType:
                                                          TextInputType
                                                              .text,
                                                          inputAction:
                                                          TextInputAction
                                                              .next,
                                                          hintText:
                                                          'Dropoff Address',
                                                          capitalization:
                                                          TextCapitalization
                                                              .words,
                                                          isReadOnly:
                                                          _isDropOffReadOnly,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (index == 2) {
                                              /// Hi H
                                              return Container(
                                                height: double.infinity,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    40,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        DateTime currentDate =
                                                        DateTime.now();
                                                        Duration d;
                                                        if (_selectedBookingOption
                                                            .id ==
                                                            5) {
                                                          // Add 4 hours
                                                          d = Duration(
                                                              hours: 4);
                                                        } else {
                                                          // Add Two Hours
                                                          d = Duration(
                                                              hours: 2);
                                                        }
                                                        DateTime minTime =
                                                        currentDate.add(d);
                                                        DatePicker.showDatePicker(
                                                            context,
                                                            showTitleActions:
                                                            true,
                                                            minTime: minTime,
                                                            maxTime: DateTime(
                                                                currentDate
                                                                    .year,
                                                                currentDate
                                                                    .month,
                                                                currentDate.day +
                                                                    5),
                                                            theme: DatePickerTheme(
                                                                headerColor:
                                                                Colors.grey,
                                                                backgroundColor:
                                                                Colors
                                                                    .black,
                                                                itemStyle: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    18),
                                                                doneStyle:
                                                                TextStyle(color: Colors.white, fontSize: 16)),
                                                            onChanged: (date) {
                                                              _pickupDateTc.text =
                                                                  changeDateFormat(
                                                                      date);
                                                              _pickupTimeTc.text =
                                                              '';
                                                            }, onConfirm: (date) {
                                                          _pickupDateTc.text =
                                                              changeDateFormat(
                                                                  date);
                                                          _pickupTimeTc.text =
                                                          '';
                                                        },
                                                            currentTime:
                                                            DateTime.now(),
                                                            locale: LocaleType.en);
                                                      },
                                                      child: AbsorbPointer(
                                                        absorbing: true,
                                                        child: CustomTfOne(
                                                          title: 'Pickup Date',
                                                          isMandatory: true,
                                                          controller:
                                                          _pickupDateTc,
                                                          focusNode:
                                                          _pickupDateFn,
                                                          keyPadType:
                                                          TextInputType
                                                              .text,
                                                          inputAction:
                                                          TextInputAction
                                                              .done,
                                                          hintText:
                                                          'Pickup Date',
                                                          capitalization:
                                                          TextCapitalization
                                                              .words,
                                                          isReadOnly: true,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (_pickupDateTc
                                                            .text.isEmpty) {
                                                          NetworkService.shared
                                                              .showSnackBar(
                                                              "Please select date before select time",
                                                              Colors.red,
                                                              context);
                                                          return;
                                                        }
                                                        Duration duration;
                                                        if (_selectedBookingOption
                                                            .id ==
                                                            5) {
                                                          duration = Duration(
                                                              hours: 4);
                                                        } else {
                                                          duration = Duration(
                                                              hours: 2);
                                                        }
                                                        DateTime
                                                        conditionsEligibleDate =
                                                        DateTime.now()
                                                            .add(duration);
                                                        DateTime todayDate =
                                                        DateTime.now();
                                                        DateTime minTime =
                                                        DateTime.now();
                                                        String selectedDate =
                                                            _pickupDateTc.text;
                                                        int sDateOnly = int
                                                            .parse(selectedDate
                                                            .split("-")[0]);
                                                        String a = '';
                                                        if (sDateOnly ==
                                                            conditionsEligibleDate
                                                                .day) {
                                                          /// Put conditions apply
                                                          Duration d;
                                                          if (_selectedBookingOption
                                                              .id ==
                                                              5) {
                                                            d = Duration(
                                                                hours: 4);
                                                            a = "4";
                                                          } else {
                                                            d = Duration(
                                                                hours: 2);
                                                            a = "2";
                                                          }
                                                          minTime =
                                                              minTime.add(d);
                                                        }

                                                        /*String selectedDate =
                                                            _pickupDateTc.text;
                                                        int sDateOnly = int
                                                            .parse(selectedDate
                                                                .split("-")[0]);
                                                        DateTime currentDate =
                                                            DateTime.now();
                                                        int cDateOnly =
                                                            currentDate.day;
                                                        if (sDateOnly ==
                                                            cDateOnly) {
                                                          Duration d;
                                                          String a = '';
                                                          if (_selectedBookingOption
                                                                  .id ==
                                                              5) {
                                                            // Add 4 hours
                                                            d = Duration(
                                                                hours: 4);
                                                            a = "4";
                                                          } else {
                                                            // Add Two Hours
                                                            d = Duration(
                                                                hours: 2);
                                                            a = "2";
                                                          }
                                                          currentDate =
                                                              currentDate
                                                                  .add(d);
                                                        }*/

                                                        DatePicker.showTime12hPicker(
                                                            context,
                                                            showTitleActions:
                                                            true,
                                                            theme: DatePickerTheme(
                                                                headerColor:
                                                                Colors.grey,
                                                                backgroundColor:
                                                                Colors
                                                                    .black,
                                                                itemStyle: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    18),
                                                                doneStyle: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: 16)),
                                                            onChanged: (date) {
                                                              DateTime abc =
                                                              minTime.subtract(
                                                                  Duration(
                                                                      minutes:
                                                                      1));
                                                              if (date.isAfter(
                                                                  abc) ||
                                                                  date.isAtSameMomentAs(
                                                                      minTime)) {
                                                                _pickupTimeTc.text =
                                                                    changeTimeFormat(
                                                                        date);
                                                              } else {
                                                                _pickupTimeTc.text =
                                                                "";
                                                                // String errMsg =
                                                                //     "A minimum of $a hours is needed for Pickup";
                                                                // NetworkService
                                                                //     .shared
                                                                //     .showSnackBar(
                                                                //         errMsg,
                                                                //         Colors.red,
                                                                //         context);
                                                              }
                                                            }, onConfirm: (date) {
                                                          DateTime abc =
                                                          minTime.subtract(
                                                              Duration(
                                                                  minutes:
                                                                  1));
                                                          if (date.isAfter(
                                                              abc) ||
                                                              date.isAtSameMomentAs(
                                                                  minTime)) {
                                                            _pickupTimeTc.text =
                                                                changeTimeFormat(
                                                                    date);
                                                          } else {
                                                            _pickupTimeTc.text =
                                                            "";
                                                            String errMsg =
                                                                "A minimum of $a hours is needed for Pickup";
                                                            NetworkService
                                                                .shared
                                                                .showSnackBar(
                                                                errMsg,
                                                                Colors.red,
                                                                context);
                                                          }

                                                          // _pickupTimeTc.text =
                                                          //     changeTimeFormat(
                                                          //         date);
                                                        },
                                                            currentTime: minTime,
                                                            locale: LocaleType.en);
                                                      },
                                                      child: AbsorbPointer(
                                                        absorbing: true,
                                                        child: CustomTfOne(
                                                          title: 'Pickup Time',
                                                          isMandatory: true,
                                                          controller:
                                                          _pickupTimeTc,
                                                          focusNode:
                                                          _pickupTimeFn,
                                                          keyPadType:
                                                          TextInputType
                                                              .text,
                                                          inputAction:
                                                          TextInputAction
                                                              .done,
                                                          hintText:
                                                          'Pickup Time',
                                                          capitalization:
                                                          TextCapitalization
                                                              .words,
                                                          isReadOnly: true,
                                                          onSubmitted: (val) {},
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showCarTypePicker(
                                                            items: _carTypes,
                                                            title:
                                                            'VEHICLE TYPE');
                                                      },
                                                      child: AbsorbPointer(
                                                        absorbing: true,
                                                        child: CustomTfOne(
                                                          title: 'Vehicle',
                                                          isMandatory: true,
                                                          controller:
                                                          _vehicleTypeTc,
                                                          focusNode:
                                                          _vehicleTypeFn,
                                                          keyPadType:
                                                          TextInputType
                                                              .text,
                                                          inputAction:
                                                          TextInputAction
                                                              .next,
                                                          hintText: 'Vehicle',
                                                          capitalization:
                                                          TextCapitalization
                                                              .words,
                                                          isReadOnly: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (index == 3) {
                                              return Container(
                                                height: double.infinity,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    40,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showMapsTypePicker(
                                                            items:
                                                            _priceMapsOptions,
                                                            title:
                                                            "SELECT MAP");
                                                      },
                                                      child: AbsorbPointer(
                                                        absorbing: true,
                                                        child: CustomTfOne(
                                                          title:
                                                          'Map For Price',
                                                          isMandatory: false,
                                                          controller:
                                                          _mapForPriceTc,
                                                          focusNode:
                                                          _mapForPriceFn,
                                                          keyPadType:
                                                          TextInputType
                                                              .text,
                                                          inputAction:
                                                          TextInputAction
                                                              .done,
                                                          hintText:
                                                          'Map For Price',
                                                          capitalization:
                                                          TextCapitalization
                                                              .words,
                                                          isReadOnly: true,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showRatePerTownPicker(
                                                            items:
                                                            _ratePerTownOptions,
                                                            title:
                                                            "LIST OF TOWNS");
                                                      },
                                                      child: AbsorbPointer(
                                                        absorbing: true,
                                                        child: CustomTfOne(
                                                          title:
                                                          'List Of Towns',
                                                          isMandatory: false,
                                                          controller:
                                                          _listOfTownsTc,
                                                          focusNode:
                                                          _listOfTownsFn,
                                                          keyPadType:
                                                          TextInputType
                                                              .text,
                                                          inputAction:
                                                          TextInputAction
                                                              .done,
                                                          hintText:
                                                          'List Of Towns',
                                                          capitalization:
                                                          TextCapitalization
                                                              .words,
                                                          isReadOnly: true,
                                                          onSubmitted: (val) {},
                                                        ),
                                                      ),
                                                    ),
                                                    CustomTfOne(
                                                      title: 'Price',
                                                      isMandatory: false,
                                                      controller: _priceTc,
                                                      focusNode: _priceFn,
                                                      keyPadType:
                                                      TextInputType.text,
                                                      inputAction:
                                                      TextInputAction.done,
                                                      hintText: 'Price',
                                                      capitalization:
                                                      TextCapitalization
                                                          .words,
                                                      isReadOnly: true,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (index == 4) {
                                              return Container(
                                                height: double.infinity,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    40,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                                  children: [
                                                    CustomTfOne(
                                                      title: '# of Passengers',
                                                      isMandatory: false,
                                                      controller:
                                                      _noOfPassengersTc,
                                                      focusNode:
                                                      _noOfPassengersFn,
                                                      keyPadType:
                                                      TextInputType.number,
                                                      inputAction:
                                                      TextInputAction.done,
                                                      hintText:
                                                      '# of Passengers',
                                                      capitalization:
                                                      TextCapitalization
                                                          .words,
                                                      isReadOnly: false,
                                                      onSubmitted: (val) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            _noOfBagsFn);
                                                      },
                                                    ),
                                                    CustomTfOne(
                                                      title: '# of Bags',
                                                      isMandatory: false,
                                                      controller: _noOfBagsTc,
                                                      focusNode: _noOfBagsFn,
                                                      keyPadType:
                                                      TextInputType.number,
                                                      inputAction:
                                                      TextInputAction.done,
                                                      hintText: '# of bags',
                                                      capitalization:
                                                      TextCapitalization
                                                          .none,
                                                      isReadOnly: false,
                                                      onSubmitted: (val) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            _specialInstructionsFn);
                                                      },
                                                    ),
                                                    CustomTfOne(
                                                      title:
                                                      'Special Instructions',
                                                      isMandatory: false,
                                                      controller:
                                                      _specialInstrutionsTc,
                                                      focusNode:
                                                      _specialInstructionsFn,
                                                      keyPadType:
                                                      TextInputType.text,
                                                      inputAction:
                                                      TextInputAction.done,
                                                      hintText:
                                                      'Special Instructions',
                                                      capitalization:
                                                      TextCapitalization
                                                          .words,
                                                      isReadOnly: false,
                                                      onSubmitted: (val) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            new FocusNode());
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (index == 5) {
                                              return Container(
                                                height: double.infinity,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    40,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showPaymentTypePicker(
                                                            items:
                                                            _paymentOptions,
                                                            title:
                                                            'PAYMENT OPTIIONS');
                                                      },
                                                      child: AbsorbPointer(
                                                        absorbing: true,
                                                        child: CustomTfOne(
                                                          title:
                                                          'Payment Option',
                                                          isMandatory: false,
                                                          controller:
                                                          _paymentOptionTc,
                                                          focusNode:
                                                          _paymentOptionsFn,
                                                          keyPadType:
                                                          TextInputType
                                                              .number,
                                                          inputAction:
                                                          TextInputAction
                                                              .done,
                                                          hintText:
                                                          'Payment Option',
                                                          capitalization:
                                                          TextCapitalization
                                                              .words,
                                                          isReadOnly: true,
                                                          onSubmitted: (val) {},
                                                        ),
                                                      ),
                                                    ),
                                                    CustomTfOne(
                                                      title:
                                                      'Corporate Account',
                                                      isMandatory: false,
                                                      controller:
                                                      _corporateAccountTc,
                                                      focusNode:
                                                      _corporateAccountFn,
                                                      keyPadType:
                                                      TextInputType.text,
                                                      inputAction:
                                                      TextInputAction.done,
                                                      hintText:
                                                      'Corporate Account Number',
                                                      capitalization:
                                                      TextCapitalization
                                                          .none,
                                                      isReadOnly: false,
                                                      onSubmitted: (val) {},
                                                    ),
                                                    CustomTfOne(
                                                      title: 'Flight Info',
                                                      isMandatory:
                                                      (_selectedBookingOption
                                                          .id ==
                                                          4 ||
                                                          _selectedBookingOption
                                                              .id ==
                                                              5)
                                                          ? true
                                                          : false,
                                                      controller: _flightInfoTc,
                                                      focusNode: _flightInfoFn,
                                                      keyPadType:
                                                      TextInputType.text,
                                                      inputAction:
                                                      TextInputAction.done,
                                                      hintText: 'Flight Info',
                                                      capitalization:
                                                      TextCapitalization
                                                          .words,
                                                      isReadOnly: false,
                                                      onSubmitted: (val) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            new FocusNode());
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            return Container();
                                          },
                                          itemScrollController:
                                          itemScrollController,
                                          itemPositionsListener:
                                          itemPositionsListener,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, bottom: 10),
                                  child: InkWell(
                                    onTap: () async {
                                      /// Current Index: 0
                                      String fullName = _fullNameTc.text;
                                      String phoneNo = _phoneTc.text;
                                      String email = _emailTc.text;
                                      if (_currentIndex == 0) {
                                        if (fullName.length < 3) {
                                          NetworkService.shared.showSnackBar(
                                              'Please provide your name',
                                              Colors.red,
                                              context);
                                          return;
                                        }

                                        if (phoneNo.length != 10) {
                                          NetworkService.shared.showSnackBar(
                                              'Invalid Phone Number',
                                              Colors.red,
                                              context);
                                          return;
                                        }

                                        if (!validateEmail(email)) {
                                          NetworkService.shared.showSnackBar(
                                              'Invalid Email',
                                              Colors.red,
                                              context);
                                          return;
                                        }

                                        setState(() {
                                          _currentIndex = 1;
                                        });
                                        itemScrollController.scrollTo(
                                            index: _currentIndex,
                                            duration: Duration(seconds: 1),
                                            curve: Curves.easeOutSine);
                                        setState(() {
                                          _pickTimeInstruction = "";
                                        });
                                        return;
                                      }

                                      /// Current Index : 1
                                      int bookingOptionId =
                                          _selectedBookingOption.id;
                                      String pickupAddress =
                                          _pickUpAddressTc.text;
                                      String dropOffAddress =
                                          _dropOffAddressTc.text;
                                      if (_currentIndex == 1) {
                                        if (pickupAddress.isEmpty) {
                                          NetworkService.shared.showSnackBar(
                                              'Please provide the pickup address',
                                              Colors.red,
                                              context);
                                          return;
                                        }

                                        if (dropOffAddress.isEmpty) {
                                          NetworkService.shared.showSnackBar(
                                              'Please provide the drop off address',
                                              Colors.red,
                                              context);
                                          return;
                                        }
                                        setState(() {
                                          _currentIndex = 2;
                                        });
                                        itemScrollController.scrollTo(
                                            index: _currentIndex,
                                            duration: Duration(seconds: 1),
                                            curve: Curves.easeOutSine);
                                        if (bookingOptionId == 5) {
                                          setState(() {
                                            _pickTimeInstruction =
                                            "- A minimum of 4 hours is needed for Pickup -";
                                          });
                                        } else {
                                          setState(() {
                                            _pickTimeInstruction =
                                            "- A minimum of 2 hours is needed for Pickup -";
                                          });
                                        }
                                        return;
                                      }

                                      /// Current Index : 2
                                      String pickDate = _pickupDateTc.text;
                                      String pickTime = _pickupTimeTc.text;
                                      int carType = _selectedCar.id;
                                      if (_currentIndex == 2) {
                                        if (pickDate.isEmpty) {
                                          NetworkService.shared.showSnackBar(
                                              'Please select the pickup date',
                                              Colors.red,
                                              context);
                                          return;
                                        }

                                        if (pickTime.isEmpty) {
                                          NetworkService.shared.showSnackBar(
                                              'Please select the pickup time',
                                              Colors.red,
                                              context);
                                          return;
                                        }

                                        setState(() {
                                          _currentIndex = 3;
                                        });
                                        itemScrollController.scrollTo(
                                            index: _currentIndex,
                                            duration: Duration(seconds: 1),
                                            curve: Curves.easeOutSine);
                                        setState(() {
                                          _pickTimeInstruction = "";
                                        });
                                        return;
                                      }

                                      /// Current Index : 3
                                      if (_currentIndex == 3) {
                                        setState(() {
                                          _currentIndex = 4;
                                        });
                                        itemScrollController.scrollTo(
                                            index: _currentIndex,
                                            duration: Duration(seconds: 1),
                                            curve: Curves.easeOutSine);
                                        return;
                                      }

                                      /// Current Index : 4
                                      String specialRequest =
                                          _specialInstrutionsTc.text;
                                      String wakeUpTime = '';
                                      if (_currentIndex == 4) {
                                        setState(() {
                                          _currentIndex = 5;
                                        });
                                        itemScrollController.scrollTo(
                                            index: _currentIndex,
                                            duration: Duration(seconds: 1),
                                            curve: Curves.easeOutSine);
                                        return;
                                      }

                                      /// Current Index : 5
                                      String flightInfo = _flightInfoTc.text;
                                      int paymentType = _selectedPaymentType.id;
                                      String corporateAccountNo = '';
                                      if (_currentIndex == 5) {
                                        if (paymentType == 1) {
                                          corporateAccountNo =
                                              _corporateAccountTc.text;
                                          if (corporateAccountNo.isEmpty) {
                                            NetworkService.shared.showSnackBar(
                                                'Please provide the Corporate Account No. since you select payment option as Corporate Account',
                                                Colors.red,
                                                context);
                                            return;
                                          }
                                        }

                                        if (_selectedBookingOption.id == 4 ||
                                            _selectedBookingOption.id == 5) {
                                          if (flightInfo.isEmpty) {
                                            NetworkService.shared.showSnackBar(
                                                'Please provide flight info such as Flight No',
                                                Colors.red,
                                                context);
                                            return;
                                          }
                                        }

                                        /// Call Book Order
                                        setState(() => _isSpinnerToShow = true);
                                        BookingOrder bookingOrder =
                                        BookingOrder(
                                            bookingOption: bookingOptionId,
                                            phone: phoneNo,
                                            fullName: fullName,
                                            flightInfo: flightInfo,
                                            email: email,
                                            pickDate: pickDate,
                                            pickTime: pickTime,
                                            travelFrom: pickupAddress,
                                            travelTo: dropOffAddress,
                                            carType: carType,
                                            specialRequest: specialRequest,
                                            wakeUp: wakeUpTime,
                                            paymentType: paymentType,
                                            corporateAccNo:
                                            corporateAccountNo);

                                        ServerResponse response =
                                        await NetworkService.shared
                                            .bookOrder(
                                            bookingOrder: bookingOrder);
                                        setState(
                                                () => _isSpinnerToShow = false);
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
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  Navigator.popUntil(
                                                      context,
                                                      ModalRoute.withName(
                                                          'HomeScreen'));
                                                },
                                                color: Colors.blue,
                                              )
                                            ],
                                          ).show();
                                        } else {
                                          NetworkService.shared.showSnackBar(
                                              response.message,
                                              Colors.red,
                                              context);
                                        }
                                      }
                                    },
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: _currentIndex == _noOfForms - 1
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _currentIndex == _noOfForms - 1
                                              ? 'BOOK ORDER'
                                              : 'NEXT',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }));
  }
}

class CustomTfOne extends StatelessWidget {
  final String title;
  final bool isMandatory;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyPadType;
  final TextInputAction inputAction;
  final String hintText;
  final TextCapitalization capitalization;
  final bool isReadOnly;
  final Function onSubmitted;

  CustomTfOne(
      {this.title,
        required this.isMandatory,
        required this.controller,
        required this.focusNode,
        required this.keyPadType,
        required this.inputAction,
        required this.hintText,
        required this.capitalization,
        required this.isReadOnly,
        required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            Visibility(
              visible: isMandatory,
              child: Text(
                '*',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Container(
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: TextField(
              enabled: !isReadOnly,
              controller: controller,
              focusNode: focusNode,
              onSubmitted: (value) {},
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 16),
              keyboardType: keyPadType,
              textCapitalization: capitalization,
              textInputAction: inputAction,
              cursorColor: Colors.teal,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              ),
            )),
      ],
    );
  }
}
