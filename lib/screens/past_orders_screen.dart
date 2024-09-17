import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pvl/models/order.dart';
import 'package:pvl/services/data_service.dart';
import 'package:pvl/services/network_service.dart';

class PastOrdersScreen extends StatefulWidget {
  @override
  _PastOrdersScreenState createState() => _PastOrdersScreenState();
}

class _PastOrdersScreenState extends State<PastOrdersScreen> {
  bool _isSpinnerToShow = false;

  Future<void> _getPastOrders() async {
    setState(() => _isSpinnerToShow = true);
    final response = await NetworkService.shared.getHistory();
    setState(() => _isSpinnerToShow = false);
    NetworkService.shared.showSnackBar(
      response.message,
      response.code == 1 ? Colors.green : Colors.red,
      context,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getPastOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bgwall.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: dataService.pastOrders.isNotEmpty
                          ? ListView.builder(
                        itemCount: dataService.pastOrders.length,
                        itemBuilder: (context, index) {
                          final order = dataService.pastOrders[index];
                          return HistoryOrderCard(
                            order: order,
                            onCancelled: () async {
                              setState(() => _isSpinnerToShow = true);
                              ServerResponse response;
                              if (order.statusFlag == 3 || order.statusFlag == 4) {
                                response = await NetworkService.shared.removeOrder(
                                  orderId: order.id,
                                  index: index,
                                );
                              } else {
                                response = await NetworkService.shared.cancelOrder(
                                  orderId: order.id,
                                );
                              }
                              setState(() => _isSpinnerToShow = false);
                              NetworkService.shared.showSnackBar(
                                response.message,
                                response.code == 1 ? Colors.green : Colors.red,
                                context,
                              );
                            },
                          );
                        },
                      )
                          : Center(
                        child: Text(
                          'No Orders in history to view',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSpinnerToShow)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      height: 50,
      child: Stack(
        children: [
          Center(
            child: Text(
              'PAST ORDERS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, size: 25),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }
}

class HistoryOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onCancelled;

  HistoryOrderCard({@required this.order, @required this.onCancelled});

  @override
  Widget build(BuildContext context) {
    final buttonName = (order.statusFlag == 3 || order.statusFlag == 4) ? 'REMOVE' : 'CANCEL';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${order.travelDateTime}',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '#${order.id}',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.fullName,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                        SizedBox(height: 2),
                        Text(
                          order.email,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                        SizedBox(height: 3),
                        Text(
                          order.phoneNo,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.carName(),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.deepOrange),
                      ),
                      Text(
                        '\$${order.totalFare.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(color: Colors.deepOrange),
              Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.green, size: 22),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      order.travelFrom,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_pin, size: 22, color: Colors.red),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      order.travelTo,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.deepOrange),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: onCancelled,
                  child: Container(
                    width: 75,
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        buttonName,
                        style: TextStyle(color: Colors.white),
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
  }
}
