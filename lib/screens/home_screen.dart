import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pvl/screens/airport_order_screen.dart';
import 'package:pvl/screens/online_booking_screen.dart';
import 'package:pvl/screens/past_orders_screen.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl/services/network_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double contentRectWidth = MediaQuery.of(context).size.width - 40;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer<DataService>(builder: (ctx, dataService, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/carBg.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: (screenHeight / 2) - 125,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://media0.giphy.com/media/cYHPG7CgfTM9DzW8YL/giphy.gif?cid=790b76110c3645109aec5924d417348e50bd226b166bc4c0&rid=giphy.gif&ct=g',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Opacity(
                                  opacity: dataService.onlineBookOpacityStatus ? 0 : 1,
                                  child: MenuCardOne(
                                    contentRectWidth: contentRectWidth,
                                    iconName: 'onlineBookIcon.png',
                                    titleOne: 'ONLINE',
                                    titleTwo: 'BOOKING',
                                    subTitle: 'Create an online booking for a Pearson Vision Limousine',
                                    onSelected: () {
                                      dataService.setOpacityStatusToZero();
                                      Future.delayed(Duration(milliseconds: 1000), () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx1) => OnlineBookingScreen(),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: Opacity(
                                  opacity: dataService.pastOrdersOpacityStatus ? 0 : 1,
                                  child: MenuCardOne(
                                    contentRectWidth: contentRectWidth,
                                    iconName: 'bookIcon.png',
                                    titleOne: 'PAST',
                                    titleTwo: 'ORDERS',
                                    subTitle: 'View all the orders you have made in the past through the app',
                                    onSelected: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (pastScreenContext) => PastOrdersScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(flex: 1, child: Container()),
                              Expanded(
                                flex: 2,
                                child: Opacity(
                                  opacity: dataService.callOpacityStatus ? 0 : 1,
                                  child: MenuCardTwo(
                                    contentRectWidth: contentRectWidth,
                                    iconName: 'phoneIcon.png',
                                    title: 'CALL FOR BOOKING',
                                    onSelected: () {
                                      dataService.setOpacityStatusToZero();
                                      Future.delayed(Duration(milliseconds: 1000), () {
                                        dataService.resetOpacityStatus();
                                        launch("tel://18556611577");
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: MenuCardTwo(
                                  contentRectWidth: contentRectWidth,
                                  iconName: 'logOutIcon.png',
                                  title: 'LOG OUT',
                                  onSelected: () {
                                    Alert(
                                      context: context,
                                      type: AlertType.warning,
                                      title: "LogOut",
                                      desc: "Are you sure that you want to logout?",
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "CANCEL",
                                            style: TextStyle(color: Colors.white, fontSize: 18),
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                          color: Colors.black,
                                        ),
                                        DialogButton(
                                          child: Text(
                                            "LOGOUT",
                                            style: TextStyle(color: Colors.white, fontSize: 18),
                                          ),
                                          onPressed: () {
                                            NetworkService.shared.logout(context);
                                            Navigator.popUntil(context, ModalRoute.withName('GetOtpScreen'));
                                          },
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ).show();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Opacity(
                                  opacity: dataService.pickUpAirportOpacityStatus ? 0 : 1,
                                  child: MenuCardOne(
                                    contentRectWidth: contentRectWidth,
                                    iconName: 'planeIcon.png',
                                    titleOne: 'PICK UP',
                                    titleTwo: 'FROM AIRPORT',
                                    subTitle: 'Create a quick booking to be picked up from the airport',
                                    onSelected: () {
                                      dataService.setOpacityStatusToZero();
                                      Future.delayed(Duration(milliseconds: 1000), () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx1) => AirportOrderScreen(),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: Opacity(
                                  opacity: dataService.moreInformationOpacityStatus ? 0 : 1,
                                  child: MenuCardOne(
                                    contentRectWidth: contentRectWidth,
                                    iconName: 'homeIcon.png',
                                    titleOne: 'MORE',
                                    titleTwo: 'INFORMATION',
                                    subTitle: 'Visit our website to view more information on our services',
                                    onSelected: () async {
                                      dataService.setOpacityStatusToZero();
                                      const url = 'https://m.pearsonvision.com/';
                                      if (await canLaunch(url)) {
                                        dataService.resetOpacityStatus();
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class MenuCardOne extends StatelessWidget {
  final double contentRectWidth;
  final String iconName;
  final String titleOne;
  final String titleTwo;
  final String subTitle;
  final VoidCallback onSelected;

  const MenuCardOne({
    required this.contentRectWidth,
    required this.iconName,
    required this.titleOne,
    required this.titleTwo,
    required this.subTitle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: contentRectWidth / 6,
              width: contentRectWidth / 6,
              child: Image.asset('assets/images/$iconName'),
            ),
            SizedBox(height: 5),
            Text(
              titleOne,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            Text(
              titleTwo,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            Text(
              subTitle,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              maxLines: 2,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuCardTwo extends StatelessWidget {
  final double contentRectWidth;
  final String iconName;
  final String title;
  final VoidCallback onSelected;

  const MenuCardTwo({
    required this.contentRectWidth,
    required this.iconName,
    required this.title,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: contentRectWidth / 6,
              width: contentRectWidth / 6,
              child: Image.asset('assets/images/$iconName'),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
